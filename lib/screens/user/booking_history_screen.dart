import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load bookings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Booking History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (bookings.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No bookings found. Try booking a service!'),
                  ),
                )
              else
                ...bookings.map((booking) => _buildBookingItem(
                      booking['serviceName'] ?? 'Unknown Service',
                      booking['dateTime'] ?? '',
                      booking['status'] ?? 'Pending',
                      _getStatusColor(booking['status'] ?? 'Pending'),
                      _getServiceIcon(booking['serviceName'] ?? ''),
                    )),
              const SizedBox(height: 30),
              const Text('Recommended for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildRecommendationTile('Pharmacy - 20% Off', 'Valid until tomorrow'),
              _buildRecommendationTile('New Cafe nearby', 'Try their new latte'),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _getServiceIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('coffee') || n.contains('cafe')) return Icons.coffee;
    if (n.contains('hospital') || n.contains('medical')) return Icons.local_hospital;
    if (n.contains('gym')) return Icons.fitness_center;
    return Icons.store;
  }

  Widget _buildBookingItem(String name, String dateTime, String status, Color statusColor, IconData icon) {
    String formattedDate = dateTime;
    try {
      final dt = DateTime.parse(dateTime);
      formattedDate = "${dt.day}/${dt.month}/${dt.year}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formattedDate),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
              child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildRecommendationTile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
