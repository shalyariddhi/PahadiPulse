import os
import json
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime, timezone
from app.config import settings

logger = logging.getLogger("pahadipulse.firebase")

class FirebaseManager:
    """
    Robust Firebase integration manager for PahadiPulse:
    - Automatically discovers service account JSON credentials or environment variables.
    - Connects directly to Google Cloud Firestore and Firebase Storage.
    - Synchronizes data seamlessly with local persistent cache to ensure high-performance offline and online operation.
    """
    def __init__(self):
        self.data_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "data")
        os.makedirs(self.data_dir, exist_ok=True)
        self.firestore_client = None
        self.firebase_app = None
        self.is_connected = False
        self._init_firebase()

    def _init_firebase(self):
        cred_path = settings.FIREBASE_CREDENTIALS_PATH or os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "")
        
        # Check standard file locations if not explicitly set
        if not cred_path:
            possible_paths = [
                os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "service-account.json"),
                os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "firebase-key.json"),
                os.path.join(os.getcwd(), "service-account.json"),
            ]
            for p in possible_paths:
                if os.path.exists(p):
                    cred_path = p
                    break

        if cred_path and os.path.exists(cred_path):
            try:
                import firebase_admin
                from firebase_admin import credentials, firestore
                
                if not firebase_admin._apps:
                    cred = credentials.Certificate(cred_path)
                    self.firebase_app = firebase_admin.initialize_app(cred, {
                        'projectId': settings.FIREBASE_PROJECT_ID,
                        'storageBucket': settings.FIREBASE_STORAGE_BUCKET
                    })
                else:
                    self.firebase_app = firebase_admin.get_app()

                self.firestore_client = firestore.client()
                self.is_connected = True
                logger.info(f"Connected successfully to Cloud Firestore (Project: {settings.FIREBASE_PROJECT_ID}) via {cred_path}")
                print(f"[Firebase] Connected successfully to Cloud Firestore (Project: {settings.FIREBASE_PROJECT_ID})")
            except Exception as e:
                logger.warning(f"Failed to connect to Firebase: {e}. Running in local resilient mode.")
                print(f"[Firebase Notice] {e}")
        else:
            logger.info("Running in local storage mode (Place service-account.json in backend/ or set FIREBASE_CREDENTIALS_PATH in .env to connect to live Cloud Firestore).")

    def _get_collection_path(self, collection_name: str) -> str:
        return os.path.join(self.data_dir, f"{collection_name}.json")

    def get_all(self, collection_name: str) -> List[Dict[str, Any]]:
        # Load local seed/cached data
        file_path = self._get_collection_path(collection_name)
        local_items = []
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    local_items = json.load(f)
            except Exception:
                local_items = []

        # If connected to Firestore, query live cloud collection and merge with seed
        if self.firestore_client:
            try:
                docs = self.firestore_client.collection(collection_name).stream()
                cloud_items_map = {d.id: d.to_dict() for d in docs}
                
                # Sync any missing seed items to cloud (batching / selective)
                if collection_name == "local_providers":
                    for local_doc in local_items:
                        lid = local_doc.get("id")
                        if lid and (lid not in cloud_items_map or not cloud_items_map[lid].get("externalBookingUrl")):
                            try:
                                self.firestore_client.collection(collection_name).document(lid).set(local_doc, merge=True)
                            except Exception:
                                pass
                            cloud_items_map[lid] = local_doc
                elif not cloud_items_map and local_items:
                    # Initial cloud seed only if cloud collection is empty
                    for local_doc in local_items[:50]:
                        lid = local_doc.get("id")
                        if lid:
                            try:
                                self.firestore_client.collection(collection_name).document(lid).set(local_doc, merge=True)
                            except Exception:
                                pass
                            cloud_items_map[lid] = local_doc

                items = list(cloud_items_map.values())
                if items:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(items, f, indent=2, ensure_ascii=False)
                    return items
            except Exception as e:
                logger.error(f"Firestore get_all failed: {e}. Falling back to local cache.")

        return local_items

    def get_by_id(self, collection_name: str, doc_id: str) -> Optional[Dict[str, Any]]:
        if self.firestore_client:
            try:
                doc = self.firestore_client.collection(collection_name).document(doc_id).get()
                if doc.exists:
                    return doc.to_dict()
                else:
                    return None
            except Exception as e:
                logger.error(f"Firestore get_by_id failed: {e}")

        items = self.get_all(collection_name)
        for item in items:
            if item.get("id") == doc_id:
                return item
        return None

    def save(self, collection_name: str, doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        data["id"] = doc_id
        if "updatedAt" not in data:
            data["updatedAt"] = datetime.now(timezone.utc).isoformat() + "Z"

        if self.firestore_client:
            try:
                self.firestore_client.collection(collection_name).document(doc_id).set(data, merge=True)
                logger.debug(f"Saved document {doc_id} in Firestore collection '{collection_name}'")
            except Exception as e:
                logger.error(f"Firestore save error: {e}")

        # Update local file cache directly
        file_path = self._get_collection_path(collection_name)
        items = []
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    items = json.load(f)
            except Exception:
                items = []

        existing_idx = next((idx for idx, item in enumerate(items) if item.get("id") == doc_id), None)
        if existing_idx is not None:
            items[existing_idx] = data
        else:
            items.append(data)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(items, f, indent=2, ensure_ascii=False)
        return data

    def create(self, collection_name: str, doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        return self.save(collection_name, doc_id, data)

    def update(self, collection_name: str, doc_id: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        current = self.get_by_id(collection_name, doc_id)
        if not current:
            return None
        
        current.update(updates)
        current["updatedAt"] = datetime.now(timezone.utc).isoformat() + "Z"
        return self.save(collection_name, doc_id, current)

    def delete(self, collection_name: str, doc_id: str) -> bool:
        if self.firestore_client:
            try:
                self.firestore_client.collection(collection_name).document(doc_id).delete()
            except Exception as e:
                logger.error(f"Firestore delete error: {e}")

        file_path = self._get_collection_path(collection_name)
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    items = json.load(f)
                new_items = [item for item in items if item.get("id") != doc_id]
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(new_items, f, indent=2, ensure_ascii=False)
            except Exception:
                pass
        return True

db = FirebaseManager()
