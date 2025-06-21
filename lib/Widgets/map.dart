import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MapCustom extends StatefulWidget {
  const MapCustom({super.key});

  @override
  State<MapCustom> createState() => _mapCustomState();
}

class _mapCustomState extends State<MapCustom> {
  late GoogleMapController mapController;
  static const LatLng _defaultCenter = LatLng(3.140853, 101.693207);
  LatLng _currentLatLng = _defaultCenter;

  List<dynamic> listForPlaces = [];
  Uuid uuid = Uuid();
  final TextEditingController searchBarController = TextEditingController();
  Map<String, dynamic>? _currentPlaceDetails;

  Set<Marker> FoodTruckWidgets = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation().then((pos) {
      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
      });
    });
    _showNearbyFoodTruck(_currentLatLng);
    searchBarController.addListener(_onModify);
  }

  Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
    String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";
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

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void makeSuggestion(String input) async {
    if (input.isEmpty) {
      setState(() => listForPlaces = []);
      return;
    }
    String sessionToken = uuid.v4();
    String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$sessionToken";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        listForPlaces = jsonDecode(response.body)['predictions'];
      });
    } else {
      setState(() => listForPlaces = []);
    }
  }

  void _onModify() {
    makeSuggestion(searchBarController.text);
  }



  Future<void> _moveToPlace(String placeId) async {
    String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";
    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=name,formatted_address,geometry,photos";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body)['result'];
      LatLng latLng = LatLng(result['geometry']['location']['lat'], result['geometry']['location']['lng']);
      setState(() {
        _currentLatLng = latLng;
        listForPlaces = [];
        searchBarController.clear();
      });
      mapController.animateCamera(CameraUpdate.newLatLng(latLng));
      _currentPlaceDetails = result;
      _showNearbyFoodTruck(_currentLatLng);
      _showPlaceDetails(placeId); // Pass the decoded result map
    }
  }

  Future<void> _showNearbyFoodTruck(LatLng currentLocation) async {
    String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";

    String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${currentLocation.latitude},${currentLocation.longitude}"
        "&radius=7000"
        "&keyword=food%20truck"
        "&key=$apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)["results"];
      Set<Marker> foodTruckMarkers = {};


      for (var place in results) {
        final location = place['geometry']['location'];
        foodTruckMarkers.add(
          Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(location['lat'], location['lng']),
            infoWindow: InfoWindow(title: place['name']),
            onTap: () => _showPlaceDetails(place['place_id']),
          ),
        );
      }

      setState(() {
        FoodTruckWidgets = foodTruckMarkers;
      });
    }


  }

  void _showPlaceDetails(String placeId) async{
    String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";
    String URL = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&*";

    final response = await http.get(Uri.parse(URL));


    if(response.statusCode == 200) {
      final result = jsonDecode(response.body)["result"];

      print("here $result");
      double? rating = result['rating'];
      String? name = result['name'];
      String? phoneNumber = result['formatted_phone_number'];
      String? address = result['formatted_address'];
      List<dynamic>? openingHours = result['opening_hours']?['weekday_text'];

      String? photoRef = result['photos'] != null && result['photos'].isNotEmpty
          ? result['photos'][0]['photo_reference']
          : null;
      String photoURL = photoRef != null
          ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoRef&key=AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s"
          : "";


      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoURL.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(photoURL, height: 180, width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name ?? "No Name",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (rating != null)
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 24,
                        direction: Axis.horizontal,
                      ),
                    if (rating != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address ?? "No Address",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                if (phoneNumber != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        phoneNumber,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
                if (openingHours != null) ...[
                  const SizedBox(height: 16),
                  const Text("Opening Hours:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...openingHours.map((hour) => Text(hour, style: const TextStyle(fontSize: 14, color: Colors.grey))),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }






  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 18,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("Current"),
                  position: _currentLatLng,
                  onTap: () {
                    if (_currentPlaceDetails != null) {
                      _showPlaceDetails(getPlaceIdFromLatLng(_currentLatLng.longitude, _currentLatLng.longitude) as String);
                    }
                  }
                ),
                ...FoodTruckWidgets,
              },
              mapType: MapType.normal,
              onTap: (poi)async {
                String? placeId = await getPlaceIdFromLatLng(poi.latitude, poi.longitude);
                if (placeId != null) {
                  _moveToPlace(placeId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No POI found at this location.')),
                  );
                }
              }
            ),
            // Inside your Positioned widget in the Stack
            Positioned(
              top: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.black26,
                    child: TextField(
                      controller: searchBarController,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                        hintText: "Search for a location...",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    child: listForPlaces.isNotEmpty
                        ? Container(
                      key: ValueKey('suggestionList'),
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 240,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: listForPlaces.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          var place = listForPlaces[index];
                          return ListTile(
                            leading: Icon(Icons.location_on, color: Colors.blueAccent),
                            title: Text(
                              place['description'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            onTap: () => _moveToPlace(place['place_id']),
                          );
                        },
                      ),
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            var pos = await _getUserLocation();
            setState(() {
              _currentLatLng = LatLng(pos.latitude, pos.longitude);
              _showNearbyFoodTruck(_currentLatLng);
            });
            mapController.animateCamera(
              CameraUpdate.newLatLng(_currentLatLng),
            );
          },
          child: Icon(
            Icons.my_location,
            color: Colors.white,
            size: 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }

}