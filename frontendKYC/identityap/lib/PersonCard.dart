import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Person {
  final int id;
  final String nni;
  final String numeroTel;
  final String dateNaissance;
  final String img_url; // Utiliser img_url au lieu de img
  Uint8List? img_memory;
  final String lieuNaissanceAr;
  final String lieuNaissanceFr;
  final String nationaliteIso;
  final String nomFamilleAr;
  final String nomFamilleFr;
  final String prenomAr;
  final String prenomFr;
  final String prenomPereAr;
  final String prenomPereFr;
  final String sexeFr;

  Person({
    required this.id,
    required this.nni,
    required this.numeroTel,
    required this.dateNaissance,
    required this.img_url, // Utiliser img_url au lieu de img
    required this.lieuNaissanceAr,
    required this.lieuNaissanceFr,
    required this.nationaliteIso,
    required this.nomFamilleAr,
    required this.nomFamilleFr,
    required this.prenomAr,
    required this.prenomFr,
    required this.prenomPereAr,
    required this.prenomPereFr,
    required this.sexeFr,
    this.img_memory,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      nni: json['NNI'],
      numeroTel: json['numero_tel'],
      dateNaissance: json['date_naissance'],
      img_url: json['img_url'], // Utiliser img_url
      lieuNaissanceAr: json['lieu_naissance_ar'],
      lieuNaissanceFr: json['lieu_naissance_fr'],
      nationaliteIso: json['nationalite_iso'],
      nomFamilleAr: json['nom_famille_ar'],
      nomFamilleFr: json['nom_famille_fr'],
      prenomAr: json['prenom_ar'],
      prenomFr: json['prenom_fr'],
      prenomPereAr: json['prenom_pere_ar'],
      prenomPereFr: json['prenom_pere_fr'],
      sexeFr: json['sexe_fr'],
      img_memory: json.containsKey('image_memory')
          ? base64Decode(json['image_memory'])
          : null,
    );
  }
}

class PersonCard extends StatelessWidget {
  final Person person;

  PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NNI: ${person.nni}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Numéro de Téléphone: ${person.numeroTel}'),
            Text('Date de Naissance: ${person.dateNaissance}'),
            person.img_url.isNotEmpty
                ? Image.network(person.img_url)
                : Container(),
            Text('Lieu de Naissance (Ar): ${person.lieuNaissanceAr}'),
            Text('Lieu de Naissance (Fr): ${person.lieuNaissanceFr}'),
            Text('Nationalité: ${person.nationaliteIso}'),
            Text('Nom de Famille (Ar): ${person.nomFamilleAr}'),
            Text('Nom de Famille (Fr): ${person.nomFamilleFr}'),
            Text('Prénom (Ar): ${person.prenomAr}'),
            Text('Prénom (Fr): ${person.prenomFr}'),
            Text('Prénom du Père (Ar): ${person.prenomPereAr}'),
            Text('Prénom du Père (Fr): ${person.prenomPereFr}'),
            Text('Sexe: ${person.sexeFr}'),
          ],
        ),
      ),
    );
  }
}
