import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Market Performance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildChartMockup('Traffic Growth', '↑ 12%', Colors.blue),
            const SizedBox(height: 20),
            _buildChartMockup('Customer Retention', '↑ 8%', Colors.green),
            const SizedBox(height: 30),
            const Text('Area Competitors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildCompetitorItem('The Daily Grind', '0.4 km', '4.5 ★'),
            _buildCompetitorItem('Coffee House', '1.2 km', '4.2 ★'),
            _buildCompetitorItem('Starbucks', '2.1 km', '4.8 ★'),
          ],
        ),
      ),
    );
  }

  Widget _buildChartMockup(String title, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(trend, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(painter: LineChartPainter(color)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorItem(String name, String dist, String rating) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.store)),
        title: Text(name),
        subtitle: Text('Distance: $dist'),
        trailing: Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final Color color;
  LineChartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
