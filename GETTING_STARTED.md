# GETTING STARTED - Map2Market

Welcome to Map2Market! This guide will help you get the project running on your machine.

## 📋 Prerequisites

Before you start, ensure you have:

- **macOS 10.15+**, **Windows 10+**, or **Ubuntu 20.04+**
- **Git** - Version control
- **Flutter 3.10+** - Mobile framework
- **Python 3.8+** - Backend runtime
- **Android Studio** or **Xcode** - Native development tools
- **VS Code** or **IntelliJ IDEA** - IDE (recommended)

---

## 1️⃣ Install Flutter

### macOS (Homebrew)
```bash
brew install flutter
```

### Windows
1. Download from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter`
3. Add to PATH:
   - Right-click "This PC" → Properties → Advanced system settings
   - Add `C:\flutter\bin` to PATH
4. Verify: `flutter --version`

### Linux
```bash
git clone https://github.com/flutter/flutter.git ~/flutter
export PATH="$HOME/flutter/bin:$PATH"
```

---

## 2️⃣ Install Python

### macOS (Homebrew)
```bash
brew install python@3.11
```

### Windows
1. Download from https://www.python.org/downloads/
2. ✅ **Check** "Add Python to PATH"
3. Install
4. Verify: `python --version`

### Linux
```bash
sudo apt-get install python3 python3-pip
```

---

## 3️⃣ Clone Project

```bash
git clone <repository-url>
cd map_to_market
```

---

## 4️⃣ Run Setup Script

Choose based on your OS:

**Windows PowerShell:**
```powershell
.\setup.ps1
```

**Windows Command Prompt:**
```cmd
setup.bat
```

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

✅ This will:
- Install Flutter dependencies
- Install Python dependencies
- Verify Firebase configuration
- Run code analysis

---

## 5️⃣ Set Up Android (Optional)

### Using Android Studio (Recommended)
1. Install Android Studio
2. Open `android/` folder in Android Studio
3. Wait for Gradle sync
4. Download SDK if prompted

### Manual Setup
```bash
# Download Android SDK
flutter config --android-sdk <path-to-android-sdk>

# Accept licenses
flutter doctor --android-licenses

# Verify setup
flutter doctor
```

---

## 6️⃣ Set Up iOS (macOS only)

```bash
# Install cocoapods
sudo gem install cocoapods

# Install iOS pods
cd ios
pod install
cd ..

# Verify
flutter doctor
```

---

## 7️⃣ Configure Environment

The `.env` file is already configured. For custom settings:

```bash
# Copy example if needed
cp .env.example .env

# Edit with your values
nano .env
```

**Key variables:**
```env
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
DATABASE_URL=sqlite:///./map2market.db
FIREBASE_PROJECT_ID=map-to-market
```

---

## 8️⃣ Start Development

### Terminal 1 - Backend API
```bash
cd backend
python main.py
```

Expected output:
```
INFO:     Started server process
INFO:     Application startup complete
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Terminal 2 - Flutter App
```bash
flutter run
```

Choose your device:
- **Android Emulator**: `a`
- **iOS Simulator**: `i` (macOS only)
- **Web**: `w`
- **Physical Device**: `d` (if connected)

---

## ✅ Verification Checklist

After setup, verify everything works:

```bash
# Check Flutter
flutter --version
flutter doctor

# Check Python
python --version
pip list | grep firebase

# Check Android
flutter devices

# Test backend
curl http://localhost:8000/health

# Test app build
flutter build apk --debug
```

---

## 🔑 Firebase Configuration

Firebase is pre-configured! No additional setup needed.

### Available Features:
- ✅ User authentication (email/password)
- ✅ Real-time database (Firestore)
- ✅ Cloud storage
- ✅ Analytics
- ✅ Cloud messaging

### Access Firebase Console:
1. Go to https://console.firebase.google.com
2. Select project: `map-to-market`
3. Login with your credentials

---

## 📱 Running on Devices

### Android Physical Device
```bash
# Enable USB Debugging on phone
# Connect phone via USB
flutter run
```

### iOS Device (macOS only)
```bash
# Connect via USB
# Trust the computer on your phone
flutter run -d
```

### Web Browser
```bash
flutter run -d chrome
```

---

## 🔧 Development Workflow

### Hot Reload (Update Code)
- Press `r` in terminal

### Hot Restart (Full Reload)
- Press `R` in terminal

### Quit App
- Press `q` in terminal

### View Logs
- Press `l` in terminal

---

## 🐛 Common Issues & Solutions

### "flutter: command not found"
```bash
# Add Flutter to PATH (macOS/Linux)
export PATH="$HOME/flutter/bin:$PATH"

# On Windows, add C:\flutter\bin to System PATH
```

### "No device found"
```bash
# List available devices
flutter devices

# Start Android emulator
emulator -avd <name>

# Or connect physical device with USB
```

### "FirebaseCore not initializing"
```bash
# Delete and reinstall
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### "Pod install failed"
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### "Backend connection refused"
```bash
# Make sure backend is running
cd backend
python main.py

# Check port 8000 is available
# Windows: netstat -ano | findstr :8000
# Mac/Linux: lsof -i :8000
```

---

## 📚 Project Structure Explained

```
map_to_market/
├── lib/                      # Flutter Dart code
│   ├── main.dart            # App entry point
│   ├── firebase_options.dart # Firebase config
│   └── services/            # Business logic
│
├── android/                 # Android-specific code
│   └── app/
│       └── google-services.json  # Firebase config
│
├── ios/                     # iOS-specific code
│   └── Runner/
│       └── GoogleService-Info.plist
│
├── backend/                 # Python FastAPI backend
│   ├── main.py             # API server
│   ├── requirements.txt     # Python dependencies
│   └── test_api.py         # API tests
│
├── ml_model/               # Machine learning
│   └── train.py            # Model training script
│
├── data/                   # Sample data
│   └── business_data.csv
│
├── models/                 # Trained models
│   ├── business_model.pkl
│   └── feature_names.pkl
│
├── pubspec.yaml            # Flutter dependencies
├── .env                    # Environment variables
└── setup.sh/setup.bat      # Quick setup scripts
```

---

## 🎯 First Steps After Setup

1. **Test Authentication**
   ```
   Click "Register" in app → Create account → Login
   ```

2. **View Sample Data**
   ```
   Check /data folder for CSV files with business data
   ```

3. **Make Predictions**
   ```
   Tap map location → Get business feasibility score
   ```

4. **Check Firestore**
   ```
   Go to Firebase Console → View saved predictions
   ```

5. **Monitor Backend**
   ```
   Watch backend terminal for API requests
   ```

---

## 🚀 Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS App (App Store)
```bash
flutter build ios --release
# Follow Xcode instructions for signing
```

---

## 📞 Getting Help

If you encounter issues:

1. **Check Flutter Doctor**
   ```bash
   flutter doctor -v
   ```

2. **Check Project Status**
   ```
   See PROJECT_STATUS.md
   ```

3. **Read Documentation**
   - FIREBASE_SETUP.md
   - QUICK_START.md
   - FIREBASE_INTEGRATION.md

4. **Clean and Rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   ```

5. **Check Logs**
   ```bash
   flutter run -v
   ```

---

## ✨ What's Next

After successful setup:
- ✅ Explore the codebase
- ✅ Try different features
- ✅ Make modifications  
- ✅ Run tests
- ✅ Build for production

---

**Congratulations! You're all set! 🎉**

Happy coding!
