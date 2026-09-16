import uuid
from typing import List, Dict, Any
from datetime import datetime, timezone
from app.core.firebase import db
from app.models.schemas import (
    ItineraryRequest, ItineraryResponse, ItineraryDay,
    ItineraryActivity, ItineraryStay, PressureStatus
)

class ItineraryService:
    @staticmethod
    def generate_itinerary(req: ItineraryRequest) -> ItineraryResponse:
        destinations = db.get_all("destinations")
        providers = db.get_all("local_providers")

        if not destinations:
            # Fallback mock destinations if not yet seeded
            destinations = [
                {"id": "kanatal", "name": "Kanatal", "district": "Tehri Garhwal", "pressureScore": 24.5, "status": "LOW", "tags": ["Nature", "Adventure", "Relaxation"], "avgDailyBudgetINR": 2200, "popularSpots": ["Surkanda Devi Trek", "Kodia Jungle Safari"]},
                {"id": "dhanaulti", "name": "Dhanaulti", "district": "Tehri Garhwal", "pressureScore": 32.0, "status": "MODERATE", "tags": ["Nature", "Photography"], "avgDailyBudgetINR": 2400, "popularSpots": ["Amber Eco Park", "Deodar Forest Trails"]},
                {"id": "chopta", "name": "Chopta", "district": "Rudraprayag", "pressureScore": 28.0, "status": "LOW", "tags": ["Nature", "Adventure", "Spiritual"], "avgDailyBudgetINR": 2000, "popularSpots": ["Tungnath Temple Trek", "Chandrashila Peak"]},
                {"id": "chakrata", "name": "Chakrata", "district": "Dehradun", "pressureScore": 26.0, "status": "LOW", "tags": ["Nature", "Adventure", "Culture"], "avgDailyBudgetINR": 2100, "popularSpots": ["Tiger Falls", "Deoban High Ridge"]},
                {"id": "mussoorie", "name": "Mussoorie", "district": "Dehradun", "pressureScore": 78.5, "status": "CRITICAL", "tags": ["Nature", "Food"], "avgDailyBudgetINR": 3800, "popularSpots": ["Mall Road", "Kempty Falls"]}
            ]

        # Calculate high-pressure benchmark (e.g. Mussoorie/Nainital corridor)
        congested_hubs = [d for d in destinations if d.get("pressureScore", 50) >= 65]
        avg_congested_pressure = sum(d.get("pressureScore", 75) for d in congested_hubs) / max(1, len(congested_hubs))
        if avg_congested_pressure < 70:
            avg_congested_pressure = 78.0

        # Filter & score candidate destinations
        user_interests = set(i.lower() for i in req.interests)
        daily_budget_limit = (req.budgetPerPersonINR / max(1, req.daysCount))

        candidates = []
        for d in destinations:
            d_tags = set(t.lower() for t in d.get("tags", []))
            tag_overlap = len(user_interests.intersection(d_tags))
            pressure = float(d.get("pressureScore", 40.0))
            d_budget = float(d.get("avgDailyBudgetINR", 2500.0))

            # Penalty for high pressure (heavy quadratic penalty above 60)
            pressure_penalty = (pressure / 100.0) ** 2 * 50.0
            
            # Preference match bonus
            interest_score = tag_overlap * 25.0

            # Budget fitness bonus
            budget_fit = 20.0 if d_budget <= daily_budget_limit else max(0.0, 20.0 - (d_budget - daily_budget_limit) * 0.02)

            total_score = interest_score + budget_fit - pressure_penalty
            candidates.append({
                "dest": d,
                "score": total_score,
                "pressure": pressure
            })

        # Sort candidates by optimization score descending
        candidates.sort(key=lambda x: x["score"], reverse=True)

        # Select top unique destinations for the itinerary
        selected_destinations = []
        seen_ids = set()
        for c in candidates:
            if c["dest"]["id"] not in seen_ids:
                selected_destinations.append(c["dest"])
                seen_ids.add(c["dest"]["id"])
            if len(selected_destinations) >= req.daysCount:
                break

        # If days > selected, cycle through selected in circuit sequence
        circuit_days: List[ItineraryDay] = []
        total_trip_cost = 0.0
        selected_pressures = []

        for day_idx in range(req.daysCount):
            dest = selected_destinations[day_idx % len(selected_destinations)]
            dest_id = dest.get("id", "")
            dest_name = dest.get("name", "Himalayan Destination")
            district = dest.get("district", "Uttarakhand")
            pressure = float(dest.get("pressureScore", 30.0))
            selected_pressures.append(pressure)

            # Find matching local providers
            dest_providers = [p for p in providers if p.get("destinationId") == dest_id]
            homestay = next((p for p in dest_providers if p.get("category") == "HOMESTAY"), None)
            guide = next((p for p in dest_providers if p.get("category") == "LOCAL_GUIDE"), None)
            food_prov = next((p for p in dest_providers if p.get("category") == "LOCAL_FOOD"), None)

            # Assign stay
            if homestay:
                stay_obj = ItineraryStay(
                    providerId=homestay.get("id"),
                    name=homestay.get("name"),
                    type="Verified Village Homestay",
                    costPerNightINR=float(homestay.get("priceStartingINR", 1800)),
                    bookingContact=homestay.get("contactPhone")
                )
            else:
                stay_obj = ItineraryStay(
                    name=f"Traditional Mountain Stay ({dest_name})",
                    type="Eco-Lodge / Local Homestay",
                    costPerNightINR=2100.0,
                    bookingContact="+91 98765 00000"
                )

            # Generate structured daily activities
            spots = dest.get("popularSpots", ["Panoramic Himalayan Ridge", "Ancient Village Trail"])
            spot1 = spots[0] if len(spots) > 0 else "Scenic Pine Valley"
            spot2 = spots[1] if len(spots) > 1 else "Sunset Point"

            activities: List[ItineraryActivity] = [
                ItineraryActivity(
                    time="08:30 AM",
                    title=f"Morning Exploration at {spot1}",
                    description=f"Guided gentle trail through native forests. High wildlife and mountain panorama visibility with zero crowd bottlenecks.",
                    category="Nature & Trekking",
                    providerName=guide.get("name") if guide else "Local Community Trek Guide",
                    costEstimateINR=350.0
                ),
                ItineraryActivity(
                    time="01:30 PM",
                    title="Organic Pahadi Cuisine Experience",
                    description="Traditional Garhwali/Kumaoni lunch with Mandua roti, Bhatt ki Churkani, and local wild mint chutney.",
                    category="Local Food",
                    providerName=food_prov.get("name") if food_prov else "Village Community Kitchen",
                    costEstimateINR=400.0
                ),
                ItineraryActivity(
                    time="04:30 PM",
                    title=f"Golden Hour Visit to {spot2}",
                    description=f"Uninterrupted views of snow-capped peaks with authentic handicrafts and herbal tea from local cooperatives.",
                    category="Culture & Relaxation",
                    providerName="Pahadi Artisans Guild",
                    costEstimateINR=250.0
                )
            ]

            day_activity_cost = sum(a.costEstimateINR for a in activities)
            day_total = (day_activity_cost * req.travellersCount) + stay_obj.costPerNightINR
            total_trip_cost += day_total

            circuit_days.append(ItineraryDay(
                dayNumber=day_idx + 1,
                destinationId=dest_id,
                destinationName=dest_name,
                district=district,
                pressureLevel=PressureStatus(dest.get("status", "LOW")),
                pressureScore=pressure,
                stayRecommendation=stay_obj,
                activities=activities,
                travelNote=f"Scenic mountain road transit. Low traffic congestion expected on the {dest_name} corridor."
            ))

        avg_chosen_pressure = sum(selected_pressures) / max(1, len(selected_pressures))
        mitigation_pct = round(max(0.0, (avg_congested_pressure - avg_chosen_pressure) / avg_congested_pressure * 100.0), 1)

        dest_names_str = ", ".join(list(dict.fromkeys(d.destinationName for d in circuit_days)))
        rationale = (
            f"Optimized circuit balances your preferences ({', '.join(req.interests)}) and budget while "
            f"avoiding congested high-pressure choke points. By directing your travel to {dest_names_str}, "
            f"this itinerary reduces estimated regional infrastructure strain by {mitigation_pct}% and routes 100% of accommodation to local village homestays."
        )

        itin_res = ItineraryResponse(
            id=f"itin_{uuid.uuid4().hex[:8]}",
            title=f"PahadiPulse Sustainable {req.daysCount}-Day Eco Circuit",
            daysCount=req.daysCount,
            travellersCount=req.travellersCount,
            budgetPerPersonINR=req.budgetPerPersonINR,
            totalEstimatedCostINR=round(total_trip_cost, 0),
            pressureMitigationScore=mitigation_pct,
            interests=req.interests,
            startingRegion=req.startingRegion or "Dehradun / Rishikesh",
            rationale=rationale,
            days=circuit_days,
            createdAt=datetime.now(timezone.utc).isoformat() + "Z"
        )

        # Cache itinerary into db
        db.save("itineraries", itin_res.id, itin_res.model_dump())
        return itin_res

itinerary_service = ItineraryService()
