import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // Generate some mock data for the demo
    final rating = service['rating'] ?? 4.5;
    final ratingCount = service['user_ratings_total'] ?? 120;
    final priceLevel = service['price_level'] ?? 2;
    final isOpen = service['opening_hours']?['open_now'] ?? true;
    final address = service['vicinity'] ?? "Location details available on map";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(service['name'], style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&q=80&w=800', // Mock image
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'OPEN NOW' : 'CLOSED',
                          style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text('$rating ($ratingCount reviews)', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(address, style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Experience premium service with experts. We provide top-notch facilities and a comfortable environment for all our customers. Join us for a unique experience that blends quality with affordability.',
                    style: TextStyle(height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  const Text('Review Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildReviewItem('John Doe', 'Great ambiance and friendly staff!', 5),
                  _buildReviewItem('Jane Smith', 'Excellent service but a bit crowded on weekends.', 4.5),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Starting from', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('\$${(priceLevel * 15 + 10).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(width: 30),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(
                    serviceId: service['id'] ?? 'unknown',
                    serviceName: service['name'] ?? 'Service',
                  )));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('BOOK NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.orange,
                )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
