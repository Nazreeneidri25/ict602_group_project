import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ict602_group_project/Widgets/map.dart';

class AddMarker extends StatefulWidget {
  const AddMarker({super.key});

  @override
  State<AddMarker> createState() => _AddMarkerState();
}

class _AddMarkerState extends State<AddMarker> {
  final TextEditingController _locationLatController = TextEditingController();
  final TextEditingController _locationLongController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;

  final auth = FirebaseAuth.instance;
  List location = [];

  @override
  void dispose() {
    _locationLatController.dispose();
    _locationLongController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance.collection('food_trucks').get();
    final data =  snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      location = data;
    });
  }


  Future<void> _submitPlace() async {

    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }

    if (_selectedFoodType == null || _selectedFoodType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a food truck type.')),
      );
      return;
    }

    final newPlace = {
      "latitude": _selectedLatLng?.latitude,
      "longitude": _selectedLatLng?.longitude,
      "foodTruckType": _selectedFoodType,
      "locations": {
        "lat": _selectedLatLng?.latitude,
        "lng": _selectedLatLng?.longitude,
      },
      "addedUser": auth.currentUser?.email ?? '',
    };


    await FirebaseFirestore.instance
        .collection('food_trucks')
        .add(newPlace);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location added successfully!')),
    );
  }


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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [Column(
            children: [
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
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select a food type' : null,
              ),
              SizedBox(height: 8),
              Row(
            children: [
              Expanded(child: TextFormField(
                controller: _locationLatController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              )),
              SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _locationLongController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ))
            ],
          ),
          ElevatedButton(
              onPressed: () => _submitPlace(),
              child: Text("Add Place")
          ),
        ]),SizedBox(
            height: 500 ,
            child: MapCustom(
              onLocationSelected: (LatLng location){
                setState(() {
                  _selectedLatLng = location;
                  _locationLatController.text = location.latitude.toString();
                  _locationLongController.text = location.longitude.toString();
                });
              },
            ))
      ])
    );
  }
}