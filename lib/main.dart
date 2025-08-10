import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:trendtalks/get_started_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDlS78vN4Wnuesg78Bs2JaJLL4SccFMirI",
          appId: "1:528947180469:android:7d31553b2fdc3345cd9ffc",
          messagingSenderId: "528947180469",
          projectId: "fx-auth-squad",
          storageBucket: "fx-auth-squad.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetStartedPage(),
    );
    
  }
}
