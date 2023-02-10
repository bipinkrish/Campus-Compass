import 'package:flutter/material.dart';
import 'package:campusmap/free_view.dart';
import 'package:campusmap/fmaps.dart';
import 'package:campusmap/themedata.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme[0],
      appBar: AppBar(
        backgroundColor: theme[2],
        elevation: 3,
        title: Text(
          "Campus Compass",
          style: TextStyle(color: theme[1], fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.map,
              color: theme[1],
            ),
            title: Text(
              "Free View",
              style: TextStyle(
                color: theme[1],
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FreeView()),
                );
              },
              icon: Icon(
                Icons.join_right_sharp,
                color: theme[1],
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Directions",
              style: TextStyle(
                color: theme[1],
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapView()),
                );
              },
              icon: Icon(
                Icons.join_right_sharp,
                color: theme[1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
