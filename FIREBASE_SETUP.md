# Firebase Integration Guide for Map2Market

## Configuration Summary

This project is integrated with Firebase for:
- **Authentication**: Email/password login via Firebase Auth
- **Firestore Database**: Store user predictions and preferences  
- **Cloud Storage**: Store user data and predictions
- **Analytics**: Track user behavior and app usage
- **Messaging**: Cloud messaging for notifications
- **Project ID**: `map-to-market`
- **API Key**: `AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM`
- **Storage Bucket**: `map-to-market.firebasestorage.app`

## Setup Instructions

### 1. Android Setup
- ✅ `google-services.json` is configured in `android/app/`
- ✅ Firebase Google Services plugin added to build.gradle
- ✅ Firebase dependencies added
- Nothing additional needed for Android

### 2. iOS Setup  
- ✅ `GoogleService-Info.plist` configured in `ios/Runner/`
- Run the following in iOS directory:
```bash
cd ios
pod install
cd ..
```

### 3. Flutter Setup
- ✅ Firebase packages added to `pubspec.yaml`
- ✅ Firebase initialized in `main.dart` 
- Generated `firebase_options.dart` for platform-specific config
- Run to fetch dependencies:
```bash
flutter pub get
```

### 4. Services Implemented

#### FirebaseAuthService (`lib/services/firebase_auth_service.dart`)
Methods available:
- `registerUser()` - Create new user account
- `loginUser()` - User login
- `logoutUser()` - User logout
- `getCurrentUser()` - Get current user
- `isUserLoggedIn()` - Check login status
- `resetPassword()` - Send password reset

Example usage:
```dart
final authService = FirebaseAuthService();
final user = await authService.loginUser(
  email: 'user@example.com',
  password: 'password123'
);
```

#### FirestoreService (`lib/services/firestore_service.dart`)
Methods available:
- `savePrediction()` - Store business predictions
- `getPredictionHistory()` - Retrieve user's predictions
- `saveUserPreferences()` - Store user settings
- `getUserPreferences()` - Get user preferences
- `saveNearbyService()` - Store nearby services

Example usage:
```dart
final firestoreService = FirestoreService();
await firestoreService.savePrediction(
  category: 'Cafe',
  latitude: 18.5204,
  longitude: 73.8567,
  successProbability: 0.85,
  riskLevel: 'LOW'
);
```

## Firestore Database Structure

```
users/
├── {userId}/
│   ├── email
│   ├── displayName
│   ├── preferences/
│   ├── predictions/
│   │   ├── {predictionId}
│   │   │   ├── category
│   │   │   ├── latitude
│   │   │   ├── longitude
│   │   │   ├── successProbability
│   │   │   ├── riskLevel
│   │   │   └── timestamp
│   └── nearby_services/
│       └── {serviceId}
│           ├── name
│           ├── type
│           ├── latitude
│           ├── longitude
│           ├── distance
│           └── savedAt
```

## Environment Variables

Add to `.env`:
```
FIREBASE_PROJECT_ID=map-to-market
FIREBASE_API_KEY=AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM
FIREBASE_STORAGE_BUCKET=map-to-market.firebasestorage.app
FIREBASE_AUTH_DOMAIN=map-to-market.firebaseapp.com
FIREBASE_MESSAGING_SENDER_ID=393628478650
```

## Next Steps

1. **Test Authentication**: Try registering and logging in
2. **Test Firestore**: Verify predictions are stored
3. **Enable Security Rules**: Set proper Firestore security rules in Firebase Console
4. **Configure Push Notifications**: Set up Apple certificates for iOS push notifications
5. **Analytics**: Monitor user engagement in Firebase Analytics Dashboard

## Troubleshooting

### Android Issues
- If build fails, run: `flutter clean && flutter pub get`
- Ensure `google-services.json` is in correct location

### iOS Issues  
- Run `pod install` if pods fail to load
- Clear build: `cd ios && rm -rf Pods Podfile.lock && pod install`

### Firebase Connection Issues
- Check Firebase Console project exists
- Verify API key is correct in `firebase_options.dart`
- Check network connectivity

## Security Considerations

- ⚠️ API Key is exposed in code (for development only)
- 🔒 For production: Use obfuscation or backend proxy
- 🔑 Set proper Firestore Security Rules
- 📱 Implement biometric authentication for sensitive operations
- 🛡️ Enable Firebase App Check

## Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /predictions/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /nearby_services/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

## Support & References

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Plugin](https://firebase.flutter.dev)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
