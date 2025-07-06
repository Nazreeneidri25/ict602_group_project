import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

class MapCustom extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;
  const MapCustom({super.key, this.onLocationSelected});


  @override
  State<MapCustom> createState() => _mapCustomState();
}

class _mapCustomState extends State<MapCustom> {
  late GoogleMapController mapController;
  late LatLng _currentLatLng = LatLng(3.1499 , 101.6945);
  late String? currentPlaceID;
  List<dynamic> listForPlaces = [];
  Uuid uuid = Uuid();
  final TextEditingController searchBarController = TextEditingController();
  Set<Marker> FoodTruckWidgets = {};
  Set<Marker> FoodTruckUserWidgets = {};
  String apiKey = "AIzaSyCIoRmMjbFRJePcWTt0-Nz7WEIcGCzV74s";



  @override
  void initState() {
    super.initState();
    _getUserLocation().then((pos) async {
      context.loaderOverlay.show();
      setState(()  {
        _currentLatLng =  LatLng(pos.latitude, pos.longitude);
        mapController.animateCamera(CameraUpdate.newLatLng(_currentLatLng));
      });
      currentPlaceID = await getPlaceIdFromLatLng(pos.latitude, pos.longitude);
      _showNearbyFoodTruck(_currentLatLng);
      context.loaderOverlay.hide();
      setState(() {
      });
    });
    showFoodTruckUserWidgets();
    searchBarController.addListener(_onModify);

  }

  void showFoodTruckUserWidgets() async {
    final snapshot = await FirebaseFirestore.instance.collection('food_trucks').get();

    final markerFutures = snapshot.docs.map((doc) async {
      final data = doc.data();
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;

      if (lat == null || lng == null) return null;

      final placeID = await getPlaceIdFromLatLng(lat, lng); // Await async function

      print("PLACE ID SINI : $placeID");

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () => _showPlaceDetails(placeID!, data),
      );
    }).toList();

    final markersList = await Future.wait(markerFutures);
    final markers = markersList.whereType<Marker>().toSet();

    setState(() {
      FoodTruckUserWidgets = markers;
    });
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

  Future<Position> _getUserLocation() async {
    context.loaderOverlay.show();
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
    context.loaderOverlay.hide();
    return await Geolocator.getCurrentPosition();
  }

  void makeSuggestion(String input) async {
    if (input.isEmpty) {
      setState(() => listForPlaces = []);
      return;
    }
    String sessionToken = uuid.v4();
    String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$sessionToken";
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
    context.loaderOverlay.show();
    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=name,formatted_address,geometry,photos";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body)['result'];
      LatLng latLng = LatLng(result['geometry']['location']['lat'], result['geometry']['location']['lng']);
      setState(() {
        _currentLatLng = latLng;
        listForPlaces = [];
        searchBarController.clear();
        currentPlaceID = placeId;
      });
      mapController.animateCamera(CameraUpdate.newLatLng(latLng));
      // _currentPlaceDetails = result;
      _showNearbyFoodTruck(_currentLatLng);
      _showPlaceDetails(placeId , null); // Pass the decoded result map
    }
    context.loaderOverlay.hide();
  }

  Future<void> _showNearbyFoodTruck(LatLng currentLocation) async {
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
            onTap: () => _showPlaceDetails(place['place_id'] , null),
          ),
        );
      }

      setState(() {
        FoodTruckWidgets = foodTruckMarkers;
      });
    }


  }

  void _showPlaceDetails(String placeId , Map<String , dynamic>? data ) async {
    String URL = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&*";
    final response = await http.get(Uri.parse(URL));
    print("place id: $placeId");
    print("data : $data");


    if (response.statusCode == 200) {
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

      DateTime? dateAdded;
      if (data != null) {
        final timestamp = data["timestamp"] as Timestamp;
        dateAdded = timestamp.toDate();
      }



      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) =>
            SingleChildScrollView(
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
                          child: Image.network(photoURL, height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data?["foodTruckName"] ?? (name ?? "No Name"),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (rating != null)
                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 24,
                            direction: Axis.horizontal,
                          ),
                        if (rating != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16, color: Colors
                                  .grey),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if(data != null)...[
                      Column(
                          spacing: 5.0,
                          children: [
                        Row(
                          spacing: 5.0,
                          children: [
                            const Icon(
                                Icons.people, color: Colors.blueAccent),
                            Text("Added by ${data["addedUser"]}")
                          ],
                        ),
                        Row(
                          spacing: 5.0,
                          children: [
                            const Icon(Icons.fastfood_rounded, color: Colors.blueAccent),
                            Text(data["foodTruckType"]),
                          ],
                        ),
                        Row(
                          spacing: 5.0,
                          children: [
                            const Icon(Icons.access_time_outlined, color: Colors.blueAccent),
                            Text("Date Added : $dateAdded")
                          ],
                        )
                      ]
                      ),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueAccent,
                            size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address ?? "No Address",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    if (phoneNumber != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                              Icons.phone, color: Colors.green, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            phoneNumber,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.lightBlueAccent
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    Icons.phone, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  "Call",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (openingHours != null) ...[
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.access_time,
                                      color: Colors.blueAccent, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    "Opening Hours",
                                    style: TextStyle(fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...openingHours.map<Widget>((hour) {
                                final parts = hour.split(': ');
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, size: 8,
                                          color: Colors.blueAccent),
                                      const SizedBox(width: 8),
                                      Text(
                                        parts[0],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          parts.length > 1 ? parts[1] : '',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
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
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: MarkerId("Current"),
                  position: _currentLatLng,
                  onTap: () async{
                    context.loaderOverlay.show();
                    _showPlaceDetails(currentPlaceID! , null);
                    context.loaderOverlay.hide();

                  }
                ),
                ...FoodTruckWidgets,
                ...FoodTruckUserWidgets,
              },
              mapType: MapType.normal,
              onTap: (poi)async {
                String? placeId = await getPlaceIdFromLatLng(poi.latitude, poi.longitude);

                if (placeId != null) {
                  print("$placeId  kjkjkjkjkjk");
                  _showPlaceDetails(placeId, null);
                  widget.onLocationSelected!(poi);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No POI found at this location.')),
                  );
                }
              }
            ),
            // Add inside the Stack, after your search bar Positioned widget
            Positioned(
              bottom: 24,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoom_in",
                    mini: true,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.add, color: Colors.blueAccent),
                    onPressed: () {
                      mapController.animateCamera(CameraUpdate.zoomIn());
                    },
                  ),
                  SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: "zoom_out",
                    mini: true,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.remove, color: Colors.blueAccent),
                    onPressed: () {
                      mapController.animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                ],
              ),
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
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.08),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 320,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: listForPlaces.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          var place = listForPlaces[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _moveToPlace(place['place_id']),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.location_on, color: Colors.blueAccent, size: 24),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place['structured_formatting']?['main_text'] ?? place['description'],
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          if (place['structured_formatting']?['secondary_text'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                place['structured_formatting']['secondary_text'],
                                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
            currentPlaceID = await getPlaceIdFromLatLng(pos.latitude, pos.longitude);
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