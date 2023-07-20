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

            },
          );
        }).toSet();
      });
    } else {
      print('Failed to fetch agences: ${response.statusCode}');
    }
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
