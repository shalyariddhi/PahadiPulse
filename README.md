# PahadiPulse (पहाड़ी पल्स)
### AI-Powered Regional Tourism & Community Intelligence Platform for Uttarakhand
**IBM Hackathon PS-04 — "Solve for My Region"**

![PahadiPulse Banner](https://images.unsplash.com/photo-1596401057633-54a8fe8ef647?auto=format&fit=crop&w=1200&q=80)

---

## 🏔️ The Challenge: Overtourism & Mountain Stress
In Uttarakhand, mass tourism gets severely concentrated in fragile mountain pockets such as Mussoorie, Nainital, and Rishikesh. This causes acute drinking water shortages, municipal waste overflows, landslide risks, and multi-hour traffic bottlenecks on single-lane ghat roads—while enchanting nearby communities (like Kanatal, Dhanaulti, Chopta, Binsar, and Harsil) receive very little tourism income.

**PahadiPulse** solves this regional crisis through **predictive AI, real-time multi-dimensional infrastructure pressure scoring, citizen issue reporting, and pressure-aware itinerary optimization**.

---

## 🌟 Key Features

1. **Regional Pressure Engine**: Real-time 0–100 composite index combining:
   - 30% Tourism / Crowd Footfall
   - 25% Water Resource Stress
   - 20% Municipal Waste Accumulation
   - 15% Traffic & Road Gridlock
   - 10% Seasonal & Landslide Hazard
2. **7-Day ML Pressure Forecasting**: Predicts forward infrastructure strain with upper/lower confidence bounds.
3. **AI Citizen Infrastructure Reporting**: Automated NLP triage classifying citizen reports (`WATER`, `WASTE`, `ROAD`, `TRAFFIC`, etc.) with 1–5 severity scoring and explanation.
4. **Pressure-Aware Smart Itinerary Generator**: Multi-objective heuristic optimization that redistributes footfall from congested hotspots to lower-pressure hidden gems while strictly honoring budget, group size, and traveler interests.
5. **Local Livelihoods & Provider Empowerment**: Integrated directory and itinerary recommendation for verified homestays, local trek guides, Pahadi cuisine outlets, and handicrafts.
6. **Government / Municipal Admin Dashboard**: Interactive regional map with live pressure overlays, citizen report triage workflow, and predictive trend analytics.

---

## 🏛️ System Architecture

```
Flutter Mobile App (Tourist & Citizen)          React + Vite + TS Admin Dashboard
              │                                                │
              └───────────────────────┬────────────────────────┘
                                      │ REST API (JSON)
                                      ▼
                             FastAPI Backend (Python)
              ┌───────────────────────┼────────────────────────┐
              ▼                       ▼                        ▼
     ML Engines & Models      Firebase Cloud Layer     JSON Fallback Store
   - Pressure Regressor       - Cloud Firestore       (Local Zero-Config Mode)
   - Report NLP Classifier    - Firebase Auth
   - Itinerary Optimizer      - Cloud Storage
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Python 3.10+**
- **Node.js 18+** & **npm**
- **Flutter 3.x** (for mobile)

### 2. Backend Setup
```bash
cd backend
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt

# Train AI models & seed 20+ Uttarakhand destinations
python -m app.ml.train_models
python -m scripts.seed_data

# Launch FastAPI server
uvicorn app.main:app --reload --port 8000
```
- Interactive API Docs: `http://localhost:8000/docs`

### 3. Admin Dashboard Setup
```bash
cd ../admin
npm install
npm run dev
```
- Admin Dashboard URL: `http://localhost:5173`

### 4. Mobile App Setup (Flutter)
```bash
cd ../mobile
flutter pub get
flutter run
```

---

## 📊 Live Regional Demo Flow (16-Step Walkthrough)
1. **Open PahadiPulse Web Admin / Mobile**: View the Uttarakhand regional overview.
2. **Examine Mussoorie / Nainital**: Notice high pressure scores (78/100, Critical Water & Traffic stress).
3. **Inspect Pressure Breakdown**: View weighted metrics and seasonal factors.
4. **View ML Predictions**: Notice projected weekend surge alerts.
5. **Launch AI Trip Planner**:
   - Select 4 Days, 3 Travelers, ₹10,000 / person budget.
   - Choose Interests: `Nature` + `Adventure`.
6. **Generate Itinerary**:
   - Engine distributes route to **Kanatal + Dhanaulti + Chopta** instead of overcrowded hotspots.
   - Saves 62% estimated regional pressure load.
7. **Explore Local Experiences**: View certified homestays, guides, and apple orchard visits.
8. **Submit Citizen Issue**:
   - Description: *"Huge plastic bottle accumulation choking stream near Kempty diversion"*
   - AI categorizes as `WASTE` with `Severity 4/5` and generates action summary.
9. **Admin Triage**: Admin views incoming report on the regional map and advances status: `SUBMITTED` ➔ `AI_CLASSIFIED` ➔ `VERIFIED` ➔ `ASSIGNED` ➔ `RESOLVED`.

---

## 🛡️ Security & Privacy
- Zero hardcoded credentials; all keys loaded via `.env`.
- Firebase Authentication token validation for protected administrative actions.
- Role-based authorization (`tourist`, `citizen`, `admin`).
- Safe fallback mode with sandboxed synthetic datasets for hackathon evaluation.

---

## 📜 Documentation Index
- [Architecture Details](docs/architecture.md)
- [Database Schema & Firestore Spec](docs/database.md)
- [REST API Contract](docs/api.md)
- [Machine Learning & Optimization Models](docs/ml.md)
- [Demo Script & Evaluation Guide](docs/demo_guide.md)
