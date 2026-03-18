-- MAP2MARKET PostGIS Database Schema

-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Businesses Table
CREATE TABLE businesses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    location GEOGRAPHY(POINT, 4326),
    rating DECIMAL(2,1),
    price_level INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Demographics Table
CREATE TABLE demographics (
    id SERIAL PRIMARY KEY,
    zone_name VARCHAR(255),
    boundary GEOMETRY(POLYGON, 4326),
    population_density FLOAT,
    avg_income FLOAT,
    commercial_score FLOAT
);

-- Search History / Prediction Logs
CREATE TABLE prediction_logs (
    id SERIAL PRIMARY KEY,
    user_id INT,
    category VARCHAR(100),
    lat FLOAT,
    lng FLOAT,
    success_probability FLOAT,
    risk_level VARCHAR(20),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create spatial index
CREATE INDEX idx_businesses_location ON businesses USING GIST (location);
CREATE INDEX idx_demographics_boundary ON demographics USING GIST (boundary);

-- Example Insert
-- INSERT INTO businesses (name, category, location) VALUES ('Sample Cafe', 'Cafe', ST_MakePoint(73.8567, 18.5204)::geography);
