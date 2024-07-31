import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoMatchingPage extends StatefulWidget {
  @override
  _VideoMatchingPageState createState() => _VideoMatchingPageState();
}

class _VideoMatchingPageState extends State<VideoMatchingPage> {
  bool isMatching = false;
  String matchResult = 'No match yet';
  final TextEditingController nniController = TextEditingController();

  void startMatching() async {
    setState(() {
      isMatching = true;
      matchResult = 'Matching in progress...';
    });

    String nni = nniController.text;
    var url = 'http://192.168.56.1:8000/appecash/match-face/?nni=$nni';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        matchResult = data[
            'message']; // Assuming the backend sends a 'message' key with the result
        isMatching = false;
      });
    } else {
      setState(() {
        matchResult = 'Failed to match face: ${response.body}';
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
                onPressed: isMatching ? null : startMatching,
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
