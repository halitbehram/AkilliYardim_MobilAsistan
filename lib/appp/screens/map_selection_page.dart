// map_selection_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectionPage extends StatefulWidget {
  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(41.0082, 28.9784), // İstanbul örnek konum
          zoom: 12,
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: _selectedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selected-location'),
                  position: _selectedLocation!,
                ),
              },
      ),
      floatingActionButton: _selectedLocation == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedLocation);
              },
              child: const Icon(Icons.check),
            ),
    );
  }
}