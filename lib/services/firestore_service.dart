import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String colUsers = 'users';
  static const String colServices = 'services';
  static const String colBookings = 'bookings';
  static const String colPredictions = 'predictions';

  // --- User Profile ---

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String role,
  }) async {
    try {
      await _firestore.collection(colUsers).doc(uid).set({
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(colUsers).doc(uid).get();
      if (!doc.exists) throw Exception('User profile not found');
      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // --- Services / Businesses ---

  Future<void> addService({
    required String name,
    required String category,
    required double lat,
    required double lng,
    required String description,
  }) async {
    try {
      final providerId = _auth.currentUser?.uid;
      if (providerId == null) throw 'User not authenticated';

      await _firestore.collection(colServices).add({
        'providerId': providerId,
        'name': name,
        'category': category.toLowerCase(),
        'latitude': lat,
        'longitude': lng,
        'description': description,
        'rating': 4.5, // Default rating for new service
        'priceLevel': 2,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getNearbyServices() {
    return _firestore.collection(colServices).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // --- Bookings ---

  Future<void> createBooking({
    required String serviceId,
    required String serviceName,
    required DateTime dateTime,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _firestore.collection(colBookings).add({
        'userId': userId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'dateTime': dateTime.toIso8601String(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getUserBookings() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    // NOTE: We intentionally omit .orderBy() here to avoid the Firestore
    // FAILED_PRECONDITION error that requires a composite index when combining
    // .where() with .orderBy() on a different field.
    // Sorting is done client-side instead.
    return _firestore
        .collection(colBookings)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['_docId'] = doc.id;
        return data;
      }).toList();

      // Client-side sort: newest first
      docs.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        // Firestore Timestamps have a compareTo method
        try {
          return (bTime as dynamic).compareTo(aTime as dynamic);
        } catch (_) {
          return 0;
        }
      });

      return docs;
    });
  }

  // --- Predictions ---

  Future<void> savePrediction({
    required String category,
    required double latitude,
    required double longitude,
    required double successProbability,
    required String riskLevel,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection(colUsers).doc(userId).collection(colPredictions).add({
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'successProbability': successProbability,
        'riskLevel': riskLevel,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Warning: Failed to save prediction to Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPredictionHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection(colUsers)
          .doc(userId)
          .collection(colPredictions)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Seed Data ---

  Future<void> seedSampleData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'Login required to seed data';

      final sampleServices = [
        {
          'name': 'Blue Bottle Coffee',
          'category': 'cafe',
          'latitude': 18.5204 + 0.005,
          'longitude': 73.8567 + 0.005,
          'description': 'Premium coffee brewery with artisanal blends.',
          'rating': 4.8,
          'priceLevel': 3,
        },
        {
          'name': 'The Daily Grind',
          'category': 'cafe',
          'latitude': 18.5204 - 0.003,
          'longitude': 73.8567 + 0.008,
          'description': 'Cozy neighborhood cafe with great workspace.',
          'rating': 4.5,
          'priceLevel': 2,
        },
        {
          'name': 'City General Hospital',
          'category': 'hospital',
          'latitude': 18.5204 + 0.012,
          'longitude': 73.8567 - 0.004,
          'description': '24/7 emergency services and specialized care.',
          'rating': 4.2,
          'priceLevel': 1,
        },
        {
          'name': 'Green Leaf Pharmacy',
          'category': 'pharmacy',
          'latitude': 18.5204 - 0.005,
          'longitude': 73.8567 - 0.002,
          'description': 'Trusted community pharmacy with home delivery.',
          'rating': 4.7,
          'priceLevel': 2,
        },
      ];

      for (var service in sampleServices) {
        await _firestore.collection(colServices).add({
          ...service,
          'providerId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to seed data: $e');
    }
  }
}
