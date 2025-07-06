import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loader_overlay/loader_overlay.dart';

class EditMarker extends StatefulWidget {
  final Map<String, dynamic> foodTruckData;
  const EditMarker({super.key, required this.foodTruckData});

  @override
  State<EditMarker> createState() => _EditMarkerState();
}

class _EditMarkerState extends State<EditMarker> {
  late TextEditingController nameController;
  late String selectedType;

  final List<String> foodTruckTypes = [
    'Malaysian Food',
    'Burger',
    'Coffee',
    'Pizza',
    'Tacos',
    'Hot Dogs',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.foodTruckData['foodTruckName']);
    selectedType = widget.foodTruckData['foodTruckType'] ?? foodTruckTypes.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveEdits() async {
    context.loaderOverlay.show();
    final docId = widget.foodTruckData['foodTruckDoc'];
    await FirebaseFirestore.instance.collection('food_trucks').doc(docId).update({
      'foodTruckName': nameController.text,
      'foodTruckType': selectedType,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food truck updated.')),
      );
      Navigator.popAndPushNamed(context, "/admin_dashboard");
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.foodTruckData['latitude'];
    final lng = widget.foodTruckData['longitude'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Food Truck'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      radius: 36,
                      child: const Icon(Icons.fastfood, size: 40, color: Colors.orangeAccent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Edit Food Truck Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Truck Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      prefixIcon: const Icon(Icons.drive_file_rename_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: foodTruckTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Food Truck Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      prefixIcon: const Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Latitude: $lat\nLongitude: $lng',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    onPressed: saveEdits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
