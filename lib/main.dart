
import 'package:flutter/material.dart';
import 'dart:async';
import 'userProfile.dart';
import 'emergency.dart';
import 'statistics_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
  print(message.notification!.title.toString() );
  print(message.notification!.body.toString() );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocationProvider(), // Initialize the Location Provider
      child: const SafetyGuardianApp(),
    ),
  );
}

class SafetyGuardianAppState extends State<SafetyGuardianApp> {
  User? user;
  @override

  void initState() {
    super.initState();
    // Add any initialization logic here
    user= FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(user: user),
        '/home': (context) => const HomePage(),
        '/user_profile': (context) => const UserProfilePage(),
        '/emergency': (context) => const EmergencyPage(),
        '/statistics': (context) => const IntegrateDataset(),
        '/signup': (context) => SignupPage(),
        '/login' : (context) => LoginPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
    );
  }



  @override
  void dispose() {
    // Dispose logic, if any
    super.dispose();
  }
}

class SafetyGuardianApp extends StatefulWidget {
  const SafetyGuardianApp({super.key});

  @override
  SafetyGuardianAppState createState() => SafetyGuardianAppState();
}



class SplashScreen extends StatefulWidget {
  final User? user;

  const SplashScreen({super.key, required this.user});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(

      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // Repeat the animation

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.user != null ?   const HomePage(): LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animation,
              child: Image.asset(
                'logo.png',
                height: 150, // Increase the size of the logo
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'GUARDIAN SAFETY APP',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'YourInterestingFont',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value){
        print('device token:');
        print(value);
        print('end');

    });
  }
  late GoogleMapController _controller;
  LatLng _center = const LatLng(33.6844, 73.0479); // Islamabad coordinates
  String _searchAddress = 'Islamabad, Pakistan';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _searchLocation(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      setState(() {
        _center = LatLng(locations[0].latitude, locations[0].longitude);
        _searchAddress = query;
      });
      _controller.animateCamera(CameraUpdate.newLatLng(_center));
          Fluttertoast.showToast(msg: '📍$query');
    } else {
      Fluttertoast.showToast(msg: 'Location not found');
    }
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _searchAddress = 'My Current Location';
      });
      _controller.animateCamera(CameraUpdate.newLatLngZoom(_center, 15));
          Fluttertoast.showToast(msg: '📍Current Location');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Safety App'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navigate to the login page when logout button is pressed
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: _searchLocation,
              decoration: InputDecoration(
                hintText: 'Search location',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _searchLocation(_searchAddress);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('1'),
                  position: _center,
                  infoWindow: InfoWindow(title: _searchAddress),
                ),
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the emergency features page.
                Navigator.pushNamed(context, '/emergency');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Emergency'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the emergency features page.
                Navigator.pushNamed(context, '/statistics');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('View Statistics'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the user profile page and pass the userId as arguments
                Navigator.pushNamed(context, '/user_profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('User Profile'),
            ),
          ],
        ),
      ),
    );
  }
}