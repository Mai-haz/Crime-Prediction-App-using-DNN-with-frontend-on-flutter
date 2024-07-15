import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flask API Demo',
      theme: ThemeData(
        primarySwatch: Colors.green, // Set the primary color to green
      ),
      home: const IntegrateDataset(),
    );
  }
}

class IntegrateDataset extends StatefulWidget {
  const IntegrateDataset({super.key});

  @override
  _IntegrateDatasetState createState() => _IntegrateDatasetState();
}

class _IntegrateDatasetState extends State<IntegrateDataset> {
  Uint8List imageBytes = Uint8List(0);
  TextEditingController dayController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController areaController = TextEditingController();

  Future<void> _sendPostRequest() async {
    String apiUrl = 'http://172.16.54.68:5000/predict'; // Adjust endpoint accordingly

    Map<String, String> headers = {"Content-type": "application/json"};
    String json = jsonEncode({
      "day": dayController.text,
      "city": cityController.text,
      "area": areaController.text,
    });
    print('Req_data: $json');
    try {
      print('Making HTTP request to: $apiUrl');
      final response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: json);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes;
          print('Printing the image bytes');
          print(imageBytes);
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crime Statistics'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'Day'),
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area'),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _sendPostRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Set the button color to green
                    ),
                    child: const Text('Predict'),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: imageBytes.isNotEmpty
                        ? Image.memory(imageBytes)
                        : Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
