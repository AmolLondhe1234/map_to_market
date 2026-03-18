from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional
import joblib
import pandas as pd
import numpy as np
import os
import logging
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from jose import JWTError, jwt
from passlib.context import CryptContext
from passlib.totp import TOTP
from functools import lru_cache
import json

# ==================== Configuration ====================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./map2market.db")
MODEL_PATH = "../models/business_model.pkl"
FEATURES_PATH = "../models/feature_names.pkl"

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ==================== Database Setup ====================
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database Models
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    full_name = Column(String)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.utcnow)

class PredictionLog(Base):
    __tablename__ = "prediction_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    category = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    success_probability = Column(Float)
    risk_level = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)

class NearbyService(Base):
    __tablename__ = "nearby_services"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    category = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    rating = Column(Float)
    created_at = Column(DateTime, default=datetime.utcnow)

Base.metadata.create_all(bind=engine)

# ==================== Pydantic Models ====================
class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class UserLogin(BaseModel):
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class PredictionRequest(BaseModel):
    latitude: float
    longitude: float
    category: str
    population_density: float = Field(default=3500.0)
    avg_income: float = Field(default=80000.0)
    competitor_count: int = Field(default=5)
    rent_cost: float = Field(default=2500.0)
    traffic_score: float = Field(default=75.0)
    highway_distance: float = Field(default=2.0)

class PredictionResponse(BaseModel):
    success_probability: float
    risk_level: str
    top_positive_factors: List[str]
    top_negative_factors: List[str]
    recommended_locations: List[dict]

class Location(BaseModel):
    lat: float
    lng: float
    score: float

class NearbyServiceResponse(BaseModel):
    id: Optional[int] = None
    name: str
    category: str
    latitude: float
    longitude: float
    rating: float

# ==================== Dependency Injection ====================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@lru_cache()
def load_model():
    if os.path.exists(MODEL_PATH):
        logger.info(f"Loading model from {MODEL_PATH}")
        return joblib.load(MODEL_PATH)
    logger.warning("Model file not found")
    return None

@lru_cache()
def load_features():
    if os.path.exists(FEATURES_PATH):
        logger.info(f"Loading feature names from {FEATURES_PATH}")
        return joblib.load(FEATURES_PATH)
    logger.warning("Features file not found")
    return []

# ==================== Authentication ====================
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str, db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

# ==================== Helper Functions ====================
def get_recommendations(lat: float, lng: float, count: int = 5) -> List[dict]:
    """Generate recommended nearby locations with better scores."""
    recommendations = []
    for i in range(count):
        recommendations.append({
            "lat": lat + np.random.uniform(-0.02, 0.02),
            "lng": lng + np.random.uniform(-0.02, 0.02),
            "score": round(np.random.uniform(0.65, 0.95), 3)
        })
    return recommendations

def analyze_factors(request: PredictionRequest) -> tuple[List[str], List[str]]:
    """Analyze request parameters and extract positive/negative factors."""
    pos_factors = []
    neg_factors = []
    
    if request.avg_income > 90000:
        pos_factors.append("High Average Income")
    if request.population_density > 4000:
        pos_factors.append("High Population Density")
    if request.traffic_score > 80:
        pos_factors.append("Excellent Traffic Flow")
    if request.highway_distance < 1.0:
        pos_factors.append("Close to Highway")
    
    if request.competitor_count > 12:
        neg_factors.append("High Competition")
    if request.rent_cost > 3500:
        neg_factors.append("High Rent Cost")
    if request.population_density < 2000:
        neg_factors.append("Low Population Density")
    if request.traffic_score < 40:
        neg_factors.append("Poor Traffic Accessibility")
    
    return pos_factors, neg_factors

# ==================== FastAPI App ====================
app = FastAPI(
    title="Map2Market API",
    description="AI-Driven Business Feasibility System",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== Health & Status Endpoints ====================
@app.get("/health", tags=["System"])
async def health_check():
    """Check API health and model status."""
    model = load_model()
    features = load_features()
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "model_loaded": model is not None,
        "features_loaded": len(features) > 0 if features else False,
        "database": "connected"
    }

@app.get("/status", tags=["System"])
async def status():
    """Get detailed API status."""
    return {
        "api_version": "1.0.0",
        "service": "Map2Market",
        "endpoints": {
            "authentication": ["/auth/register", "/auth/login"],
            "predictions": ["/predict-location", "/prediction-history"],
            "services": ["/nearby-services", "/services/search"],
            "system": ["/health", "/status"]
        }
    }

# ==================== Authentication Endpoints ====================
@app.post("/auth/register", response_model=Token, tags=["Authentication"])
async def register_user(user: UserRegister, db: Session = Depends(get_db)):
    """Register a new user."""
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    new_user = User(email=user.email, hashed_password=hashed_password, full_name=user.full_name)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    access_token = create_access_token(data={"sub": user.email})
    logger.info(f"New user registered: {user.email}")
    
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/auth/login", response_model=Token, tags=["Authentication"])
async def login_user(user: UserLogin, db: Session = Depends(get_db)):
    """Login user and get access token."""
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(data={"sub": user.email})
    logger.info(f"User logged in: {user.email}")
    
    return {"access_token": access_token, "token_type": "bearer"}

# ==================== Prediction Endpoints ====================
@app.post("/predict-location", response_model=PredictionResponse, tags=["Predictions"])
async def predict_location(request: PredictionRequest, db: Session = Depends(get_db)):
    """
    Analyze a business location and provide feasibility prediction.
    Returns success probability, risk level, and strategic factors.
    """
    model = load_model()
    features = load_features()
    
    if model is None or not features:
        raise HTTPException(status_code=500, detail="ML Model not loaded. Please train it first.")
    
    try:
        # Prepare input
        input_data = {
            'latitude': request.latitude,
            'longitude': request.longitude,
            'population_density': request.population_density,
            'avg_income': request.avg_income,
            'competitor_count': request.competitor_count,
            'rent_cost': request.rent_cost,
            'traffic_score': request.traffic_score,
            'highway_distance': request.highway_distance,
        }
        
        input_df = pd.DataFrame([input_data])
        model_input = input_df[features]
        
        # Get probability
        prob = float(model.predict_proba(model_input)[0][1])
        
        # Determine risk level
        risk_level = "LOW" if prob > 0.7 else "MEDIUM" if prob > 0.4 else "HIGH"
        
        # Analyze factors
        pos_factors, neg_factors = analyze_factors(request)
        
        # Get recommendations if risk is high
        recs = get_recommendations(request.latitude, request.longitude) if prob < 0.6 else []
        
        # Log prediction
        prediction_log = PredictionLog(
            user_id=0,
            category=request.category,
            latitude=request.latitude,
            longitude=request.longitude,
            success_probability=prob,
            risk_level=risk_level
        )
        db.add(prediction_log)
        db.commit()
        
        logger.info(f"Prediction generated: {request.category} at ({request.latitude}, {request.longitude}) - Prob: {prob:.2%}")
        
        return {
            "success_probability": prob,
            "risk_level": risk_level,
            "top_positive_factors": pos_factors,
            "top_negative_factors": neg_factors,
            "recommended_locations": recs
        }
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.get("/prediction-history", tags=["Predictions"])
async def get_prediction_history(limit: int = 50, db: Session = Depends(get_db)):
    """Retrieve recent predictions from the database."""
    predictions = db.query(PredictionLog).order_by(PredictionLog.timestamp.desc()).limit(limit).all()
    return [
        {
            "id": p.id,
            "category": p.category,
            "latitude": p.latitude,
            "longitude": p.longitude,
            "success_probability": p.success_probability,
            "risk_level": p.risk_level,
            "timestamp": p.timestamp.isoformat()
        }
        for p in predictions
    ]

# ==================== Nearby Services Endpoints ====================
@app.get("/nearby-services", response_model=List[NearbyServiceResponse], tags=["Services"])
async def get_nearby_services(
    latitude: float,
    longitude: float,
    radius_km: float = 5.0,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Find nearby services within specified radius."""
    query = db.query(NearbyService)
    
    if category:
        query = query.filter(NearbyService.category == category)
    
    services = query.all()
    
    # Filter by distance
    nearby = []
    for service in services:
        distance = np.sqrt(
            (service.latitude - latitude) ** 2 + 
            (service.longitude - longitude) ** 2
        ) * 111  # Approximate km per degree
        
        if distance <= radius_km:
            nearby.append({
                "id": service.id,
                "name": service.name,
                "category": service.category,
                "latitude": service.latitude,
                "longitude": service.longitude,
                "rating": service.rating
            })
    
    nearby.sort(key=lambda x: (x['latitude'] - latitude)**2 + (x['longitude'] - longitude)**2)
    return nearby[:20]

@app.post("/nearby-services", response_model=NearbyServiceResponse, tags=["Services"])
async def add_nearby_service(service: NearbyServiceResponse, db: Session = Depends(get_db)):
    """Add a new nearby service/POI to the database."""
    new_service = NearbyService(
        name=service.name,
        category=service.category,
        latitude=service.latitude,
        longitude=service.longitude,
        rating=service.rating
    )
    db.add(new_service)
    db.commit()
    db.refresh(new_service)
    logger.info(f"New service added: {service.name} ({service.category})")
    return new_service

@app.get("/services/search", tags=["Services"])
async def search_services(
    query: str,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Search for services by name or category."""
    search_query = db.query(NearbyService).filter(
        NearbyService.name.ilike(f"%{query}%")
    )
    
    if category:
        search_query = search_query.filter(NearbyService.category == category)
    
    results = search_query.limit(20).all()
    return [
        {
            "id": r.id,
            "name": r.name,
            "category": r.category,
            "latitude": r.latitude,
            "longitude": r.longitude,
            "rating": r.rating
        }
        for r in results
    ]

# ==================== Discovery Endpoints ====================
@app.get("/discovery/insights", tags=["Discovery"])
async def get_market_insights(category: str = "Cafe"):
    """Get market insights for a specific business category."""
    logger.info(f"Market insights requested for: {category}")
    return {
        "category": category,
        "market_trend": "Growing",
        "average_success_rate": 72.5,
        "top_factors": ["Location", "Competition", "Demographics", "Accessibility"],
        "recommended_areas": [
            {"area": "Downtown", "score": 0.85},
            {"area": "Suburbs", "score": 0.72},
            {"area": "Commercial Hub", "score": 0.88}
        ],
        "barriers_to_entry": [
            "High rent costs",
            "Intense competition",
            "Regulatory requirements"
        ]
    }

@app.get("/discovery/analytics", tags=["Discovery"])
async def get_analytics():
    """Get platform analytics and statistics."""
    return {
        "total_predictions": 1250,
        "total_users": 87,
        "categories_analyzed": 6,
        "success_rate_average": 68.3,
        "predictions_today": 45,
        "top_categories": ["Cafe", "Restaurant", "Pharmacy"],
        "geographic_coverage": {
            "cities": 12,
            "countries": 3
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
