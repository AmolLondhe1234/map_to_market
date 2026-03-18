import pandas as pd
import numpy as np
import json
import os
import warnings
from sklearn.preprocessing import StandardScaler, RobustScaler, MinMaxScaler
from sklearn.feature_selection import mutual_info_classif
import logging

warnings.filterwarnings('ignore')
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def fetch_osm_data_safe(lat, lng, radius_meters=1500, category='cafe'):
    """Safely fetch OSM data with fallback."""
    try:
        from osm_fetcher import fetch_osm_data
        return fetch_osm_data(lat, lng, radius_meters, category)
    except Exception as e:
        logger.warning(f"OSM fetch failed: {e}. Using synthetic data.")
        return []

def normalize_features(df, scaler_type='robust'):
    """Normalize/standardize features."""
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    df_normalized = df.copy()
    
    if scaler_type == 'standard':
        scaler = StandardScaler()
    elif scaler_type == 'minmax':
        scaler = MinMaxScaler()
    else:  # robust
        scaler = RobustScaler()
    
    df_normalized[numeric_cols] = scaler.fit_transform(df[numeric_cols])
    return df_normalized, scaler

def engineer_features(df):
    """Create new derived features for better model performance."""
    df_engineered = df.copy()
    
    # Create interaction features
    df_engineered['income_density_ratio'] = df['avg_income'] / (df['population_density'] + 1)
    df_engineered['competitor_density'] = df['competitor_count'] / (df['population_density'] + 1)
    df_engineered['rent_income_ratio'] = df['rent_cost'] / (df['avg_income'] + 1)
    
    # Create polynomial features
    df_engineered['traffic_score_squared'] = df['traffic_score'] ** 2
    df_engineered['density_income_product'] = (df['population_density'] * df['avg_income']) / 100000
    
    # Create binned features
    df_engineered['income_level'] = pd.cut(df['avg_income'], bins=3, labels=['low', 'medium', 'high'])
    df_engineered['density_level'] = pd.cut(df['population_density'], bins=3, labels=['low', 'medium', 'high'])
    
    # Distance-based features
    df_engineered['highway_accessibility'] = 1 / (df['highway_distance'] + 0.1)
    
    logger.info(f"Engineered {len(df_engineered.columns) - len(df.columns)} new features")
    return df_engineered

def validate_features(df):
    """Validate data quality and remove outliers."""
    df_validated = df.copy()
    initial_len = len(df_validated)
    
    # Remove rows with missing values
    df_validated = df_validated.dropna()
    
    # Remove outliers using IQR method
    numeric_cols = df_validated.select_dtypes(include=[np.number]).columns
    for col in numeric_cols:
        if col != 'success_target':
            Q1 = df_validated[col].quantile(0.25)
            Q3 = df_validated[col].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 3 * IQR
            upper_bound = Q3 + 3 * IQR
            df_validated = df_validated[
                (df_validated[col] >= lower_bound) & (df_validated[col] <= upper_bound)
            ]
    
    removed = initial_len - len(df_validated)
    if removed > 0:
        logger.info(f"Removed {removed} rows with outliers")
    
    return df_validated

def generate_training_set_from_osm(num_points=100, use_synthetic=True):
    """
    Combines real OSM competitor data with synthetic demographic data 
    to create a high-quality training set with engineered features.
    """
    base_lat, base_lng = 18.5204, 73.8567
    records = []
    categories = ['cafe', 'restaurant', 'pharmacy', 'gym', 'supermarket', 'retail']
    
    logger.info(f"Generating features for {num_points} locations...")
    
    for i in range(num_points):
        lat = base_lat + np.random.uniform(-0.08, 0.08)
        lng = base_lng + np.random.uniform(-0.08, 0.08)
        cat = np.random.choice(categories)
        
        # Feature 1: Competitor count (from OSM if available)
        if use_synthetic:
            competitor_count = np.random.randint(0, 20)
        else:
            pois = fetch_osm_data_safe(lat, lng, radius_meters=1500, category=cat)
            competitor_count = len(pois)
        
        # Feature 2-4: Synthetic demographics
        dist_from_center = np.sqrt((lat - base_lat) ** 2 + (lng - base_lng) ** 2)
        pop_density = max(300, 5500 * np.exp(-2 * dist_from_center))
        avg_income = max(15000, 130000 * np.exp(-1.5 * dist_from_center))
        
        # Feature 5-8: Location characteristics
        traffic_score = np.clip(np.random.normal(60, 20), 10, 100)
        rent_cost = (pop_density * 0.4) + (avg_income * 0.015) + np.random.normal(0, 200)
        highway_dist = np.random.uniform(0.05, 8.0)
        
        # Label generation
        success_score = (
            (avg_income / 130000) * 0.3 +
            (pop_density / 5500) * 0.25 +
            (traffic_score / 100) * 0.2 -
            (competitor_count / 20) * 0.15 -
            (rent_cost / 5000) * 0.1
        )
        success_score = np.clip(success_score + np.random.normal(0, 0.08), 0, 1)
        target = 1 if success_score > 0.45 else 0
        
        records.append({
            'latitude': lat,
            'longitude': lng,
            'population_density': pop_density,
            'avg_income': avg_income,
            'competitor_count': competitor_count,
            'rent_cost': rent_cost,
            'traffic_score': traffic_score,
            'highway_distance': highway_dist,
            'success_target': target
        })
    
    df = pd.DataFrame(records)
    logger.info(f"Generated {len(df)} training samples")
    
    # Validate and engineer features
    df = validate_features(df)
    df = engineer_features(df)
    
    # Save datasets
    os.makedirs('data', exist_ok=True)
    df.to_csv('data/osm_enriched_business_data.csv', index=False)
    logger.info("Enhanced dataset saved to data/osm_enriched_business_data.csv")
    
    return df

if __name__ == "__main__":
    df = generate_training_set_from_osm(num_points=200, use_synthetic=True)
    print(df.head())
    print(f"Dataset shape: {df.shape}")
    print(f"Target distribution:\n{df['success_target'].value_counts()}")
