import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Import recording.dart file

class UserProfile {
  String userId = '';
  String name = '';
  String gender = '';
  String cnic = '';
  String address = '';
  String email = '';
  String phoneNumber = '';
  List<String> emergencyContacts = ['', ''];
  String city = '';
  String profilePicUrl = '';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'cnic': cnic,
      'address': address,
      'email': email,
      'phoneNumber': phoneNumber,
      'emergencyContacts': emergencyContacts,
      'city': city,
      'profilePicUrl': profilePicUrl,
    };
  }
}

class CustomUserProfilePage extends StatefulWidget {
  const CustomUserProfilePage({super.key});

  @override
  _CustomUserProfilePageState createState() => _CustomUserProfilePageState();
}

class _CustomUserProfilePageState extends State<CustomUserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  UserProfile userProfile = UserProfile();
  File? _image;
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.green,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (userProfile.profilePicUrl.isNotEmpty
                        ? NetworkImage(userProfile.profilePicUrl) as ImageProvider<Object>?
                        : null),
                    radius: 50,
                    child: _image == null && userProfile.profilePicUrl.isEmpty ? const Icon(Icons.camera_alt) : null,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.name = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.wc),
                    const SizedBox(width: 10),
                    const Text('Gender', style: TextStyle(fontSize: 16)),
                    Radio(value: 'Male', groupValue: _selectedGender, onChanged: _handleGenderChange),
                    const Text('Male'),
                    Radio(value: 'Female', groupValue: _selectedGender, onChanged: _handleGenderChange),
                    const Text('Female'),
                  ],
                ),

                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'CNIC', prefixIcon: Icon(Icons.credit_card)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.cnic = value;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.address = value;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.email = value;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.phoneNumber = value;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.city = value;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Emergency Contact 1', prefixIcon: Icon(Icons.phone)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.emergencyContacts[0] = value;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter emergency contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Emergency Contact 2', prefixIcon: Icon(Icons.phone)),
                  onChanged: (value) {
                    setState(() {
                      userProfile.emergencyContacts[1] = value;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter emergency contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                  ),
                  child: const Text('Save'),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGenderChange(String? value) {
    setState(() {
      _selectedGender = value;
      userProfile.gender = value ?? '';
    });
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('user_profiles/${userProfile.userId}/profile_pic.jpg');
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        userProfile.profilePicUrl = downloadUrl;
      });
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  void saveProfile() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference userProfilesRef = FirebaseDatabase.instance.reference().child('user_profiles');
    userProfilesRef.child(userId).set(userProfile.toJson()).then((_) {
      print('Profile saved successfully');
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to save profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save profile. Please try again later.'),
      ));
    });
  }
}
