import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PersonCard.dart';
import 'VideoMatchingPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application de Carte d\'Identité',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InputPage1(),
    );
  }
}

class InputPage1 extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage1> {
  final TextEditingController _nniController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Person? person; // Variable pour stocker l'objet Person
  bool isLoading = false;

  void fetchPersonInfo() async {
    setState(() {
      isLoading = true;
    });

    var url =
        'http://192.168.1.141:8000/appecash/fetch-person-info/?nni=${_nniController.text}&numero_tel=${_phoneController.text}';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var decodedData = utf8.decode(response.bodyBytes);
      var jsonData = json.decode(decodedData);

      if (jsonData.containsKey('person')) {
        setState(() {
          person = Person.fromJson(jsonData['person']);
          isLoading = false;
        });
      } else {
        setState(() {
          person = null;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        person = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saisir vos informations'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nniController,
              decoration: InputDecoration(
                labelText: 'NNI',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de Téléphone',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchPersonInfo,
              child: Text('Rechercher'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : person != null
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: PersonCard(person: person!),
                        ),
                      )
                    : Text('No person found or error occurred'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoMatchingPage()),
                );
              },
              child: Text('Go to Video Matching'),
            ),
          ],
        ),
      ),
    );
  }
}
