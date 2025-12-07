import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';

// To run this script:
// 1. Make sure you have your firebase_options.dart file configured.
// 2. Run `dart pub add cloud_firestore firebase_core` in your terminal.
// 3. Run `dart run scripts/upload_businesses.dart` from the root of your project.

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final businessesJson = await File('assets/data/businesses.json').readAsString();
  final businesses = jsonDecode(businessesJson) as List<dynamic>;

  print('Starting to upload ${businesses.length} businesses...');

  for (var businessData in businesses) {
    final id = businessData['id'] as String;
    if (id.isNotEmpty) {
      print('Uploading ${businessData['name']}...');
      await firestore.collection('businesses').doc(id).set(businessData as Map<String, dynamic>);
    } else {
      print('Skipping a business with no ID.');
    }
  }

  print('\n[32m✓ Successfully uploaded all businesses to Firestore![0m');
}
