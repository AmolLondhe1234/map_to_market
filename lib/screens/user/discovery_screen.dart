import 'package:flutter/material.dart';
import 'service_detail_screen.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Discover', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Special Offers', 'See All'),
                  const SizedBox(height: 12),
                  _buildPromosList(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Top Rated Nearby', 'View All'),
                  const SizedBox(height: 12),
                  _buildTopRatedList(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Explore Categories', ''),
                  const SizedBox(height: 12),
                  _buildCategoriesGrid(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (action.isNotEmpty)
          TextButton(onPressed: () {}, child: Text(action, style: const TextStyle(color: Colors.blue))),
      ],
    );
  }

  Widget _buildPromosList() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPromoCard('30% OFF', 'First Coffee at Brew House', Colors.orange),
          _buildPromoCard('Buy 1 Get 1', 'Pizza Mania - Weekends', Colors.red),
          _buildPromoCard('FREE Checkup', 'City Dental Clinic', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String discount, String text, Color color) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(discount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTopRatedList(BuildContext context) {
    final List<Map<String, dynamic>> mockTopRated = [
      {'name': 'Starbucks Downtown', 'rating': 4.8, 'dist': '0.5 km', 'vicinity': '123 Main St'},
      {'name': 'Apollo Pharmacy', 'rating': 4.7, 'dist': '1.2 km', 'vicinity': 'High Street 45'},
      {'name': 'Fitness First', 'rating': 4.9, 'dist': '2.4 km', 'vicinity': 'Sky Tower Floor 3'},
    ];

    return Column(
      children: mockTopRated.map((place) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: place)));
          },
          leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.star, color: Colors.white)),
          title: Text(place['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${place['rating']} ★ • ${place['dist']}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        ),
      )).toList(),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {'icon': Icons.coffee, 'name': 'Cafe'},
      {'icon': Icons.restaurant, 'name': 'Dining'},
      {'icon': Icons.local_pharmacy, 'name': 'Health'},
      {'icon': Icons.shopping_bag, 'name': 'Suits'},
      {'icon': Icons.fitness_center, 'name': 'Gym'},
      {'icon': Icons.more_horiz, 'name': 'Others'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(categories[index]['icon'] as IconData, color: Colors.blue),
              const SizedBox(height: 8),
              Text(categories[index]['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }
}
