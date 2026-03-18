import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final user = authService.getCurrentUser();

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            user?.displayName ?? 'User Name',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'user@example.com',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Divider(),
          _buildProfileOption(Icons.settings, 'Account Settings'),
          _buildProfileOption(Icons.notifications_outlined, 'Notifications'),
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Database Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  color: Colors.blue.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text('If you don\'t see your data, try syncing your account profile to the database.', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _syncProfile(context),
                                icon: const Icon(Icons.sync, size: 16),
                                label: const Text('Sync Profile', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _seedData(context),
                                icon: const Icon(Icons.data_array, size: 16),
                                label: const Text('Seed Demo', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => authService.logoutUser(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _syncProfile(BuildContext context) async {
    final authService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final user = authService.getCurrentUser();
    
    if (user != null) {
      try {
        await firestoreService.createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          role: 'USER', // Default back to user if missing
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile synced to database!'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _seedData(BuildContext context) async {
    final firestoreService = FirestoreService();
    try {
      await firestoreService.seedSampleData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample data initialized!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeding failed: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
