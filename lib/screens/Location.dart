import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../Colors/coustcolors.dart';

class RapidoMapPage extends StatefulWidget {
  @override
  _RapidoMapPageState createState() => _RapidoMapPageState();
}

class _RapidoMapPageState extends State<RapidoMapPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(12.9716, 77.5946); // Default location
  String _address = "Fetching address...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch the current location
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _fetchAddress(position.latitude, position.longitude);
      _mapController.move(
          _currentLocation, 15.0); // Move map to current location
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _address =
              json.decode(response.body)['display_name'] ?? "No address found";
        });
      } else {
        print("Failed to fetch address");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Location"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Map widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _currentLocation = position.center!;
                  });
                  _fetchAddress(
                      _currentLocation.latitude, _currentLocation.longitude);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),

          // Center Marker
          const Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on,
              size: 40,
              color: Colors.red,
            ),
          ),

          // Address display and confirmation button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the address
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Select Drop button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'location': _currentLocation,
                        'address': _address,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CoustColors.colrButton3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Center(
                      child: Text(
                        "Select location",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
