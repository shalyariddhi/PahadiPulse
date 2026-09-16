# PahadiPulse — Firebase Setup & Cloud Synchronization Guide

PahadiPulse is architected for seamless dual-mode operation:
1. **Zero-Config Evaluation Mode (Default)**: Runs instantly with full persistent local JSON data storage and simulated authentication for judges and reviewers.
2. **Cloud Firebase Mode (Production & Live)**: Connects directly to **Google Cloud Firestore**, **Firebase Authentication**, and **Firebase Storage**.

---

## 1. Firebase Console Setup (One-Time)

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project: `pahadipulse-hackathon`.
2. **Enable Cloud Firestore**:
   - Navigate to **Build > Firestore Database** -> Click **Create database**.
   - Start in **Production mode** (or Test mode).
   - Choose region: `asia-south1` (Mumbai) or `us-central1`.
3. **Enable Firebase Authentication**:
   - Navigate to **Build > Authentication** -> Click **Get started**.
   - In the **Sign-in method** tab, enable **Email/Password**.
4. **Enable Firebase Storage**:
   - Navigate to **Build > Storage** -> Click **Get started** to store incident proof photos.

---

## 2. Connect Backend (FastAPI + Firestore)

### Step 1: Download Service Account Key
1. In Firebase Console, go to **Project Settings** (gear icon) ➔ **Service accounts**.
2. Click **Generate new private key** and download the `.json` file.
3. Move the downloaded file to `pahadipulse/backend/` and rename it to:
   ```
   service-account.json
   ```

### Step 2: Configure Backend `.env`
In `pahadipulse/backend/.env`:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=service-account.json
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
```

### Step 3: Synchronize Seed Data to Cloud Firestore
Run the single synchronization script to populate all 20 Uttarakhand destinations, local providers, and citizen reports straight into Cloud Firestore:
```bash
cd backend
python -m scripts.sync_to_firebase
```

Output:
```
🔥 Syncing data to Firebase Project: pahadipulse-hackathon...
Uploading 20 records to Firestore collection 'destinations'...
✅ Synced collection 'destinations'
Uploading 8 records to Firestore collection 'local_providers'...
✅ Synced collection 'local_providers'
Uploading 5 records to Firestore collection 'reports'...
✅ Synced collection 'reports'

🎉 Successfully synced 33 documents to Cloud Firestore!
```

---

## 3. Connect React Admin Web Portal

1. In Firebase Console, go to **Project Settings** ➔ **General** ➔ **Your apps** ➔ Click the **Web** icon `</>`.
2. Register app as `PahadiPulse Admin`.
3. Copy the `firebaseConfig` keys into `pahadipulse/admin/.env`:
   ```env
   VITE_FIREBASE_API_KEY=AIzaSy...
   VITE_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
   VITE_FIREBASE_PROJECT_ID=your-project-id
   VITE_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=1234567890
   VITE_FIREBASE_APP_ID=1:1234567890:web:abcdef123456
   ```
4. Restart the admin portal:
   ```bash
   cd admin
   npm run dev
   ```

---

## 4. Connect Flutter Mobile App

1. In Firebase Console, register an **Android / iOS** app.
2. Download `google-services.json` and place it in `mobile/android/app/`.
3. The mobile application will automatically communicate with Firestore through the backend API or direct Firebase SDK.
