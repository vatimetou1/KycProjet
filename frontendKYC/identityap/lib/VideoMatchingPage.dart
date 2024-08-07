import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:identityap/camera.dart';
import 'dart:convert';
import 'camera.dart';

class VideoMatchingPage extends StatefulWidget {
  @override
  _VideoMatchingPageState createState() => _VideoMatchingPageState();
}

class _VideoMatchingPageState extends State<VideoMatchingPage> {
  bool isMatching = false;
  String matchResult = 'No match yet';
  final TextEditingController nniController = TextEditingController();

  void startMatching(String imagePath) async {
    if (!mounted) return;

    setState(() {
      isMatching = true;
      matchResult = 'Matching in progress...';
    });

    try {
      String nni = nniController.text;
      var url = 'http://192.168.1.141:8000/appecash/match-face/?nni=$nni';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = json.decode(responseBody);
        setState(() {
          matchResult = data[
              'message']; // Assuming the backend sends a 'message' key with the result
          isMatching = false;
        });
      } else {
        setState(() {
          matchResult = 'Failed to match face: $responseBody';
          isMatching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        matchResult = 'Failed to match face: $e';
        isMatching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Matching'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: nniController,
                decoration: InputDecoration(
                  labelText: 'Enter NNI',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isMatching
                    ? null
                    : () async {
                        final capturedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraPage()),
                        );

                        if (capturedImage != null) {
                          startMatching(capturedImage);
                        }
                      },
                child: Text('Start Matching'),
              ),
              SizedBox(height: 20),
              isMatching
                  ? CircularProgressIndicator()
                  : Text(
                      matchResult,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
