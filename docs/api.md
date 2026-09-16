# PahadiPulse — REST API Contract

Base URL: `http://localhost:8000` or `/api/v1`

---

## 1. Destinations & Pressure Endpoints

### `GET /api/destinations`
Returns all registered regional destinations in Uttarakhand with active pressure scores and status levels.
- **Query Params**: `district`, `status`, `tag`, `sort_by`
- **Response**:
```json
[
  {
    "id": "kanatal",
    "name": "Kanatal",
    "district": "Tehri Garhwal",
    "latitude": 30.412,
    "longitude": 78.334,
    "description": "Serene hamlet surrounded by dense deodar and pine forests.",
    "altitudeMeters": 2590,
    "pressureScore": 24.5,
    "status": "LOW",
    "subScores": {
      "tourism": 20.0,
      "water": 28.0,
      "waste": 18.0,
      "traffic": 15.0,
      "environment": 45.0
    },
    "tags": ["Nature", "Adventure", "Relaxation", "Photography"],
    "avgDailyBudgetINR": 2200,
    "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"
  }
]
```

### `GET /api/destinations/{id}/pressure`
Returns current granular breakdown and formula transparency for the specified destination.

### `GET /api/destinations/{id}/predictions`
Returns 7-day predicted pressure trend with upper/lower confidence bounds.

---

## 2. Citizen Reporting Endpoints

### `POST /api/reports`
Submits a new citizen or tourist infrastructure issue. The backend automatically routes the description to the AI classification engine.
- **Request Body**:
```json
{
  "userId": "user_123",
  "userName": "Ramesh Pant",
  "destinationId": "mussoorie",
  "category": "OTHER",
  "description": "Severe traffic jam stretching 4km before library chowk; road blocked due to single-lane tourist buses.",
  "imageUrl": "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957",
  "latitude": 30.456,
  "longitude": 78.072
}
```
- **Response**:
```json
{
  "id": "rep_98234",
  "status": "AI_CLASSIFIED",
  "aiCategory": "TRAFFIC",
  "aiSeverity": 4,
  "aiConfidence": 0.92,
  "aiExplanation": "Severe road gridlock detected on critical corridor; high delay impact on emergency transit.",
  "createdAt": "2026-09-14T12:00:00Z"
}
```

### `PATCH /api/reports/{id}/status`
Admin triage workflow status update.
- **Request**: `{"status": "VERIFIED", "adminNotes": "Traffic police Dehradun notified"}`

---

## 3. Smart Itinerary Generator

### `POST /api/itinerary/generate`
Generates a pressure-mitigated, budget-optimized travel plan distributing footfall across Uttarakhand.
- **Request**:
```json
{
  "daysCount": 4,
  "travellersCount": 3,
  "budgetPerPersonINR": 10000,
  "interests": ["Nature", "Adventure"],
  "startingRegion": "Dehradun / Rishikesh",
  "travelMode": "CAB / SELF_DRIVE"
}
```
- **Response**:
```json
{
  "id": "itin_77312",
  "title": "Garhwal Ridge & High Forest Circuit (Eco-Balanced)",
  "daysCount": 4,
  "totalEstimatedCostINR": 28500,
  "pressureMitigationScore": 64.5,
  "rationale": "Optimized to bypass overcrowded Mussoorie Mall Road (78% pressure) by routing you through Dhanaulti, Kanatal, and Chopta with community-owned homestays.",
  "days": [
    {
      "dayNumber": 1,
      "destinationName": "Dhanaulti & Eco-Park",
      "pressureLevel": "LOW",
      "activities": [
        {
          "time": "10:00 AM",
          "title": "Eco-Park Amber Deodar Canopy Walk",
          "category": "Nature",
          "costEstimateINR": 50
        }
      ],
      "stayRecommendation": {
        "name": "Buransh Himalayan Stay",
        "type": "Homestay",
        "costPerNightINR": 2000
      }
    }
  ]
}
```
