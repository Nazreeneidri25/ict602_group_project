import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ict602_group_project/Widgets/map.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AddMarker extends StatefulWidget {
  const AddMarker({super.key});

  @override
  State<AddMarker> createState() => _AddMarkerState();
}

class _AddMarkerState extends State<AddMarker> {
  final TextEditingController _foodTruckNameController = TextEditingController();
  final TextEditingController _locationLatController = TextEditingController();
  final TextEditingController _locationLongController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;

  final auth = FirebaseAuth.instance;
  List location = [];

  final List<String> _foodTypes = [
    'Malaysian Food',
    'Burger',
    'Coffee',
    'Pizza',
    'Tacos',
    'Hot Dogs',
    'Others'
  ];
  String? _selectedFoodType;

  @override
  void dispose() {
    _locationLatController.dispose();
    _locationLongController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance.collection('food_trucks').get();
    final data = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      location = data;
    });
  }

  Future<void> _submitPlace() async {
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }

    if (_selectedFoodType == null || _selectedFoodType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a food truck type.')),
      );
      return;
    }

    if (_foodTruckNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food truck name.')),
      );
      return;
    }

    context.loaderOverlay.show();
    final newPlace = {
      "latitude": _selectedLatLng?.latitude,
      "longitude": _selectedLatLng?.longitude,
      "foodTruckType": _selectedFoodType,
      "foodTruckName": _foodTruckNameController.text.trim(),
      "locations": {
        "lat": _selectedLatLng?.latitude,
        "lng": _selectedLatLng?.longitude,
      },
      "addedUser": auth.currentUser?.email ?? '',
      "timestamp": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('food_trucks').add(newPlace);

    _foodTruckNameController.clear();
    context.loaderOverlay.hide();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 400,
                child: MapCustom(
                  onLocationSelected: (LatLng location) {
                    setState(() {
                      _selectedLatLng = location;
                      _locationLatController.text = location.latitude.toString();
                      _locationLongController.text = location.longitude.toString();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.fastfood, size: 40, color: Colors.orangeAccent),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _foodTruckNameController,
                      decoration: InputDecoration(
                        labelText: 'Food Truck Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.drive_file_rename_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedFoodType,
                      items: _foodTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedFoodType = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Type of Food Truck',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationLatController,
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              prefixIcon: const Icon(Icons.my_location),
                            ),
                            readOnly: true,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _locationLongController,
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                            readOnly: true,
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text("Add Food Truck"),
                        onPressed: _submitPlace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
