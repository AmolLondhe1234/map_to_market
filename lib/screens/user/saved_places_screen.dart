import 'package:flutter/material.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Your Saved Places', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSavedItem('Work', '123 Business St, Downtown', Icons.work),
          _buildSavedItem('Gym', '45 Fitness Ave', Icons.fitness_center),
          _buildSavedItem('Favorite Cafe', 'Coffee Corner, High St', Icons.coffee),
          const SizedBox(height: 30),
          const Text('Recently Visited', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildHistoryItem('Shopping Mall', 'Visited 2 days ago'),
          _buildHistoryItem('Central Pharmacy', 'Visited 5 days ago'),
        ],
      ),
    );
  }

  Widget _buildSavedItem(String title, String address, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        tileColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address),
        trailing: const Icon(Icons.favorite, color: Colors.red),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String time) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(title),
      subtitle: Text(time),
      onTap: () {},
    );
  }
}
