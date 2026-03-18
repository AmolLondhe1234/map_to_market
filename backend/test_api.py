import pytest
import json
import requests
from fastapi.testclient import TestClient

# For local testing without TestClient
BASE_URL = "http://localhost:8000"

def test_prediction_manual():
    """Manual testing of prediction endpoint."""
    url = f"{BASE_URL}/predict-location"
    
    payload = {
        "latitude": 18.5204,
        "longitude": 73.8567,
        "category": "Cafe",
        "population_density": 4500.0,
        "avg_income": 95000.0,
        "competitor_count": 2,
        "rent_cost": 3000.0,
        "traffic_score": 85.0,
        "highway_distance": 1.2
    }
    
    try:
        response = requests.post(url, json=payload, timeout=5)
        if response.status_code == 200:
            print("✓ API Success!")
            data = response.json()
            print(f"✓ Success Probability: {data.get('success_probability', 'N/A'):.2%}")
            print(f"✓ Risk Level: {data.get('risk_level', 'N/A')}")
            print(f"✓ Positive Factors: {data.get('top_positive_factors', [])}")
            print(f"✓ Negative Factors: {data.get('top_negative_factors', [])}")
            return True
        else:
            print(f"✗ API Error {response.status_code}: {response.text}")
            return False
    except Exception as e:
        print(f"✗ Connection Error: {e}")
        return False

def test_health():
    """Test health endpoint."""
    url = f"{BASE_URL}/health"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Health: {data.get('status')}")
            print(f"✓ Model Loaded: {data.get('model_loaded')}")
            print(f"✓ Database: {data.get('database')}")
            return True
        else:
            print(f"✗ Health Check Failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Health Check Error: {e}")
        return False

def test_nearby_services():
    """Test nearby services endpoint."""
    url = f"{BASE_URL}/nearby-services"
    params = {
        "latitude": 18.5204,
        "longitude": 73.8567,
        "radius_km": 5.0
    }
    
    try:
        response = requests.get(url, params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Found {len(data)} nearby services")
            return True
        else:
            print(f"✗ Error: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def test_market_insights():
    """Test market insights endpoint."""
    url = f"{BASE_URL}/discovery/insights"
    params = {"category": "Cafe"}
    
    try:
        response = requests.get(url, params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Market Trend: {data.get('market_trend')}")
            print(f"✓ Avg Success Rate: {data.get('average_success_rate')}%")
            print(f"✓ Top Factors: {data.get('top_factors', [])}")
            return True
        else:
            print(f"✗ Error: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def test_analytics():
    """Test analytics endpoint."""
    url = f"{BASE_URL}/discovery/analytics"
    
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Total Predictions: {data.get('total_predictions')}")
            print(f"✓ Total Users: {data.get('total_users')}")
            print(f"✓ Avg Success Rate: {data.get('success_rate_average')}%")
            return True
        else:
            print(f"✗ Error: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def run_all_tests():
    """Run all API tests."""
    print("\n" + "="*60)
    print("MAP2MARKET API TEST SUITE")
    print("="*60 + "\n")
    
    tests = [
        ("Health Check", test_health),
        ("Prediction", test_prediction_manual),
        ("Nearby Services", test_nearby_services),
        ("Market Insights", test_market_insights),
        ("Analytics", test_analytics),
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n[Testing: {test_name}]")
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"✗ Test Error: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    passed = sum(1 for _, result in results if result)
    total = len(results)
    print(f"Passed: {passed}/{total}")
    
    for test_name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"  {status}: {test_name}")
    
    print("="*60 + "\n")
    return passed == total

if __name__ == "__main__":
    import sys
    success = run_all_tests()
    sys.exit(0 if success else 1)
