import requests
import json
import os

def fetch_osm_data(lat, lng, radius_meters=2000, category="cafe"):
    """
    Fetches Points of Interest (POI) from OpenStreetMap using the Overpass API.
    """
    overpass_url = "http://overpass-api.de/api/interpreter"
    
    # Overpass QL query: find amenities near the coordinate
    overpass_query = f"""
    [out:json];
    (
      node["amenity"="{category}"](around:{radius_meters},{lat},{lng});
      node["shop"="{category}"](around:{radius_meters},{lat},{lng});
    );
    out body;
    """
    
    print(f"Fetching {category} data near {lat}, {lng}...")
    
    response = requests.get(overpass_url, params={'data': overpass_query})
    
    if response.status_code == 200:
        data = response.json()
        elements = data.get('elements', [])
        
        # Extract meaningful data
        pois = []
        for element in elements:
            pois.append({
                "id": element.get('id'),
                "lat": element.get('lat'),
                "lon": element.get('lon'),
                "name": element.get('tags', {}).get('name', "Unnamed"),
                "type": element.get('tags', {}).get('amenity') or element.get('tags', {}).get('shop')
            })
        
        os.makedirs('data_pipeline/output', exist_ok=True)
        with open(f'data_pipeline/output/osm_{category}_data.json', 'w') as f:
            json.dump(pois, f, indent=4)
            
        print(f"Successfully fetched {len(pois)} {category} POIs.")
        return pois
    else:
        print(f"Error fetching data: {response.status_code}")
        return []

if __name__ == "__main__":
    # Test with Pune, India coordinates
    fetch_osm_data(18.5204, 73.8567, radius_meters=3000, category="cafe")
