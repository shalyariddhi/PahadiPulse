import os
import sys
import json
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.core.firebase import db
from app.services.pressure_service import pressure_service
from app.services.ml_service import ml_service

# 20 Official Uttarakhand Regional Destinations across Garhwal & Kumaon
DESTINATIONS_SEED = [
    {
        "id": "mussoorie",
        "name": "Mussoorie",
        "district": "Dehradun",
        "latitude": 30.4598,
        "longitude": 78.0644,
        "altitudeMeters": 2005,
        "capacity": 15000,
        "capacityDailyTourists": 15000,
        "currentVisitorsEst": 22400,
        "tourismScore": 88.0,
        "waterScore": 82.0,
        "wasteScore": 76.0,
        "trafficScore": 92.0,
        "environmentScore": 45.0,
        "description": "Queen of the Hills, experiencing acute weekend traffic bottlenecks on Mall Road and chronic water tanker demand.",
        "tags": ["Nature", "Colonial Heritage", "Photography", "Food"],
        "bestSeasons": ["March-June", "September-November"],
        "avgDailyBudgetINR": 3800,
        "popularSpots": ["Gun Hill", "Kempty Falls", "Camel's Back Road", "Mall Road"],
        "imageUrl": "https://images.unsplash.com/photo-1596401057633-54a8fe8ef647?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "dhanaulti",
        "name": "Dhanaulti",
        "district": "Tehri Garhwal",
        "latitude": 30.4500,
        "longitude": 78.2333,
        "altitudeMeters": 2286,
        "capacity": 5000,
        "capacityDailyTourists": 5000,
        "currentVisitorsEst": 1400,
        "tourismScore": 28.0,
        "waterScore": 30.0,
        "wasteScore": 22.0,
        "trafficScore": 20.0,
        "environmentScore": 25.0,
        "description": "Quiet deodar sanctuary with eco-parks managed by local forest cooperatives. Ideal low-stress alternative to Mussoorie.",
        "tags": ["Nature", "Relaxation", "Photography"],
        "bestSeasons": ["March-June", "September-January"],
        "avgDailyBudgetINR": 2400,
        "popularSpots": ["Amber Eco Park", "Dhara Eco Park", "Potato Farm Viewpoint"],
        "imageUrl": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "kanatal",
        "name": "Kanatal",
        "district": "Tehri Garhwal",
        "latitude": 30.4123,
        "longitude": 78.3341,
        "altitudeMeters": 2590,
        "capacity": 4000,
        "capacityDailyTourists": 4000,
        "currentVisitorsEst": 950,
        "tourismScore": 18.0,
        "waterScore": 25.0,
        "wasteScore": 15.0,
        "trafficScore": 12.0,
        "environmentScore": 20.0,
        "description": "Pristine mountain ridge wrapped in dense deodar and pine forests. Low infrastructure strain and authentic village stays.",
        "tags": ["Nature", "Adventure", "Relaxation", "Photography"],
        "bestSeasons": ["All Year"],
        "avgDailyBudgetINR": 2200,
        "popularSpots": ["Surkanda Devi Temple", "Kodia Jungle", "Tehri Viewpoint"],
        "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "rishikesh",
        "name": "Rishikesh",
        "district": "Dehradun",
        "latitude": 30.0869,
        "longitude": 78.2676,
        "altitudeMeters": 372,
        "capacity": 25000,
        "capacityDailyTourists": 25000,
        "currentVisitorsEst": 31000,
        "tourismScore": 84.0,
        "waterScore": 62.0,
        "wasteScore": 68.0,
        "trafficScore": 85.0,
        "environmentScore": 40.0,
        "description": "Yoga capital of the world experiencing severe pilgrim and adventure traffic near Tapovan and Ram Jhula.",
        "tags": ["Adventure", "Spiritual", "Culture", "Food"],
        "bestSeasons": ["September-April"],
        "avgDailyBudgetINR": 2800,
        "popularSpots": ["Triveni Ghat", "Ram Jhula", "Laxman Jhula", "Beatles Ashram"],
        "imageUrl": "https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "nainital",
        "name": "Nainital",
        "district": "Nainital",
        "latitude": 29.3919,
        "longitude": 79.4542,
        "altitudeMeters": 2084,
        "capacity": 18000,
        "capacityDailyTourists": 18000,
        "currentVisitorsEst": 24500,
        "tourismScore": 86.0,
        "waterScore": 79.0,
        "wasteScore": 72.0,
        "trafficScore": 89.0,
        "environmentScore": 48.0,
        "description": "Famous Kumaon lake city under peak tourist pressure with severe parking shortages along Mallital and Tallital.",
        "tags": ["Nature", "Boating", "Photography", "Relaxation"],
        "bestSeasons": ["March-June", "October-December"],
        "avgDailyBudgetINR": 3600,
        "popularSpots": ["Naini Lake", "Naina Peak", "Snow View Point", "Tiffin Top"],
        "imageUrl": "https://images.unsplash.com/photo-1610444583713-2615a1f6a1d4?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "mukteshwar",
        "name": "Mukteshwar",
        "district": "Nainital",
        "latitude": 29.4722,
        "longitude": 79.6478,
        "altitudeMeters": 2171,
        "capacity": 5000,
        "capacityDailyTourists": 5000,
        "currentVisitorsEst": 1600,
        "tourismScore": 32.0,
        "waterScore": 36.0,
        "wasteScore": 24.0,
        "trafficScore": 22.0,
        "environmentScore": 25.0,
        "description": "Panoramic Himalayan views, apple and apricot orchards, and quiet village trails.",
        "tags": ["Nature", "Adventure", "Photography", "Food"],
        "bestSeasons": ["March-June", "October-February"],
        "avgDailyBudgetINR": 2700,
        "popularSpots": ["Chauli Ki Jali", "Mukteshwar Dham", "Bhaalu Gaad Waterfall"],
        "imageUrl": "https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "auli",
        "name": "Auli",
        "district": "Chamoli",
        "latitude": 30.5284,
        "longitude": 79.5670,
        "altitudeMeters": 2800,
        "capacity": 6000,
        "capacityDailyTourists": 6000,
        "currentVisitorsEst": 3200,
        "tourismScore": 48.0,
        "waterScore": 42.0,
        "wasteScore": 38.0,
        "trafficScore": 55.0,
        "environmentScore": 40.0,
        "description": "Premier skiing destination surrounded by coniferous and oak forests, accessed via ropeway from Joshimath.",
        "tags": ["Adventure", "Nature", "Photography"],
        "bestSeasons": ["December-March (Skiing)", "May-October"],
        "avgDailyBudgetINR": 4200,
        "popularSpots": ["Auli Ropeway", "Gorson Bugyal Trek", "Artificial Lake"],
        "imageUrl": "https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "chopta",
        "name": "Chopta",
        "district": "Rudraprayag",
        "latitude": 30.4878,
        "longitude": 79.1764,
        "altitudeMeters": 2680,
        "capacity": 3500,
        "capacityDailyTourists": 3500,
        "currentVisitorsEst": 850,
        "tourismScore": 24.0,
        "waterScore": 28.0,
        "wasteScore": 20.0,
        "trafficScore": 14.0,
        "environmentScore": 30.0,
        "description": "Mini Switzerland of Uttarakhand. Base camp for the sacred Tungnath and Chandrashila treks with pristine alpine meadows.",
        "tags": ["Nature", "Adventure", "Spiritual", "Photography"],
        "bestSeasons": ["April-November", "December-February (Snow)"],
        "avgDailyBudgetINR": 2000,
        "popularSpots": ["Tungnath Temple", "Chandrashila Summit", "Deoria Tal Trek"],
        "imageUrl": "https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "lansdowne",
        "name": "Lansdowne",
        "district": "Pauri Garhwal",
        "latitude": 29.8377,
        "longitude": 78.6872,
        "altitudeMeters": 1706,
        "capacity": 6000,
        "capacityDailyTourists": 6000,
        "currentVisitorsEst": 2100,
        "tourismScore": 35.0,
        "waterScore": 38.0,
        "wasteScore": 26.0,
        "trafficScore": 28.0,
        "environmentScore": 20.0,
        "description": "Clean, orderly cantonment hill station surrounded by blue pine and oak forests.",
        "tags": ["Nature", "Culture", "Relaxation"],
        "bestSeasons": ["All Year"],
        "avgDailyBudgetINR": 2600,
        "popularSpots": ["Bhulla Lake", "Tip N Top Viewpoint", "St. John's Church"],
        "imageUrl": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "ranikhet",
        "name": "Ranikhet",
        "district": "Almora",
        "latitude": 29.6434,
        "longitude": 79.4322,
        "altitudeMeters": 1869,
        "capacity": 6000,
        "capacityDailyTourists": 6000,
        "currentVisitorsEst": 1950,
        "tourismScore": 30.0,
        "waterScore": 32.0,
        "wasteScore": 20.0,
        "trafficScore": 22.0,
        "environmentScore": 18.0,
        "description": "Cantonment hill town with historic pine glades, golf courses, and quiet walking ridges.",
        "tags": ["Nature", "Culture", "Relaxation"],
        "bestSeasons": ["March-June", "September-November"],
        "avgDailyBudgetINR": 2500,
        "popularSpots": ["Chaubatia Apple Gardens", "Golf Course", "Jhula Devi Temple"],
        "imageUrl": "https://images.unsplash.com/photo-1426604966848-d7adac402bff?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "almora",
        "name": "Almora",
        "district": "Almora",
        "latitude": 29.5971,
        "longitude": 79.6591,
        "altitudeMeters": 1638,
        "capacity": 8000,
        "capacityDailyTourists": 8000,
        "currentVisitorsEst": 3400,
        "tourismScore": 42.0,
        "waterScore": 46.0,
        "wasteScore": 38.0,
        "trafficScore": 39.0,
        "environmentScore": 24.0,
        "description": "Cultural heart of Kumaon famous for Bal Mithai, heritage copperware, and centuries-old stone lanes.",
        "tags": ["Culture", "Food", "Spiritual", "Heritage"],
        "bestSeasons": ["March-June", "September-November"],
        "avgDailyBudgetINR": 2400,
        "popularSpots": ["Kasai Devi Temple", "Bright End Corner", "Chitai Golu Devta"],
        "imageUrl": "https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "binsar",
        "name": "Binsar",
        "district": "Almora",
        "latitude": 29.7042,
        "longitude": 79.7497,
        "altitudeMeters": 2420,
        "capacity": 2500,
        "capacityDailyTourists": 2500,
        "currentVisitorsEst": 480,
        "tourismScore": 16.0,
        "waterScore": 20.0,
        "wasteScore": 12.0,
        "trafficScore": 10.0,
        "environmentScore": 18.0,
        "description": "Wilderness sanctuary offering panoramic 300km vistas of Trishul, Nanda Devi, and Panchachuli peaks.",
        "tags": ["Nature", "Photography", "Relaxation"],
        "bestSeasons": ["October-March", "April-June"],
        "avgDailyBudgetINR": 2500,
        "popularSpots": ["Zero Point", "Binsar Wildlife Sanctuary", "Mary Budden Estate Trail"],
        "imageUrl": "https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "tehri",
        "name": "Tehri Lake & New Tehri",
        "district": "Tehri Garhwal",
        "latitude": 30.3800,
        "longitude": 78.4800,
        "altitudeMeters": 1750,
        "capacity": 7000,
        "capacityDailyTourists": 7000,
        "currentVisitorsEst": 2300,
        "tourismScore": 34.0,
        "waterScore": 28.0,
        "wasteScore": 24.0,
        "trafficScore": 26.0,
        "environmentScore": 22.0,
        "description": "Emerald reservoir surrounded by high ridges, offering regulated water sports, floating cottages, and boating.",
        "tags": ["Adventure", "Water Sports", "Nature"],
        "bestSeasons": ["All Year"],
        "avgDailyBudgetINR": 2900,
        "popularSpots": ["Tehri Dam Viewpoint", "Water Sports Complex", "Floating Huts"],
        "imageUrl": "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "chakrata",
        "name": "Chakrata",
        "district": "Dehradun",
        "latitude": 30.7042,
        "longitude": 77.8681,
        "altitudeMeters": 2118,
        "capacity": 4500,
        "capacityDailyTourists": 4500,
        "currentVisitorsEst": 1100,
        "tourismScore": 22.0,
        "waterScore": 24.0,
        "wasteScore": 18.0,
        "trafficScore": 15.0,
        "environmentScore": 22.0,
        "description": "Secluded cantonment town offering Tiger Falls and the high coniferous ridges of Deoban.",
        "tags": ["Nature", "Adventure", "Culture", "Relaxation"],
        "bestSeasons": ["March-June", "October-February"],
        "avgDailyBudgetINR": 2100,
        "popularSpots": ["Tiger Falls", "Deoban Forest", "Chilmiri Neck", "Budher Caves"],
        "imageUrl": "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "harsil",
        "name": "Harsil",
        "district": "Uttarkashi",
        "latitude": 31.0378,
        "longitude": 78.7397,
        "altitudeMeters": 2620,
        "capacity": 3500,
        "capacityDailyTourists": 3500,
        "currentVisitorsEst": 720,
        "tourismScore": 19.0,
        "waterScore": 16.0,
        "wasteScore": 14.0,
        "trafficScore": 15.0,
        "environmentScore": 25.0,
        "description": "Charming apple valley on the banks of the Bhagirathi river, offering untouched cedar woods and wooden houses.",
        "tags": ["Nature", "Relaxation", "Photography", "Culture"],
        "bestSeasons": ["April-June", "September-October"],
        "avgDailyBudgetINR": 2300,
        "popularSpots": ["Bagori Village", "Dharali Apple Orchards", "Saat Tal Trek"],
        "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "munsiyari",
        "name": "Munsiyari",
        "district": "Pithoragarh",
        "latitude": 30.0667,
        "longitude": 80.2333,
        "altitudeMeters": 2200,
        "capacity": 3000,
        "capacityDailyTourists": 3000,
        "currentVisitorsEst": 550,
        "tourismScore": 15.0,
        "waterScore": 18.0,
        "wasteScore": 14.0,
        "trafficScore": 10.0,
        "environmentScore": 28.0,
        "description": "Gateway to the Johar Valley and Milam Glacier, sitting directly facing the magnificent Panchachuli 5 peaks.",
        "tags": ["Adventure", "Nature", "Culture", "Photography"],
        "bestSeasons": ["March-June", "September-November"],
        "avgDailyBudgetINR": 2100,
        "popularSpots": ["Panchachuli Viewpoint", "Birthi Falls", "Khaliya Top Trek"],
        "imageUrl": "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "kausani",
        "name": "Kausani",
        "district": "Bageshwar",
        "latitude": 29.8543,
        "longitude": 79.5967,
        "altitudeMeters": 1890,
        "capacity": 4000,
        "capacityDailyTourists": 4000,
        "currentVisitorsEst": 900,
        "tourismScore": 20.0,
        "waterScore": 22.0,
        "wasteScore": 16.0,
        "trafficScore": 14.0,
        "environmentScore": 18.0,
        "description": "Known as the Switzerland of India for its uninterrupted 300km Himalayan panoramas and organic tea gardens.",
        "tags": ["Nature", "Culture", "Relaxation", "Photography"],
        "bestSeasons": ["April-June", "September-November"],
        "avgDailyBudgetINR": 2200,
        "popularSpots": ["Anasakti Ashram", "Kausani Tea Estate", "Rudradhari Falls"],
        "imageUrl": "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "devprayag",
        "name": "Devprayag",
        "district": "Tehri Garhwal",
        "latitude": 30.1458,
        "longitude": 78.5989,
        "altitudeMeters": 830,
        "capacity": 5000,
        "capacityDailyTourists": 5000,
        "currentVisitorsEst": 1500,
        "tourismScore": 28.0,
        "waterScore": 22.0,
        "wasteScore": 25.0,
        "trafficScore": 32.0,
        "environmentScore": 35.0,
        "description": "Holy confluence of Alaknanda and Bhagirathi rivers forming the sacred Ganga river.",
        "tags": ["Spiritual", "Culture", "Photography"],
        "bestSeasons": ["September-May"],
        "avgDailyBudgetINR": 1800,
        "popularSpots": ["Sangam Confluence Ghat", "Raghunathji Temple", "Suspension Bridge"],
        "imageUrl": "https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "uttarkashi",
        "name": "Uttarkashi",
        "district": "Uttarkashi",
        "latitude": 30.7268,
        "longitude": 78.4354,
        "altitudeMeters": 1158,
        "capacity": 9000,
        "capacityDailyTourists": 9000,
        "currentVisitorsEst": 3800,
        "tourismScore": 44.0,
        "waterScore": 38.0,
        "wasteScore": 36.0,
        "trafficScore": 42.0,
        "environmentScore": 38.0,
        "description": "Major mountaineering center hosting NIM and gateway to Gangotri and high Himalayan passes.",
        "tags": ["Adventure", "Spiritual", "Nature"],
        "bestSeasons": ["March-June", "September-November"],
        "avgDailyBudgetINR": 2200,
        "popularSpots": ["Vishwanath Temple", "Nehru Institute of Mountaineering", "Maneri Dam"],
        "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    },
    {
        "id": "pauri",
        "name": "Pauri",
        "district": "Pauri Garhwal",
        "latitude": 30.1500,
        "longitude": 78.7800,
        "altitudeMeters": 1814,
        "capacity": 5500,
        "capacityDailyTourists": 5500,
        "currentVisitorsEst": 1200,
        "tourismScore": 22.0,
        "waterScore": 26.0,
        "wasteScore": 18.0,
        "trafficScore": 16.0,
        "environmentScore": 22.0,
        "description": "District headquarters sitting high on Kandoliya hill with sweeping views of the snow-clad Chaukhamba and Kedarnath peaks.",
        "tags": ["Nature", "Culture", "Relaxation", "Photography"],
        "bestSeasons": ["March-June", "September-December"],
        "avgDailyBudgetINR": 2100,
        "popularSpots": ["Kandoliya Temple & Pine Park", "Kyunkaleshwar Mahadev", "Ransi Ground"],
        "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        "isDemo": True,
        "dataSource": "DEMO_SYNTHETIC_HACKATHON"
    }
]

PROVIDERS_SEED = [
    {
        "id": "prov_kanatal_01",
        "destinationId": "kanatal",
        "name": "Pahadi Soul Homestay & Organic Orchard",
        "category": "HOMESTAY",
        "description": "Authentic stone-and-wood Garhwali homestay serving Mandua roti, Bhatt ki dal, and wild rhododendron cordial.",
        "ownerName": "Suresh Negi",
        "contactPhone": "+91 98765 43210",
        "contactEmail": "suresh.kanatal@pahadipulse.in",
        "locationAddress": "Upper Ridge Trail, Kanatal",
        "latitude": 30.4125,
        "longitude": 78.3344,
        "priceStartingINR": 1800,
        "pricingUnit": "per room/night",
        "verified": True,
        "rating": 4.9,
        "imageUrl": "https://images.unsplash.com/photo-1587061949409-02df41d5e562?auto=format&fit=crop&w=600&q=80",
        "isDemo": True
    },
    {
        "id": "prov_kanatal_02",
        "destinationId": "kanatal",
        "name": "Kodia Jungle Local Trek & Birding Guides",
        "category": "LOCAL_GUIDE",
        "description": "Certified local youth guiding safe walking trails through dense deodar forests, barking deer habitats, and natural springs.",
        "ownerName": "Deepak Rawat",
        "contactPhone": "+91 98765 43211",
        "locationAddress": "Kodia Forest Gate, Kanatal",
        "latitude": 30.4130,
        "longitude": 78.3350,
        "priceStartingINR": 600,
        "pricingUnit": "per half-day guided walk",
        "verified": True,
        "rating": 4.8,
        "imageUrl": "https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=600&q=80",
        "isDemo": True
    },
    {
        "id": "prov_chopta_01",
        "destinationId": "chopta",
        "name": "Monal Himalayan Eco-Camps & Stays",
        "category": "HOMESTAY",
        "description": "Solar-powered eco-stay offering zero-waste hospitality and high-altitude acclimitization guidance.",
        "ownerName": "Rameshwar Prasad",
        "contactPhone": "+91 98765 43212",
        "locationAddress": "Dugalbitta, Chopta Base",
        "latitude": 30.4850,
        "longitude": 79.1720,
        "priceStartingINR": 2100,
        "pricingUnit": "per Swiss tent/night with meals",
        "verified": True,
        "rating": 4.9,
        "imageUrl": "https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=600&q=80",
        "isDemo": True
    }
]

REPORTS_SEED = [
    {
        "id": "rep_seed_01",
        "userId": "citizen_mussoorie_01",
        "userName": "Deepak Rawat",
        "destinationId": "mussoorie",
        "destinationName": "Mussoorie",
        "category": "WATER",
        "description": "Main drinking water pipeline ruptured near Library Chowk; taps dry in Barlowganj for the 3rd consecutive day.",
        "imageUrl": "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80",
        "latitude": 30.4580,
        "longitude": 78.0670,
        "status": "AI_CLASSIFIED",
        "adminNotes": "AI Recommendation: Alert Jal Sansthan water supply engineer & initiate emergency water tanker deployment.",
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=3)).isoformat(),
        "isDemo": True
    },
    {
        "id": "rep_seed_02",
        "userId": "tourist_mussoorie_02",
        "userName": "Amit Sharma",
        "destinationId": "mussoorie",
        "destinationName": "Mussoorie",
        "category": "TRAFFIC",
        "description": "Massive 6km vehicle gridlock from Kolhukhet toll barrier all the way up to Picture Palace; single lane blocked by parked tourist buses.",
        "imageUrl": "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=600&q=80",
        "latitude": 30.4350,
        "longitude": 78.0750,
        "status": "VERIFIED",
        "adminNotes": "Traffic police Dehradun notified. Diverting heavy vehicles at Rajpur road.",
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=6)).isoformat(),
        "isDemo": True
    }
]

def seed_database():
    print("Seeding PahadiPulse Database...")

    # 1. Seed Destinations
    print(f"Seeding {len(DESTINATIONS_SEED)} Uttarakhand destinations...")
    for dest in DESTINATIONS_SEED:
        t = dest["tourismScore"]
        w = dest["waterScore"]
        ws = dest["wasteScore"]
        tr = dest["trafficScore"]
        env = dest["environmentScore"]
        score, stat, _ = pressure_service.calculate_score(t, w, ws, tr, env)

        dest["pressureScore"] = score
        dest["status"] = stat
        dest["subScores"] = {
            "tourism": t,
            "water": w,
            "waste": ws,
            "traffic": tr,
            "environment": env
        }
        dest["updatedAt"] = datetime.now(timezone.utc).isoformat()
        db.save("destinations", dest["id"], dest)

    # 2. Seed Providers
    print(f"Seeding {len(PROVIDERS_SEED)} local providers and homestays...")
    dest_map = {d["id"]: d["name"] for d in DESTINATIONS_SEED}
    for prov in PROVIDERS_SEED:
        prov["destinationName"] = dest_map.get(prov["destinationId"], prov["destinationId"])
        db.save("local_providers", prov["id"], prov)

    # 3. Seed Reports with AI inference
    print(f"Seeding {len(REPORTS_SEED)} citizen reports with AI classification...")
    for rep in REPORTS_SEED:
        ai_res = ml_service.classify_report(rep["description"])
        rep["aiCategory"] = ai_res.aiCategory
        rep["aiSeverity"] = ai_res.aiSeverity
        rep["aiConfidence"] = ai_res.aiConfidence
        rep["aiExplanation"] = ai_res.aiExplanation
        db.save("reports", rep["id"], rep)

    # 4. Seed 30-day Historical Pressure Logs for all destinations
    print(f"Seeding 30-day historical pressure logs for all {len(DESTINATIONS_SEED)} destinations...")
    now = datetime.now(timezone.utc)
    for dest in DESTINATIONS_SEED:
        dest_id = dest["id"]
        base_t = dest["tourismScore"]
        base_w = dest["waterScore"]
        base_ws = dest["wasteScore"]
        base_tr = dest["trafficScore"]
        base_env = dest["environmentScore"]

        for i in range(29, -1, -1):
            day_date = now - timedelta(days=i)
            # Weekend surge simulation
            weekend_boost = 12.0 if day_date.weekday() in (5, 6) else -4.0
            import random
            random.seed((hash(dest_id) + i * 37) % 100000)
            jitter = (random.random() - 0.5) * 5.0
            
            t = max(0.0, min(100.0, base_t + weekend_boost + jitter))
            w = max(0.0, min(100.0, base_w + (weekend_boost * 0.4) + jitter))
            ws = max(0.0, min(100.0, base_ws + (weekend_boost * 0.5) + jitter))
            tr = max(0.0, min(100.0, base_tr + (weekend_boost * 0.8) + jitter))
            env = max(0.0, min(100.0, base_env + (jitter * 0.3)))

            score, status, _ = pressure_service.calculate_score(t, w, ws, tr, env)
            hist_id = f"{dest_id}_{day_date.strftime('%Y%m%d')}"
            hist_record = {
                "id": hist_id,
                "destinationId": dest_id,
                "date": day_date.strftime("%Y-%m-%d"),
                "timestamp": day_date.isoformat(),
                "score": score,
                "status": status.value if hasattr(status, 'value') else str(status),
                "tourismScore": round(t, 1),
                "waterScore": round(w, 1),
                "wasteScore": round(ws, 1),
                "trafficScore": round(tr, 1),
                "environmentScore": round(env, 1)
            }
            db.save("pressure_history", hist_id, hist_record)

    print(f"Data Seeding completed successfully for all {len(DESTINATIONS_SEED)} destinations!")

if __name__ == "__main__":
    seed_database()
