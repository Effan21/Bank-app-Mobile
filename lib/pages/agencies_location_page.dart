import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../const.dart';
import '../theme/colors.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  LatLng _initialPosition = LatLng(5.316667, -4.033333);
  Set<Marker> _markers = {};

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Navigator.pop(context);
    }

    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _fetchAgences() async {
    final url = Uri.parse('http://$ip_server:8000/bank/agences/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      setState(() {
        _markers = data.map((agence) {
          final lat = agence['latitude'] as double;
          final lng = agence['longitude'] as double;
          final markerId = MarkerId(agence['nom']);

          return Marker(
            markerId: markerId,
            position: LatLng(lat, lng),
            onTap: () {
              _showInfoWindow(markerId, agence);
            },
          );
        }).toSet();
      });
    } else {
      print('Failed to fetch agences: ${response.statusCode}');
    }
  }

  void _showInfoWindow(MarkerId markerId, dynamic agence) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = Offset.zero;

    final infoWindow = InfoWindow(
      markerId: markerId,
      position: LatLng(
        agence['latitude'] as double,
        agence['longitude'] as double,
      ),
      onTap: () {
        // Handle tap on the info window
      },
    );

    _customInfoWindowController.addInfoWindow!(infoWindow);

    _customInfoWindowController.onInfoWindowTap(() {
      showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    agence['nom'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contact: ${agence['contact']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Email: ${agence['email']}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      if (position != null) {
        setState(() {
          _initialPosition =
              LatLng(position.latitude, position.longitude);
        });
      }
    });

    _fetchAgences();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const Text('Localiser les agences'),
          backgroundColor: AppColor.primary,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 10,
          ),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _customInfoWindowController.googleMapController = controller;
          },
        ),
      ),
    );
  }
}
