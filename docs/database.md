# PahadiPulse — Database & Schema Specification

## 1. Firestore Collections Overview

PahadiPulse organizes regional telemetry, destinations, issue tickets, and local economic entities into 8 primary Firestore collections:

```
├── destinations/
├── reports/
├── pressure_history/
├── pressure_predictions/
├── local_providers/
├── itineraries/
├── users/
└── notifications/
```

---

## 2. Detailed Schema Definitions

### `destinations`
Stores geo-coordinates, capacity limits, and current sub-factor scores for each Uttarakhand regional hub.

```json
{
  "id": "mussoorie",
  "name": "Mussoorie",
  "district": "Dehradun",
  "latitude": 30.4598,
  "longitude": 78.0644,
  "description": "Queen of the Hills, facing severe seasonal gridlock and water scarcity on Mall Road.",
  "altitudeMeters": 2005,
  "capacityDailyTourists": 15000,
  "currentVisitorsEst": 22400,
  "tourismScore": 88.5,
  "waterScore": 82.0,
  "wasteScore": 74.5,
  "trafficScore": 91.0,
  "environmentScore": 45.0,
  "pressureScore": 78.6,
  "status": "CRITICAL",
  "tags": ["Nature", "Colonial Heritage", "Photography", "Food"],
  "bestSeasons": ["March-June", "September-November"],
  "avgDailyBudgetINR": 3500,
  "popularSpots": ["Gun Hill", "Kempty Falls", "Mall Road", "Camel's Back"],
  "imageUrl": "https://images.unsplash.com/photo-1596401057633-54a8fe8ef647",
  "updatedAt": "2026-09-14T10:00:00Z"
}
```

### `reports`
Tracks citizen and traveler infrastructure reports with AI classification and workflow status.

```json
{
  "id": "rep-2026-001",
  "userId": "user_citizen_101",
  "userName": "Deepak Rawat",
  "destinationId": "mussoorie",
  "destinationName": "Mussoorie",
  "category": "WASTE",
  "description": "Massive plastic bottle and carton dump near Kempty bypass causing water blockage in natural stream.",
  "imageUrl": "https://images.unsplash.com/photo-1611288875785-f5b2111d0fc8",
  "latitude": 30.4812,
  "longitude": 78.0411,
  "aiCategory": "WASTE",
  "aiSeverity": 4,
  "aiConfidence": 0.94,
  "aiExplanation": "Identified high-density plastic pollution obstructing drainage waterway; immediate municipal clearance recommended.",
  "status": "AI_CLASSIFIED",
  "adminNotes": "Forwarded to Mussoorie Nagar Palika sanitation team.",
  "createdAt": "2026-09-14T08:30:00Z",
  "resolvedAt": null
}
```

### `pressure_history` & `pressure_predictions`
Used for historical trend auditing and forward ML forecasting.

```json
{
  "id": "pred_mussoorie_2026_09_15",
  "destinationId": "mussoorie",
  "forecastDate": "2026-09-15",
  "predictedPressure": 81.2,
  "confidenceLower": 76.5,
  "confidenceUpper": 85.9,
  "primaryRiskFactor": "Weekend traffic rush + municipal water supply tanker shortage",
  "generatedAt": "2026-09-14T00:00:00Z"
}
```

### `local_providers`
Empowers local homestays, village guides, and traditional artisans.

```json
{
  "id": "prov_kanatal_01",
  "destinationId": "kanatal",
  "name": "Pahadi Soul Homestay & Apple Orchard",
  "category": "HOMESTAY",
  "description": "Authentic stone-and-wood Garhwali homestay serving Mandua roti and wild rhododendron juice.",
  "ownerName": "Suresh Negi",
  "contactPhone": "+91 98765 43210",
  "contactEmail": "suresh.kanatal@pahadipulse.in",
  "locationAddress": "Upper Kanatal Ridge, Tehri Garhwal",
  "latitude": 30.4123,
  "longitude": 78.3341,
  "priceStartingINR": 1800,
  "pricingUnit": "per room/night with organic breakfast",
  "verified": true,
  "externalBookingUrl": "https://pahadisoul.example.com",
  "imageUrl": "https://images.unsplash.com/photo-1587061949409-02df41d5e562",
  "rating": 4.9
}
```
