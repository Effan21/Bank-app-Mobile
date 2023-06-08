import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';

import '../theme/colors.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  LatLng _initialPosition = LatLng(5.316667, -4.033333) ;
  String Idpompe ="";

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



  }
  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('Localiser les agences'),
        backgroundColor: AppColor.primary,
      ),
  body:
        GoogleMap( initialCameraPosition: CameraPosition(target: _initialPosition,
          zoom:4,),myLocationButtonEnabled: true,myLocationEnabled: true,
        ),);
  }
}



