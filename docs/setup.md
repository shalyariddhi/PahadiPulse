# PahadiPulse: Subsystem Setup & Execution Guide

This guide details how to install dependencies and run each subsystem independently.

---

## 1. Prerequisites
- **Python**: 3.10 or higher
- **Node.js**: 18.x or higher with `npm`
- **Flutter**: 3.x (with Dart 3.x)

---

## 2. FastAPI Backend (`/backend`)

### Installation:
```bash
cd backend
python -m pip install -r requirements.txt
```

### Environment Configuration:
Create a `.env` file from `.env.example`:
```bash
cp .env.example .env
```
*(Optional: Provide `service-account.json` in `backend/` for Cloud Firestore connection).*

### Seed Data & Start Server:
```bash
python -m scripts.seed_data
python -m uvicorn app.main:app --reload --port 8000
```
- **API URL**: `http://localhost:8000`
- **Swagger Documentation**: `http://localhost:8000/docs`

---

## 3. React Admin Portal (`/admin`)

### Installation:
```bash
cd admin
npm install
```

### Environment Configuration:
Create a `.env` file from `.env.example`:
```bash
cp .env.example .env
```

### Start Development Server:
```bash
npm run dev
```
- **Admin Portal URL**: `http://localhost:5173`

---

## 4. Flutter Tourist Mobile Application (`/mobile`)

### Installation:
```bash
cd mobile
flutter pub get
```

### Run on Device / Emulator:
```bash
flutter run
```

---

## 5. Machine Learning Pipeline (`/ml`)

### Installation & Training:
```bash
cd ml
pip install -r requirements.txt
python train.py
python evaluate.py
```
Models will be trained and exported to `ml/models/` and `backend/app/ml/saved_models/`.
