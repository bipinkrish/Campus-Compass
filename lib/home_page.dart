import 'package:flutter/material.dart';

import 'package:campusmap/street_view.dart' show FreeView;
import 'package:campusmap/directions_map.dart' show MapView;
import 'package:campusmap/main.dart' show theme;

List<String> names = [
  "Street View",
  "Directions",
];

List classes = const [
  FreeView(),
  MapView(),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: theme[1],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme[0],
              ),
              child: const Text(""),
            ),
            ListTile(
              title: const Center(child: Text('Close')),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      backgroundColor: theme[0],
      appBar: AppBar(
        backgroundColor: theme[2],
        elevation: 3,
        title: Text(
          "Campus Compass",
          style: TextStyle(
            color: theme[1],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < names.length; i++)
            ListTile(
              title: Text(
                names[i],
                style: TextStyle(
                  color: theme[1],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => classes[i]),
                );
              },
              trailing: Icon(
                Icons.arrow_right_rounded,
                color: theme[1],
              ),
            ),
        ],
      ),
    );
  }
}
