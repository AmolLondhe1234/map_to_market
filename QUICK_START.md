# QUICK START GUIDE - Map2Market

## 🚀 5-Minute Setup

### Step 1: Run Setup Script

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**Windows (Command Prompt):**
```cmd
setup.bat
```

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

### Step 2: Start the Backend (Optional but Recommended)

```bash
cd backend
python main.py
```

Backend will be available at: `http://localhost:8000`

### Step 3: Run the App

```bash
flutter run
```

Choose your device:
- **Android Emulator**: Press `a`
- **iOS Simulator**: Press `i` (macOS only)
- **Web**: Press `w`

---

## 📱 Platform-Specific Setup

### Android
```bash
# Emulator only
flutter run

# Build APK
flutter build apk --release

# Install on physical device
flutter run -d <device-id>
```

### iOS (macOS only)
```bash
# Simulator
flutter run -d ios

# Build app
flutter build ios --release

# Pod installation if needed
cd ios && pod install && cd ..
```

### Web
```bash
# Enable web (first time only)
flutter config --enable-web

# Run on web
flutter run -d chrome
```

---

## 🔍 Verify Installation

Check that everything is installed correctly:

```bash
# Flutter version
flutter --version

# Flutter doctor
flutter doctor

# Python version
python --version

# List devices
flutter devices
```

---

## 📂 Project Structure

```
map_to_market/
├── lib/                          # Flutter app code
│   ├── main.dart                 # Entry point
│   ├── firebase_options.dart     # Firebase config
│   └── services/                 # Service classes
├── android/                      # Android native code
├── ios/                          # iOS native code
├── backend/                      # Python FastAPI backend
├── data/                         # Sample data
├── ml_model/                     # ML model training
├── database/                     # Database schema
└── pubspec.yaml                  # Dependencies
```

---

## 🔐 Firebase Configuration

All Firebase configuration is already in place:
- ✅ Android: `android/app/google-services.json`
- ✅ iOS: `ios/Runner/GoogleService-Info.plist`
- ✅ Flutter: `lib/firebase_options.dart`

No additional setup needed!

---

## 🌐 API Endpoints

Backend runs on `http://localhost:8000`

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `GET /health` - API health check

### Predictions
- `POST /predict-location` - Get business prediction
- `GET /prediction-history` - Get user predictions

### Services
- `GET /nearby-services` - Find nearby services
- `POST /nearby-services` - Add new service

---

## 🐛 Troubleshooting

### Flutter not found
```bash
# Install Flutter
# Windows: https://flutter.dev/docs/get-started/install/windows
# macOS: https://flutter.dev/docs/get-started/install/macos
# Linux: https://flutter.dev/docs/get-started/install/linux
```

### Python not found
```bash
# Install Python 3.8+
# Download from: https://www.python.org/downloads/
```

### Android emulator not working
```bash
# Start Android emulator manually
emulator -avd <emulator-name>

# List available emulators
emulator -list-avds
```

### iOS pod issues
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Dependencies conflict
```bash
# Clean and reinstall
flutter clean
rm -rf pubspec.lock
flutter pub get
```

---

## 📊 Development Commands

```bash
# Run with verbose output
flutter run -v

# Hot reload (press r in terminal)
# Full restart (press R in terminal)
# Quit (press q in terminal)

# Run tests
flutter test

# Build APK
flutter build apk --release

# Generate app bundle (for Play Store)
flutter build appbundle

# View generated code
flutter pub get
```

---

## 📚 Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [Android Studio Setup](https://developer.android.com/studio)
- [Xcode Setup](https://developer.apple.com/xcode/)

---

## 🎯 Next Steps

1. **Test authentication** - Try registering and logging in
2. **Load sample data** - Check `/data` folder for CSV files
3. **Test predictions** - Use the app to make business predictions
4. **Check logs** - Look at backend output for API requests
5. **Explore Firestore** - View stored predictions in Firebase

---

## 📝 Notes

- Development uses SQLite database by default
- Backend can be configured to use PostgreSQL in `.env`
- Firebase is configured for authentication and real-time database
- ML models are pre-trained and located in `/models`
- Sample data is available in `/data` folder

---

## 💡 Tips

- Keep backend running in a separate terminal
- Use `flutter run` to test on device/emulator
- Check Flutter Doctor for any issues: `flutter doctor`
- Monitor backend logs while testing API
- Use Firebase Console to manage users and data

---

**Happy coding! 🎉**

For more details, see the comprehensive guides:
- `FIREBASE_SETUP.md` - Firebase configuration details
- `FIREBASE_INTEGRATION.md` - Integration overview
- `PROJECT_STATUS.md` - Project status and files
