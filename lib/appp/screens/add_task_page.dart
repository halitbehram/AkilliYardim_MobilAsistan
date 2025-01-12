// add_task_page.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_selection_page.dart';

class AddTaskPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTaskAdded;

  AddTaskPage({required this.onTaskAdded});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedAddress = "Haritadan Konum Belirle";
  double? _latitude;
  double? _longitude;
  double _radius = 1000.0;

  void _selectLocation() async {
    LatLng? selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(),
      ),
    );

    if (selectedLocation != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation.latitude, selectedLocation.longitude);

      setState(() {
        _latitude = selectedLocation.latitude;
        _longitude = selectedLocation.longitude;
        _selectedAddress = placemarks.first.name ?? "Bilinmeyen Konum";
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.isNotEmpty && _latitude != null) {
      widget.onTaskAdded({
        'title': _titleController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'address': _selectedAddress,
        'radius': _radius,
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatma Tanımla'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Sana Ne Hatırlatmamı İstersin ?'),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectLocation,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(_selectedAddress),
              ),
            ),
            Slider(
              value: _radius,
              min: 1000,
              max: 10000,
              divisions: 9,
              label: 'Çap: ${( _radius / 1000).toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}