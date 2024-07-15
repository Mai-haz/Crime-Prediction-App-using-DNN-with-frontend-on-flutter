import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart'; // Import the country picker package

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';

  Future<void> _verifyPhoneNumber(BuildContext context) async {
    try {
      verificationCompleted(AuthCredential authCredential) {
        _auth.signInWithCredential(authCredential);
        Navigator.pushReplacementNamed(context, '/home');
      }

      verificationFailed(FirebaseAuthException authException) {
        print('Phone verification failed: ${authException.message}');
      }

      codeSent(String verificationId, [int? forceResendingToken]) {
        _verificationId = verificationId;
      }

      codeAutoRetrievalTimeout(String verificationId) {
        _verificationId = verificationId;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      print('Error verifying phone number: $e');
    }
  }

  Future<void> _signInWithPhoneNumber(BuildContext context) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Login successful, navigate to home page
        Navigator.pushReplacementNamed(context, '/home');

        // Show a success message (you can customize this)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Error signing in with phone number');
      }
    } catch (e) {
      print('Error signing in with phone number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Change app bar color to green
        title: const Text('Phone Login'),
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'logo.png', // Replace 'assets/logo.png' with your logo path
                height: 100, // Adjust the height of the logo as needed
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: GestureDetector(
                  onTap: () {
                    // Show country picker dialog
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        // Handle country selection
                        _phoneNumberController.text = '+${country.phoneCode}';
                      },
                    );
                  },
                  child: const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _verifyPhoneNumber(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Change button color to green
              ),
              child: const Text('Send OTP'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signInWithPhoneNumber(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Change button color to green
              ),
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}