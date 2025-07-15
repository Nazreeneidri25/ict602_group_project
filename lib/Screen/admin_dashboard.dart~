import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:ict602_group_project/Screen/editMarker.dart';
import 'package:ict602_group_project/Widgets/parentWidget.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAdmin = false;
  List<Map<String, dynamic>> foodTruckData = [];
  String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";

  @override
  void initState() {
    super.initState();
    _checkAdminPrivileges();
    listofFoodTrucks();
  }

  Future<void> _checkAdminPrivileges() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      // Redirect to login if no user is logged in
      Navigator.pushReplacementNamed(context, '/auth');
      return;
    }

    try {
      // Check if the user has admin privileges in Firestore
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc['role'] == 'admin') {
        setState(() {
          _isAdmin = true;
        });
      } else {
        // Redirect non-admin users
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Handle errors (e.g., Firestore issues)
      print('Error checking admin privileges: $e');
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  void listofFoodTrucks() async {
    context.loaderOverlay.show();
      final snapshot = await FirebaseFirestore.instance.collection('food_trucks').get();
      final foodTrucks = await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data();
      final addedUser = data["addedUser"];
      final foodTruckType = data["foodTruckType"];
      final latitude = data["latitude"];
      final longitude = data["longitude"];
      final foodTruckName = data["foodTruckName"];
      final foodTruckDoc = doc.id;
      final placeID = await getPlaceIdFromLatLng(latitude, longitude);
      late  String location;

      String URL = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey&*";
      final response = await http.get(Uri.parse(URL));

      if(response.statusCode == 200){
        final result = jsonDecode(response.body)["result"];
        location = result['formatted_address'];
      }

      return {
        "addedUser": addedUser,
        "foodTruckType": foodTruckType,
        "latitude": latitude,
        "longitude": longitude,
        "foodTruckName": foodTruckName,
        "locationFromAPI" : location,
        "foodTruckDoc" : foodTruckDoc
      };

    }));

    setState(() {
      foodTruckData.clear();
      foodTruckData.addAll(foodTrucks);
    });

    context.loaderOverlay.hide();
  }

  Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var results = jsonDecode(response.body)['results'];
      if (results != null && results.isNotEmpty) {
        print("masuk sini?");
        print(results[0]['place_id']);
        return results[0]['place_id'];
      }else print("masuk else");
    }
    return null;
  }

  Future<void> deleteFoodTruck(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Truck'),
        content: const Text('Are you sure you want to delete this food truck?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
        context.loaderOverlay.show();
        await FirebaseFirestore.instance
            .collection('food_trucks')
            .doc(docId)
            .delete();
        setState(() {
          listofFoodTrucks();
          foodTruckData;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food truck deleted.')),
        );
      }
      context.loaderOverlay.hide();
  }



  Widget foodTruckCard() {
    return ListView(
      children: foodTruckData.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fastfood, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item["foodTruckName"] ?? 'No Name Yet',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      item['foodTruckType'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Location: ${item["locationFromAPI"]}",
                        style: const TextStyle(fontSize: 15),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.map, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${item['latitude']}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Lng: ${item['longitude']}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          ),
                        ])
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Added By: ${item['addedUser']}',
                      style: const TextStyle(fontSize: 15, color: Colors
                          .black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit', style: TextStyle(
                          color: Colors.white)),
                      onPressed: () => Navigator.push(
                          context,
                        MaterialPageRoute(builder: (context) => ParentWidget(child: EditMarker(foodTruckData: item)))
                      )
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Delete', style: TextStyle(
                          color: Colors.white)),
                      onPressed: () {
                        deleteFoodTruck(item["foodTruckDoc"]);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!_isAdmin) {
      return const SizedBox.shrink(); // Prevent rendering if not admin
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text('Admin Menu', style: TextStyle(color: Colors.white)),
            ),
            Expanded(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, '/auth');
                  },
                )),
          ],
        )),
      body: foodTruckData.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fastfood_outlined,
                  size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                "No Food Trucks Found",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Looks like no users have added food trucks yet.\nCheck back later or add one yourself!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: listofFoodTrucks,
                icon: const Icon(Icons.refresh),
                label: const Text("Reload"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      )
          : foodTruckCard(),
    );
  }
}