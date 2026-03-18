import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import '../../services/firestore_service.dart';


class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final loc.Location _locationService = loc.Location();
  final FirestoreService _firestoreService = FirestoreService();

  
  LatLng? _selectedLocation;
  String _selectedCategory = 'cafe';
  bool _isSaving = false;

  void _onTapMap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      setState(() => _isSaving = true);
      
      try {
        await _firestoreService.addService(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          lat: _selectedLocation!.latitude,
          lng: _selectedLocation!.longitude,
          description: _descController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service registered successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on map to select location'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Service')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(18.5204, 73.8567),
                    zoom: 14,
                  ),
                  onTap: _onTapMap,
                  markers: _selectedLocation == null ? {} : {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    )
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: const Text('Tap on map to select business location', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Business Name', prefixIcon: Icon(Icons.business)),
                      validator: (v) => v!.isEmpty ? 'Enter business name' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                      items: const [
                        DropdownMenuItem(value: 'cafe', child: Text('Cafe')),
                        DropdownMenuItem(value: 'restaurant', child: Text('Restaurant')),
                        DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy')),
                      ],
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                      validator: (v) => v!.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SAVE SERVICE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
