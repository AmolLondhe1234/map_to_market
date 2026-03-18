class AppConfig {
  // KEY 1: Maps SDK key (Android-restricted with SHA-1) — used for GoogleMap widget
  static const String googleMapsApiKey = 'AIzaSyAWO5uXzlcMIKK5Z-1wjk6NjS0CoZj8N68';

  // KEY 2: HTTP API key — used for Places Autocomplete, Nearby Search, Directions REST calls
  // This key should have NO Android restriction (or IP restriction only)
  // Go to console.cloud.google.com → Create new key → No restrictions (or HTTP referrer)
  // Enable: Places API, Directions API, Geocoding API
  static const String placesApiKey = 'AIzaSyAP31jZo0JedjCNi4LpVN1StciQxRFTg3o'; // HTTP REST key (Places, Directions, Geocoding)

  // For physical Android device - uses PC's WiFi IP
  static const String apiBaseUrl = 'http://192.168.0.106:8000';
  // For Android Emulator use: 'http://10.0.2.2:8000'
  // For iOS Simulator use: 'http://localhost:8000'
}
