import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const BookingScreen({super.key, required this.serviceId, required this.serviceName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _timeslots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM',
    '05:00 PM', '06:00 PM', '07:00 PM', '08:00 PM'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _confirmBooking() async {
    setState(() => _isSubmitting = true);
    
    try {
      // Combine date and time
      final timeParts = _selectedTime.split(' ');
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      int min = int.parse(hourMin[1]);
      if (timeParts[1] == 'PM' && hour < 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;

      final bookingDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        min,
      );

      await _firestoreService.createBooking(
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        dateTime: bookingDateTime,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Your appointment at ${widget.serviceName} is scheduled for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at $_selectedTime.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close booking screen
                  Navigator.pop(context); // Back to map
                },
                child: const Text('GREAT'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking for ${widget.serviceName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Text('Change', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Select Time Slot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeslots.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTime == _timeslots[index];
                return InkWell(
                  onTap: () => setState(() => _selectedTime = _timeslots[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _timeslots[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text('Special Requirements (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CONFIRM BOOKING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
