// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:campusmap/themedata.dart';

// Constants

const String SIT =
    "CAoSLEFGMVFpcE4tLTl2NFFuQndobjdzaXhOSFpPQlhzQkcwUUxBWF9lbVdDajdJ";
const String CSdept =
    "CAoSLEFGMVFpcE5QZG1fV1c4OUlnTmh0VEh6LXRUUjdrV3AtUWYxNUVDNEVxYUJu";

List<String> mapAnchors = [SIT, CSdept];
List<String> mapNames = ["Admin Block", "CS Department"];
List<double> mapAngles = [90, -130];

TextStyle listMaps = TextStyle(
  color: theme[1],
  fontSize: 14,
  fontStyle: FontStyle.italic,
);

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
      appBar: AppBar(
        backgroundColor: theme[0],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  backgroundColor: theme[0],
                  title: Column(
                    children: [
                      Text(
                        "Jump To",
                        style: TextStyle(
                          color: theme[1],
                        ),
                      ),
                      Divider(
                        height: 15,
                        color: theme[1],
                      )
                    ],
                  ),
                  children: [
                    for (int i = 0; i < mapNames.length; i++)
                      ListTile(
                        title: Center(
                          child: Text(
                            mapNames[i],
                            style: listMaps,
                          ),
                        ),
                        onTap: () {
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
        foregroundColor: theme[1],
        backgroundColor: theme[2],
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
