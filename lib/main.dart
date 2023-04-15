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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Add a theme with a default page transition animation
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MapView(),
    );
  }
}
