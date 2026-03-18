import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
// ignore: unused_import
import '../../services/firebase_auth_service.dart';
import '../../widgets/prediction_panel.dart';
import 'service_detail_screen.dart';
import '../../config.dart';
import '../../services/firestore_service.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with TickerProviderStateMixin {
  late GoogleMapController mapController;
  final loc.Location _locationService = loc.Location();
  // ignore: unused_field
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _showPredictionPanel = false;
  Map<String, dynamic>? _predictionResult;

  // Multi-select categories
  final Set<String> _selectedCategories = {};
  bool _allCategoriesMode = true; // true = show all by default

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  MapType _currentMapType = MapType.normal;
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  String? _selectedPlaceName;
  Map<String, dynamic>? _selectedServiceObject;
  // ignore: unused_field
  List _nearbyResults = [];
  final Set<Circle> _circles = {};

  // Custom marker icons
  BitmapDescriptor? _userLocationIcon;

  // Pulse animation for user location
  late AnimationController _pulseController;
  // ignore: unused_field
  late Animation<double> _pulseAnimation;

  final String googleMapsApiKey = AppConfig.googleMapsApiKey;
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  // Category config with colors
  final List<Map<String, dynamic>> categories = [
    {'name': 'Cafe', 'value': 'cafe', 'icon': '☕', 'color': Colors.brown, 'hue': BitmapDescriptor.hueOrange},
    {'name': 'Restaurant', 'value': 'restaurant', 'icon': '🍴', 'color': Colors.red, 'hue': BitmapDescriptor.hueRed},
    {'name': 'Pharmacy', 'value': 'pharmacy', 'icon': '💊', 'color': Colors.green, 'hue': BitmapDescriptor.hueGreen},
    {'name': 'Hospital', 'value': 'hospital', 'icon': '🏥', 'color': Colors.pink, 'hue': BitmapDescriptor.hueRose},
    {'name': 'ATM', 'value': 'atm', 'icon': '🏧', 'color': Colors.purple, 'hue': BitmapDescriptor.hueViolet},
    {'name': 'Supermarket', 'value': 'shopping_mall', 'icon': '🛍️', 'color': Colors.blue, 'hue': BitmapDescriptor.hueBlue},
    {'name': 'Gas Station', 'value': 'gas_station', 'icon': '⛽', 'color': Colors.orange, 'hue': BitmapDescriptor.hueYellow},
    {'name': 'School', 'value': 'school', 'icon': '🏫', 'color': Colors.teal, 'hue': BitmapDescriptor.hueCyan},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _createCustomUserMarker();
    _initializeLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Create a custom blue dot marker like Google Maps
  Future<void> _createCustomUserMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 80;

    // Outer accuracy ring (light blue, semi-transparent)
    final Paint outerRingPaint = Paint()
      ..color = const Color(0x334285F4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, outerRingPaint);

    // Middle ring (border)
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 3.5, borderPaint);

    // Inner blue dot
    final Paint dotPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 5, dotPaint);

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    if (data != null) {
      setState(() {
        _userLocationIcon = BitmapDescriptor.bytes(data.buffer.asUint8List());
      });
    }
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await _locationService.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      final pos = await _locationService.getLocation();
      setState(() {
        _currentPosition = LatLng(pos.latitude!, pos.longitude!);
        _updateUserLocationMarker();
      });

      mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));

      // Load all categories by default
      await _loadAllCategories();

      // Listen to live location updates
      _locationService.onLocationChanged.listen((loc.LocationData locationData) {
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
            _updateUserLocationMarker();
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing location: $e');
    }
  }

  void _updateUserLocationMarker() {
    if (_currentPosition == null) return;
    _markers.removeWhere((m) => m.markerId.value == 'current_location');
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: _userLocationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndex: 100, // Always on top
      ),
    );

    // Accuracy circle
    _circles.removeWhere((c) => c.circleId.value == 'accuracy_circle');
    _circles.add(Circle(
      circleId: const CircleId('accuracy_circle'),
      center: _currentPosition!,
      radius: 80,
      fillColor: const Color(0x224285F4),
      strokeColor: const Color(0x664285F4),
      strokeWidth: 1,
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
    }
  }

  // Load ALL categories simultaneously (default view)
  Future<void> _loadAllCategories() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _allCategoriesMode = true;
      _selectedCategories.clear();
    });

    try {
      // Fetch from Firestore (verified businesses)
      final firestoreData = await _firestoreService.getNearbyServices().first;

      setState(() {
        _markers.removeWhere((m) => m.markerId.value != 'current_location');
      });

      // Fetch top categories in parallel
      final fetchFutures = categories.take(4).map((cat) async {
        try {
          final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
            '&radius=1500'
            '&type=${cat['value']}'
            '&key=$googleMapsApiKey',
          );
          final response = await http.get(url).timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return {'category': cat, 'results': data['results'] as List};
          }
        } catch (_) {}
        return {'category': cat, 'results': []};
      });

      final results = await Future.wait(fetchFutures);

      setState(() {
        for (var result in results) {
          final cat = result['category'] as Map<String, dynamic>;
          final places = result['results'] as List;
          for (var place in places) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            _markers.add(Marker(
              markerId: MarkerId('g_${place['place_id']}'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: '${cat['icon']} ${cat['name']} • ⭐ ${place['rating'] ?? 'N/A'}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(cat['hue'] as double),
              onTap: () => _onPlaceSelected(LatLng(lat, lng), place['name'], service: place),
            ));
          }
        }

        // Add Firestore verified businesses
        for (var service in firestoreData) {
          final lat = service['latitude'];
          final lng = service['longitude'];
          final catMatch = categories.firstWhere(
            (c) => c['value'] == service['category'],
            orElse: () => {'icon': '📍', 'hue': BitmapDescriptor.hueGreen},
          );
          _markers.add(Marker(
            markerId: MarkerId('fs_${service['id']}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: '✓ ${service['name']}',
              snippet: '${catMatch['icon']} Verified Business',
            ),
            onTap: () => _onPlaceSelected(LatLng(lat, lng), service['name'], service: service),
          ));
        }
      });
    } catch (e) {
      debugPrint('Error loading all categories: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Handle single or multi-category toggle
  Future<void> _onCategoryToggled(String categoryValue) async {
    setState(() {
      _allCategoriesMode = false;
      if (_selectedCategories.contains(categoryValue)) {
        _selectedCategories.remove(categoryValue);
      } else {
        _selectedCategories.add(categoryValue);
      }
    });

    if (_selectedCategories.isEmpty) {
      // No categories selected → revert to all
      await _loadAllCategories();
      return;
    }

    await _findNearbyServices(_selectedCategories.toList());
  }

  Future<void> _findNearbyServices(List<String> types) async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _markers.removeWhere((m) => m.markerId.value != 'current_location');
    });

    try {
      final firestoreData = await _firestoreService.getNearbyServices().first;

      final fetchFutures = types.map((type) async {
        final cat = categories.firstWhere(
          (c) => c['value'] == type,
          orElse: () => {'hue': BitmapDescriptor.hueRed, 'icon': '📍', 'name': type},
        );
        try {
          final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
            '&radius=2000'
            '&type=$type'
            '&key=$googleMapsApiKey',
          );
          final response = await http.get(url).timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return {'category': cat, 'results': data['results'] as List};
          }
        } catch (_) {}
        return {'category': cat, 'results': []};
      });

      final allResults = await Future.wait(fetchFutures);
      List combinedResults = [];

      setState(() {
        for (var result in allResults) {
          final cat = result['category'] as Map<String, dynamic>;
          final places = result['results'] as List;
          combinedResults.addAll(places);
          for (var place in places) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            _markers.add(Marker(
              markerId: MarkerId('g_${place['place_id']}'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: '${cat['icon']} ${cat['name']} • ⭐ ${place['rating'] ?? 'N/A'}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(cat['hue'] as double),
              onTap: () => _onPlaceSelected(LatLng(lat, lng), place['name'], service: place),
            ));
          }
        }

        // Add filtered Firestore results
        final filteredFirestore = firestoreData
            .where((s) => types.contains(s['category']))
            .toList();
        for (var service in filteredFirestore) {
          final lat = service['latitude'];
          final lng = service['longitude'];
          _markers.add(Marker(
            markerId: MarkerId('fs_${service['id']}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: '✓ ${service['name']}',
              snippet: 'Verified Business',
            ),
            onTap: () => _onPlaceSelected(LatLng(lat, lng), service['name'], service: service),
          ));
        }

        _nearbyResults = [...combinedResults, ...filteredFirestore];
      });
    } catch (e) {
      debugPrint('Error finding services: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onPlaceSelected(LatLng position, String name, {Map<String, dynamic>? service}) {
    setState(() {
      _destinationPosition = position;
      _selectedPlaceName = name;
      _selectedServiceObject = service;
      _showPredictionPanel = false;
    });
    _getRoutePolyline();
    mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  Future<void> _getRoutePolyline() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    poly.PolylinePoints polylinePoints = poly.PolylinePoints(apiKey: googleMapsApiKey);
    poly.PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: poly.PolylineRequest(
        origin: poly.PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        destination: poly.PointLatLng(_destinationPosition!.latitude, _destinationPosition!.longitude),
        mode: poly.TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: const Color(0xFF4285F4),
          points: polylineCoordinates,
          width: 5,
          patterns: [],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ));
      });

      // Fit camera to show full route
      final bounds = _computeLatLngBounds(polylineCoordinates);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    }
  }

  LatLngBounds _computeLatLngBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Calculate approx distance in km
  String _getDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371;
    final dLat = _degreesToRadians(to.latitude - from.latitude);
    final dLng = _degreesToRadians(to.longitude - from.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(from.latitude)) *
            cos(_degreesToRadians(to.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    if (distance < 1) return '${(distance * 1000).toStringAsFixed(0)} m';
    return '${distance.toStringAsFixed(1)} km';
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  Future<void> _predictLocation(LatLng location) async {
    setState(() {
      _isLoading = true;
      _markers.add(Marker(
        markerId: const MarkerId('selected_analysis'),
        position: location,
        infoWindow: const InfoWindow(title: 'Analyzing This Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/predict-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'category': _selectedCategories.isNotEmpty ? _selectedCategories.first : 'general',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _predictionResult = jsonDecode(response.body);
          _showPredictionPanel = true;
        });
      } else {
        _showFallbackPrediction();
      }
    } catch (e) {
      _showFallbackPrediction();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFallbackPrediction() {
    setState(() {
      _predictionResult = {
        'success_probability': 0.75,
        'risk_level': 'LOW',
        'top_positive_factors': ['High foot traffic', 'Competitive area', 'Near transit'],
        'top_negative_factors': ['High rent potential'],
      };
      _showPredictionPanel = true;
    });
  }

  Future<void> _launchNavigation() async {
    if (_destinationPosition == null) return;
    final url = 'google.navigation:q=${_destinationPosition!.latitude},${_destinationPosition!.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUrl = 'https://www.google.com/maps/dir/?api=1&destination=${_destinationPosition!.latitude},${_destinationPosition!.longitude}';
      await launchUrl(Uri.parse(webUrl));
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Google Map ──
          SizedBox.expand(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(18.5204, 73.8567),
                zoom: 14,
              ),
              mapType: _currentMapType,
              markers: _markers,
              polylines: _polylines,
              circles: _circles,
              myLocationEnabled: false, // We draw our own dot
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onLongPress: _predictLocation,
            ),
          ),

          // ── Top Controls ──
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: TextEditingController(),
                      googleAPIKey: googleMapsApiKey,
                      inputDecoration: const InputDecoration(
                        hintText: "Search shops, places...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF4285F4)),
                      ),
                      debounceTime: 700,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        final lat = double.parse(prediction.lat!);
                        final lng = double.parse(prediction.lng!);
                        _onPlaceSelected(LatLng(lat, lng), prediction.description ?? '');
                      },
                      itemClick: (Prediction prediction) {},
                    ),
                  ),
                ),

                // Category filter chips (multi-select)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length + 1, // +1 for "All" chip
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "All" chip
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: _loadAllCategories,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _allCategoriesMode
                                    ? const Color(0xFF4285F4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _allCategoriesMode
                                      ? const Color(0xFF4285F4)
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4),
                                ],
                              ),
                              child: Text(
                                '🗺️ All',
                                style: TextStyle(
                                  color: _allCategoriesMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final cat = categories[index - 1];
                      final isSelected = _selectedCategories.contains(cat['value']);
                      final catColor = cat['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => _onCategoryToggled(cat['value'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? catColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? catColor : Colors.grey.shade300,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Text(
                              '${cat['icon']} ${cat['name']}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Active filter indicator
                if (_selectedCategories.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_selectedCategories.length} categories selected',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Right Side FABs ──
          Positioned(
            right: 12,
            top: MediaQuery.of(context).padding.top + 130,
            child: Column(
              children: [
                _buildFab(
                  heroTag: 'mapType',
                  icon: Icons.layers_outlined,
                  onTap: _toggleMapType,
                  tooltip: 'Toggle Map Type',
                ),
                const SizedBox(height: 10),
                _buildFab(
                  heroTag: 'myLocation',
                  icon: Icons.my_location,
                  onTap: () {
                    if (_currentPosition != null) {
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentPosition!, 16),
                      );
                    }
                  },
                  tooltip: 'My Location',
                  activeColor: const Color(0xFF4285F4),
                ),
                const SizedBox(height: 10),
                _buildFab(
                  heroTag: 'refresh',
                  icon: Icons.refresh,
                  onTap: _allCategoriesMode
                      ? _loadAllCategories
                      : () => _findNearbyServices(_selectedCategories.toList()),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // ── Legend (bottom left) ──
          Positioned(
            bottom: _destinationPosition != null ? 170 : 20,
            left: 12,
            child: _buildLegend(),
          ),

          // ── Bottom Destination Card ──
          if (_destinationPosition != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _buildDestinationCard(),
            ),

          // ── Loading Overlay ──
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4285F4)),
                ),
              ),
            ),

          // ── Prediction Panel ──
          if (_showPredictionPanel && _predictionResult != null)
            PredictionPanel(
              prediction: _predictionResult!,
              onClose: () => setState(() => _showPredictionPanel = false),
            ),
        ],
      ),
    );
  }

  Widget _buildFab({
    required String heroTag,
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color? activeColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Icon(icon, color: activeColor ?? Colors.black87, size: 22),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Legend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 4),
          _legendItem(color: const Color(0xFF4285F4), label: 'Your Location'),
          _legendItem(color: Colors.green, label: 'Verified Business'),
          _legendItem(color: Colors.red, label: 'Google Places'),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    final distance = _currentPosition != null && _destinationPosition != null
        ? _getDistance(_currentPosition!, _destinationPosition!)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: Color(0xFF4285F4), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPlaceName ?? 'Selected Location',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedServiceObject != null)
                        Text(
                          '⭐ ${_selectedServiceObject!['rating'] ?? 'N/A'} · ${_selectedServiceObject!['vicinity'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (distance.isNotEmpty)
                        Text(
                          '📍 $distance away',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF4285F4)),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() {
                    _destinationPosition = null;
                    _polylines.clear();
                    _selectedServiceObject = null;
                    _selectedPlaceName = null;
                  }),
                ),
              ],
            ),
            const Divider(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.analytics_outlined,
                  label: 'Analyze',
                  color: Colors.orange,
                  onTap: () => _predictLocation(_destinationPosition!),
                ),
                if (_selectedServiceObject != null)
                  _actionButton(
                    icon: Icons.info_outline,
                    label: 'Details',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailScreen(service: _selectedServiceObject!),
                      ),
                    ),
                  ),
                _actionButton(
                  icon: Icons.navigation,
                  label: 'Navigate',
                  color: Colors.green,
                  filled: true,
                  onTap: _launchNavigation,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: filled ? Colors.white : color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
