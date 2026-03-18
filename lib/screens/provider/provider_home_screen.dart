import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import 'add_service_screen.dart';
import 'profit_map_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome, ${_authService.getCurrentUser()?.displayName ?? "Provider"}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Manage your services and analyze market trends.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            // Stats Cards
            Row(
              children: [
                _buildStatCard('Active Services', '3', Icons.business_center, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard('Market Score', '8.4', Icons.trending_up, Colors.green),
              ],
            ),
            const SizedBox(height: 30),
            
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildActionTile(
              context,
              title: 'Add New Service',
              subtitle: 'Register a new business location',
              icon: Icons.add_location_alt,
              color: Colors.orange,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddServiceScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              title: 'Analyze Market',
              subtitle: 'Check business viability score',
              icon: Icons.analytics,
              color: Colors.purple,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfitMapScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              title: 'My Services',
              subtitle: 'Manage your existing locations',
              icon: Icons.list,
              color: Colors.blue,
              onTap: () {},
            ),
            
            const SizedBox(height: 30),
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildActivityItem('Cafe Market Analysis', 'Score: 78%', '2 hours ago'),
            _buildActivityItem('Added New Restaurant', 'Location: Downtown', 'Yesterday'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String description, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
