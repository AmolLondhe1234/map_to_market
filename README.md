# MAP2MARKET – AI-Driven Business Feasibility System

[![Firebase Ready](https://img.shields.io/badge/Firebase-Ready-orange?style=flat-square)](https://firebase.google.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue?style=flat-square)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.8+-green?style=flat-square)](https://python.org)
[![License](https://img.shields.io/badge/License-MIT-purple?style=flat-square)](#)

A comprehensive full-stack solution for predicting business success using AI, geospatial data, demographic insights, and competitor analysis.

## 🚀 Quick Start

```bash
# 1. Run setup (choose your OS)
./setup.sh              # macOS/Linux
setup.bat               # Windows
.\setup.ps1             # PowerShell

# 2. Start backend
cd backend && python main.py

# 3. Run app
flutter run
```

👉 **New to the project?** Start with [GETTING_STARTED.md](GETTING_STARTED.md)

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Running the App](#running-the-app)
- [API Documentation](#api-documentation)
- [Configuration](#configuration)
- [Development](#development)
- [Deployment](#deployment)
- [Documentation](#documentation)
- [Support](#support)

## ✨ Features

### 🔐 Authentication
- Email/password registration and login
- Firebase Authentication integration
- Session management
- Password reset functionality

### 📊 Business Analytics
- AI-powered business feasibility prediction
- Success probability scoring
- Risk level assessment
- Competitor analysis
- Demographic insights

### 🗺️ Geospatial Features
- Interactive Google Maps integration
- Location-based predictions
- Nearby services discovery
- Heat map visualization

### 💾 Data Management
- Firestore real-time database
- Cloud storage integration
- Prediction history tracking
- User preferences storage

### 📱 Multi-Platform Support
- Android native app
- iOS native app
- Web application
- Linux/Windows desktop

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Frontend                    │
│  (Android, iOS, Web, Linux, Windows)                │
└──────────────────────┬──────────────────────────────┘
                       │
      ┌────────────────┼────────────────┐
      │                │                │
      ▼                ▼                ▼
┌──────────┐    ┌──────────┐    ┌──────────────┐
│ Firebase │    │ FastAPI  │    │ ML Models    │
│ (Auth)   │    │ Backend  │    │ (RF, XGBoost)│
└──────────┘    └────┬─────┘    └──────────────┘
                     │
      ┌──────────────┴──────────────┐
      ▼                             ▼
┌──────────────┐           ┌──────────────────┐
│ SQLite/      │           │ PostGIS Database │
│ PostgreSQL   │           │ (Spatial Data)   │
└──────────────┘           └──────────────────┘
```

## 📂 Project Structure

```
map_to_market/
├── lib/                              # Flutter app (Dart)
│   ├── main.dart                     # Entry point
│   ├── firebase_options.dart         # Firebase configuration
│   └── services/                     # Business logic
│       ├── firebase_auth_service.dart
│       └── firestore_service.dart
│
├── android/                          # Android native code
│   └── app/
│       └── google-services.json      # Firebase config
│
├── ios/                              # iOS native code
│   └── Runner/
│       └── GoogleService-Info.plist  # Firebase config
│
├── backend/                          # Python FastAPI backend
│   ├── main.py                       # API server
│   ├── requirements.txt              # Dependencies
│   └── test_api.py                   # API tests
│
├── ml_model/                         # ML pipeline
│   ├── train.py                      # Model training
│   ├── featurizer.py                 # Feature engineering
│   └── data_generator.py             # Synthetic data
│
├── data_pipeline/                    # Data processing
│   └── osm_fetcher.py                # OpenStreetMap data
│
├── database/                         # DB schema
│   └── schema.sql                    # PostGIS schema
│
├── data/                             # Sample datasets
│   ├── business_data.csv
│   └── osm_enriched_business_data.csv
│
├── models/                           # Trained ML models
│   ├── business_model.pkl
│   └── feature_names.pkl
│
├── pubspec.yaml                      # Flutter dependencies
├── .env                              # Environment config
├── setup.sh / setup.bat / setup.ps1  # Setup scripts
└── DOCUMENTATION
    ├── GETTING_STARTED.md
    ├── QUICK_START.md
    ├── FIREBASE_SETUP.md
    ├── FIREBASE_INTEGRATION.md
    └── PROJECT_STATUS.md
```

## 🔧 Setup & Installation

### Prerequisites
- **Flutter 3.10+** - Install from https://flutter.dev
- **Python 3.8+** - Install from https://python.org
- **Git** - For version control
- **Android Studio** or **Xcode** - For native development
- **VS Code** or **IntelliJ IDEA** - Code editor

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd map_to_market
```

### Step 2: Run Setup Script
Choose based on your operating system:

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**Windows (Command Prompt):**
```cmd
setup.bat
```

This will:
- ✅ Install all Flutter dependencies
- ✅ Install all Python dependencies  
- ✅ Verify Firebase configuration
- ✅ Run code analysis
- ✅ Validate setup

### Step 3: Verify Installation
```bash
flutter doctor
flutter pub get
python --version
```

For detailed setup instructions, see [GETTING_STARTED.md](GETTING_STARTED.md)

## 🚀 Running the App

### Frontend (Flutter)

```bash
# Simply run
flutter run

# Then choose:
# - Press 'a' for Android Emulator
# - Press 'i' for iOS Simulator (macOS)
# - Press 'w' for Web
# - Press 'd' for Physical Device
```

### Backend (FastAPI)

In a separate terminal:
```bash
cd backend
python main.py
```

Backend runs on: `http://localhost:8000`

### Development Commands

```bash
# Hot reload (update code)
# Press 'r' in terminal

# Hot restart (full reload)
# Press 'R' in terminal

# View logs
# Press 'l' in terminal

# Quit
# Press 'q' in terminal
```

## 📡 API Documentation

### Base URL
```
http://localhost:8000
```

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe"
}
```

#### Login User
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Prediction Endpoints

#### Get Business Prediction
```http
POST /predict-location
Content-Type: application/json

{
  "category": "Cafe",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "population_density": 5000,
  "avg_income": 50000
}
```

#### Get Prediction History
```http
GET /prediction-history
Authorization: Bearer <token>
```

### Service Endpoints

#### Find Nearby Services
```http
GET /nearby-services?lat=18.5204&lng=73.8567&radius=1000
```

#### Discovery Insights
```http
GET /discovery/insights?category=Cafe
```

### System Endpoints

#### Health Check
```http
GET /health
```

#### API Status
```http
GET /status
```

For full API documentation, visit: `http://localhost:8000/docs` (Swagger UI)

## ⚙️ Configuration

### Environment Variables

Create or edit `.env` file:

```env
# Backend
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
BACKEND_DEBUG=true

# Database
DATABASE_URL=sqlite:///./map2market.db
# For PostgreSQL: DATABASE_URL=postgresql://user:password@localhost/map2market

# Security
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60

# Firebase
FIREBASE_PROJECT_ID=map-to-market
FIREBASE_API_KEY=AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM
FIREBASE_STORAGE_BUCKET=map-to-market.firebasestorage.app

# ML Model
MODEL_PATH=./models/business_model.pkl
FEATURES_PATH=./models/feature_names.pkl

# Logging
LOG_LEVEL=DEBUG
LOG_FILE=./logs/map2market.log

# App Settings
APP_NAME=Map2Market
TIMEZONE=Asia/Kolkata
```

### Firebase Configuration

Firebase is pre-configured! No additional setup needed.

**Firebase Project Details:**
- Project ID: `map-to-market`
- Project Number: `393628478650`
- Storage Bucket: `map-to-market.firebasestorage.app`

Access Firebase Console: https://console.firebase.google.com

For detailed Firebase setup, see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

## 💻 Development

### Code Structure

**Flutter (Dart):**
```dart
// Services for business logic
lib/
├── services/
│   ├── firebase_auth_service.dart    # Authentication
│   └── firestore_service.dart        # Database
└── main.dart                          # App entry
```

**Backend (Python):**
```python
# FastAPI endpoints
backend/
├── main.py                            # API routes
└── requirements.txt                   # Dependencies
```

**ML Models:**
```python
# Model training pipeline
ml_model/
├── train.py                           # Training script
├── featurizer.py                      # Feature engineering
└── data_generator.py                  # Data generation
```

### Code Quality

Check code quality:
```bash
flutter analyze
flutter format lib/
```

Run tests:
```bash
flutter test
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes and commit
git add .
git commit -m "Add your feature"

# Push and create PR
git push origin feature/your-feature
```

## 🚢 Deployment

### Build for Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/`

### Build for iOS

```bash
flutter build ios --release
```

Then open in Xcode and follow app signing steps.

### Build for Web

```bash
flutter build web --release
```

Output: `build/web/`

### Deploy Backend

```bash
# Using Gunicorn
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 backend.main:app

# Using Docker
docker build -t map2market-backend .
docker run -p 8000:8000 map2market-backend
```

## 📚 Documentation

- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete setup guide for all platforms
- **[QUICK_START.md](QUICK_START.md)** - 5-minute quick start
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Firebase configuration and setup
- **[FIREBASE_INTEGRATION.md](FIREBASE_INTEGRATION.md)** - Firebase integration details
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - Current project status

## 🆘 Support

### Troubleshooting

**Issue: Flutter command not found**
```bash
# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"
```

**Issue: No devices available**
```bash
flutter devices
emulator -avd <emulator-name>  # Start Android emulator
```

**Issue: Pod installation failed (iOS)**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**Issue: Backend connection refused**
```bash
# Make sure backend is running
cd backend
python main.py
```

### Getting Help

1. Check [GETTING_STARTED.md](GETTING_STARTED.md)
2. Review [PROJECT_STATUS.md](PROJECT_STATUS.md)
3. Check logs with `flutter run -v`
4. Run `flutter doctor` to diagnose issues
5. Check Firebase Console for authentication issues

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👥 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 🎯 Roadmap

- [ ] Push notifications
- [ ] Offline mode
- [ ] Advanced analytics
- [ ] AR visualization
- [ ] Multi-language support
- [ ] Export reports

## 📞 Contact

For questions or support, please reach out to the development team.

---

**Status: ✅ Production Ready**

Last Updated: March 10, 2026

### 3. Mobile App
- Open `/android_app` in Android Studio.
- Add your Google Maps API Key in `AndroidManifest.xml`.
- Update the `baseUrl` in `MainActivity.kt` to point to your backend.

### 4. Database
- Setup PostgreSQL with PostGIS.
- Run the schema in `/database/schema.sql`.

## Key Features
- **Success Prediction**: Predicts probability of business success using supervised learning.
- **Location Recommendation**: Suggests alternative high-potential zones if initial feasibility is low.
- **Service Discovery**: Real-time nearby service search for customers.
- **Heatmap Visualization**: (To be implemented in Android using Maps SDK utilities).

## API Endpoints
- `POST /predict-location`: Core feasibility engine.
- `GET /nearby-services`: Location-based discovery.
- `POST /login`: Mock authentication.
