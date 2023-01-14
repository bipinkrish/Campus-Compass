// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

// Constants

const String SIT =
    "CAoSLEFGMVFpcE4tLTl2NFFuQndobjdzaXhOSFpPQlhzQkcwUUxBWF9lbVdDajdJ";
const String CSdept =
    "CAoSLEFGMVFpcE5QZG1fV1c4OUlnTmh0VEh6LXRUUjdrV3AtUWYxNUVDNEVxYUJu";

List<String> mapAnchors = [SIT, CSdept];
List<String> mapNames = ["Admin Block", "CS Department"];
List<double> mapAngles = [90, -130];

TextStyle listMaps = const TextStyle(fontSize: 14, fontStyle: FontStyle.italic);

// Class

class FreeView extends StatefulWidget {
  const FreeView({super.key});

  @override
  State<FreeView> createState() => _FreeViewState();
}

class _FreeViewState extends State<FreeView> {
  int panID = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: const Text("Jump To"),
                  children: [
                    for (int i = 0; i < 2; i++)
                      SimpleDialogOption(
                        child: Text(
                          mapNames[i],
                          style: listMaps,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            panID = i;
                          });
                        },
                      ),
                  ],
                );
              });
        },
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.map_outlined,
        ),
      ),
      body: SafeArea(
        child: FlutterGoogleStreetView(
          initPanoId: mapAnchors[panID],
          initSource: StreetViewSource.outdoor,
          initBearing: mapAngles[panID],
          zoomGesturesEnabled: true,
          onStreetViewCreated: (StreetViewController controller) async {},
        ),
      ),
    );
  }
}
