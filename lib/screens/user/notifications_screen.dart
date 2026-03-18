import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            'Booking Confirmed',
            'Your appointment with Starbucks is confirmed for tomorrow.',
            '2 hours ago',
            Icons.check_circle,
            Colors.green,
          ),
          _buildNotificationItem(
            'Special Offer',
            'Get 50% off on your next spa booking nearby!',
            '5 hours ago',
            Icons.local_offer,
            Colors.orange,
          ),
          _buildNotificationItem(
            'New Business nearby',
            'A new fitness center just opened in your area. Check it out!',
            'Yesterday',
            Icons.new_releases,
            Colors.blue,
          ),
          _buildNotificationItem(
            'Review Request',
            'How was your visit to Apollo Pharmacy? Share your feedback.',
            '2 days ago',
            Icons.rate_review,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(body),
        trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        onTap: () {},
      ),
    );
  }
}
