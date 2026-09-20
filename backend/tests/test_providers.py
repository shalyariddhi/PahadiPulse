import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.domain import ProviderCategory

client = TestClient(app)
admin_headers = {"Authorization": "Bearer admin_secret_pahadi"}

def test_get_all_providers():
    res = client.get("/api/providers")
    assert res.status_code == 200
    providers = res.json()
    assert len(providers) >= 10

    # Ensure all demo items have isDemo=True and a disclaimer
    for prov in providers:
        assert prov["isDemo"] is True
        assert "disclaimer" in prov
        assert "Synthetic demo" in prov["disclaimer"]
        assert "priceStartingINR" in prov
        assert "locationAddress" in prov
        assert "contactPhone" in prov

def test_all_seven_categories_represented():
    expected_categories = {
        "HOMESTAY",
        "LOCAL_GUIDE",
        "LOCAL_FOOD",
        "HANDICRAFTS",
        "LOCAL_PRODUCTS",
        "CULTURAL_EXPERIENCE",
        "RENTAL"
    }
    
    res = client.get("/api/providers")
    assert res.status_code == 200
    found_categories = {p["category"] for p in res.json()}
    
    for cat in expected_categories:
        assert cat in found_categories, f"Category {cat} missing from seeded providers"

def test_filter_by_category():
    for cat in ["HOMESTAY", "LOCAL_GUIDE", "LOCAL_FOOD", "HANDICRAFTS", "LOCAL_PRODUCTS", "CULTURAL_EXPERIENCE", "RENTAL"]:
        res = client.get(f"/api/providers?category={cat}")
        assert res.status_code == 200
        items = res.json()
        assert len(items) > 0
        for item in items:
            assert item["category"] == cat

def test_filter_by_destination():
    res = client.get("/api/providers?destination=kanatal")
    assert res.status_code == 200
    items = res.json()
    assert len(items) >= 2
    for item in items:
        assert item["destinationId"].lower() == "kanatal" or item["destinationName"].lower() == "kanatal"

def test_filter_by_price_range():
    res = client.get("/api/providers?min_price=500&max_price=1500")
    assert res.status_code == 200
    items = res.json()
    assert len(items) > 0
    for item in items:
        price = item["priceStartingINR"]
        assert 500 <= price <= 1500

def test_filter_by_verified():
    res = client.get("/api/providers?verified=true")
    assert res.status_code == 200
    items = res.json()
    assert len(items) > 0
    for item in items:
        assert item["verified"] is True

def test_get_provider_by_id():
    res = client.get("/api/providers/prov_kanatal_01")
    assert res.status_code == 200
    data = res.json()
    assert data["id"] == "prov_kanatal_01"
    assert data["name"] == "Pahadi Soul Homestay & Organic Orchard"
    assert data["category"] == "HOMESTAY"
    assert data["destinationId"] == "kanatal"
    assert data["externalBookingUrl"] != ""

def test_get_provider_not_found():
    res = client.get("/api/providers/non_existent_provider_xyz")
    assert res.status_code == 404

def test_admin_provider_crud_lifecycle():
    # 1. Create a new provider as admin
    new_provider = {
        "id": "prov_test_artisan_99",
        "name": "Kumaoni Copper Artisan Guild",
        "category": "HANDICRAFTS",
        "destinationId": "binsar",
        "description": "Hand-hammered traditional copper vessels and mountain cookware.",
        "ownerName": "Harish Tamta",
        "contactPhone": "+91 98765 99999",
        "contactEmail": "harish.copper@pahadipulse.in",
        "locationAddress": "Tamta Mohalla, Binsar Valley",
        "latitude": 29.701,
        "longitude": 79.742,
        "priceStartingINR": 1200.0,
        "pricingUnit": "per copper pitcher",
        "verified": True,
        "externalBookingUrl": "https://pahadipulse.in/demo-providers/prov_test_artisan_99",
        "rating": 4.9,
        "reviewCount": 15,
        "isDemo": True
    }

    create_res = client.post("/api/providers", json=new_provider, headers=admin_headers)
    assert create_res.status_code == 201
    created_data = create_res.json()
    assert created_data["id"] == "prov_test_artisan_99"
    assert created_data["name"] == new_provider["name"]

    # 2. Verify it shows up in GET /api/providers/{id}
    get_res = client.get("/api/providers/prov_test_artisan_99")
    assert get_res.status_code == 200
    assert get_res.json()["name"] == "Kumaoni Copper Artisan Guild"

    # 3. Update the provider as admin
    update_payload = {
        "priceStartingINR": 1350.0,
        "description": "Updated description with master artisan hallmark."
    }
    patch_res = client.patch("/api/providers/prov_test_artisan_99", json=update_payload, headers=admin_headers)
    assert patch_res.status_code == 200
    assert patch_res.json()["priceStartingINR"] == 1350.0
    assert "hallmark" in patch_res.json()["description"]

    # 4. Delete the provider as admin
    del_res = client.delete("/api/providers/prov_test_artisan_99", headers=admin_headers)
    assert del_res.status_code == 200
    assert del_res.json()["id"] == "prov_test_artisan_99"

    # 5. Confirm deletion
    get_deleted = client.get("/api/providers/prov_test_artisan_99")
    assert get_deleted.status_code == 404
