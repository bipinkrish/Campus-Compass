// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names

import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:campusmap/views/home_map.dart' show MapView;

// THEME
List<Color> THEME = const [
  Color.fromARGB(255, 52, 53, 65),
  Color.fromARGB(255, 251, 251, 254),
  Color.fromARGB(255, 42, 43, 52),
  Color.fromARGB(255, 125, 126, 131),
];

// apikey
const API_KEY = "AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(microseconds: 4200000),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MapView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: THEME[0],
      child: Image.asset("assets/logos/logoanim.gif"),
    );
  }
}
