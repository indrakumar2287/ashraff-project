import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(26.92, 75.78),
  );

  LatLng currentLatLng = LatLng(26.92, 75.78);
  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  void getUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Location Device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Location Permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData? locationData = await location.getLocation();

    print(
      "Location Data >> ${locationData.latitude} , ${locationData.longitude}",
    );

    Future.delayed(Duration(seconds: 4));

    setState(() {
      currentLatLng = LatLng(
        locationData.latitude ?? 25,
        locationData.longitude ?? 75,
      );
      initialCameraPosition = CameraPosition(
        target: LatLng(
          locationData.latitude ?? 25,
          locationData.longitude ?? 75,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: initialCameraPosition,


                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                onCameraMove: (data) {
                  initialCameraPosition = data;
                },
                markers: {
                  Marker(markerId: MarkerId("id1"), position: currentLatLng),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
