import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class PoliceStation {
  final String name;
  final String phone;
  final String province;
  final String city;

  PoliceStation({
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
  });
}

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  String? _currentLocation;
  final List<PoliceStation> _policeStations = [];
  List<PoliceStation> _filteredPoliceStations = []; // List to store filtered police stations
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPoliceStations();
    _getCurrentLocation();
  }

  void _loadPoliceStations() async {
    try {
      String csvData = await rootBundle.loadString('fixed_police.csv');
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvData);

      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        List<dynamic> row = rowsAsListOfValues[i];
        if (row.length == 4) {
          _policeStations.add(PoliceStation(
            name: row[0],
            phone: row[1].toString(), // Convert to string explicitly
            province: row[2],
            city: row[3],
          ));
        }
      }
      // Initialize filtered list with all police stations
      _filteredPoliceStations.addAll(_policeStations);
    } catch (e) {
      print('Error loading police stations:$e');}
  }

  _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation =
          'Location permissions are permanently denied, we cannot request permissions.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        _currentLocation =
        '${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}';
      });
    } catch (e) {
      print("Error getting current location: $e");
      setState(() {
        _currentLocation = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Police Stations'),
        backgroundColor: Colors.green,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _currentLocation ?? 'Loading...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by city',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterPoliceStations('');
                },
              ),
            ),
            onChanged: _filterPoliceStations,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredPoliceStations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      _filteredPoliceStations[index].name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Phone: ${_filteredPoliceStations[index].phone}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'City: ${_filteredPoliceStations[index].city}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Province: ${_filteredPoliceStations[index].province}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () {
                        _initiateCall(_filteredPoliceStations[index].phone);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _filterPoliceStations(String query) {
    setState(() {
      _filteredPoliceStations = _policeStations
          .where((station) =>
          station.city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  _initiateCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res != null && res) {
      print('Call initiated successfully');
    } else {
      print('Failed to initiate call');
    }
  }
}
