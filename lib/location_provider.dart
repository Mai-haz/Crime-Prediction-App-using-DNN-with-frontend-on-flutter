import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  LatLng _currentLocation = const LatLng(33.6844, 73.0479); // Default location

  LatLng get currentLocation => _currentLocation;

  void updateLocation(LatLng location) {
    _currentLocation = location;
    notifyListeners();
  }
}