import 'package:flutter/material.dart';
import 'package:campusmap/free_view.dart';
import 'package:panorama/panorama.dart';
import 'package:campusmap/fmaps.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.map,
            ),
            title: const Text(
              "Free View",
            ),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FreeView()),
                );
              },
              icon: const Icon(Icons.join_right_sharp),
            ),
          ),
          ListTile(
            title: const Text("Panaroma"),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Temp()),
                );
              },
              icon: const Icon(Icons.join_right_sharp),
            ),
          ),
          ListTile(
            title: const Text("Directions"),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapView()),
                );
              },
              icon: const Icon(Icons.join_right_sharp),
            ),
          ),
        ],
      ),
    );
  }
}

class Temp extends StatelessWidget {
  const Temp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Panorama(
          sensitivity: 2,
          child: Image.network(
              "https://e4youth.org/wp-content/uploads/2019/02/eifelcover.jpg"),
        ),
      ),
    );
  }
}
