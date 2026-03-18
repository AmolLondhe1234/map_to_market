import pandas as pd
import numpy as np
import os

def generate_sample_data(num_samples=1000):
    np.random.seed(42)
    
    # Generic categories
    categories = ['Cafe', 'Grocery', 'Pharmacy', 'Gym', 'Restaurant']
    
    data = {
        'latitude': np.random.uniform(18.4, 18.6, num_samples),
        'longitude': np.random.uniform(73.7, 73.9, num_samples),
        'population_density': np.random.uniform(500, 5000, num_samples),
        'avg_income': np.random.uniform(30000, 150000, num_samples),
        'competitor_count': np.random.randint(0, 15, num_samples),
        'rent_cost': np.random.uniform(500, 5000, num_samples),
        'traffic_score': np.random.uniform(0, 100, num_samples),
        'highway_distance': np.random.uniform(0.1, 10, num_samples),
    }
    
    df = pd.DataFrame(data)
    
    # Simple logic for success probability
    # Success ~ income + density + traffic - competitors - rent - highway_dist
    success_score = (
        0.3 * (df['avg_income'] / 150000) +
        0.2 * (df['population_density'] / 5000) +
        0.2 * (df['traffic_score'] / 100) -
        0.15 * (df['competitor_count'] / 15) -
        0.1 * (df['rent_cost'] / 5000) -
        0.05 * (df['highway_distance'] / 10)
    )
    
    # Normalize and add noise
    success_score = (success_score - success_score.min()) / (success_score.max() - success_score.min())
    success_score += np.random.normal(0, 0.05, num_samples)
    df['success_target'] = np.where(success_score > 0.6, 1, 0)
    
    os.makedirs('data', exist_ok=True)
    df.to_csv('data/business_data.csv', index=False)
    print("Sample dataset generated at data/business_data.csv")

if __name__ == "__main__":
    generate_sample_data()
