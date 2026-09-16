import os
import sys
import json
import logging

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.core.firebase import db
from app.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("sync_to_firebase")

def sync_all_collections():
    """
    Pushes local seed data directly to Cloud Firestore collections.
    """
    if not db.firestore_client:
        print("\n" + "="*70)
        print("[Notice] Firebase not connected yet!")
        print("Please ensure service-account.json is present in backend/")
        print("="*70 + "\n")
        return False

    print(f"\n[Firebase Sync] Pushing data to Cloud Firestore (Project: {settings.FIREBASE_PROJECT_ID})...")
    
    collections = ["destinations", "local_providers", "reports"]
    total_synced = 0

    try:
        for col in collections:
            items = db.get_all(col)
            print(f"Uploading {len(items)} records to collection '{col}'...")
            for item in items:
                doc_id = item.get("id")
                if doc_id:
                    db.firestore_client.collection(col).document(doc_id).set(item, merge=True)
                    total_synced += 1
            print(f"[Done] Synced collection '{col}'")

        print(f"\n[Success] Successfully synced {total_synced} documents to Cloud Firestore!")
        return True
    except Exception as e:
        if "firestore.googleapis.com" in str(e) or "PERMISSION_DENIED" in str(e):
            print("\n" + "="*70)
            print("[ACTION REQUIRED IN FIREBASE CONSOLE]")
            print(f"Cloud Firestore is not yet activated for project '{settings.FIREBASE_PROJECT_ID}'.")
            print("To enable it (takes 30 seconds):")
            print(f"1. Open: https://console.firebase.google.com/project/{settings.FIREBASE_PROJECT_ID}/firestore")
            print("2. Click 'Create database'")
            print("3. Choose Location (e.g. asia-south1 or us-central1) and click Enable")
            print("4. Re-run this command: python -m scripts.sync_to_firebase")
            print("="*70 + "\n")
        else:
            print(f"\n[Sync Error] {e}")
        return False

if __name__ == "__main__":
    sync_all_collections()
