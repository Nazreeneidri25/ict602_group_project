import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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
  LatLng? _selectedLatLng;
  String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";
  final auth = FirebaseAuth.instance;
  String? _selectedFoodType;

  final List<String> _foodTypes = [
    'Malaysian Food',
    'Burger',
    'Coffee',
    'Pizza',
    'Tacos',
    'Hot Dogs',
    'Others'
  ];

  @override
  void dispose() {
    _locationLatController.dispose();
    _locationLongController.dispose();
    super.dispose();
  }

  Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var results = jsonDecode(response.body)['results'];
      if (results != null && results.isNotEmpty) {
        String placeId = results[0]['place_id'];
        String location = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&*";
        final response = await http.get(Uri.parse(location));
        final result = jsonDecode(response.body)["result"];
        String address = result['formatted_address'];
        return address;
      }
    }
    return null;
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
      "locations": await getPlaceIdFromLatLng(_selectedLatLng!.latitude , _selectedLatLng!.longitude),
      "addedUser": auth.currentUser?.email ?? '',
      "timestamp": FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('food_trucks').add(newPlace);
    _foodTruckNameController.clear();
    context.loaderOverlay.hide();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location added successfully!')),
    );
    Navigator.popAndPushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 300,
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Food Truck Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _foodTruckNameController,
                          decoration: InputDecoration(
                            labelText: 'Food Truck Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            prefixIcon: const Icon(Icons.drive_file_rename_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          "Location (auto-filled)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 8),
                        Text(
                          _selectedLatLng == null
                              ? "Tap on the map above to select a location."
                              : "Location selected.",
                          style: TextStyle(
                            color: _selectedLatLng == null ? Colors.red : Colors.green,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitPlace,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text("Add Food Truck"),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}