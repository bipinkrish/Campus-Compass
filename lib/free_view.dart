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
  fontSize: 16,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
                        height: 10,
                        color: theme[1],
                      )
                    ],
                  ),
                  children: [
                    for (int i = 0; i < mapNames.length; i++)
                      SizedBox(
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              panID = i;
                            });
                          },
                          child: Center(
                            child: Text(
                              mapNames[i],
                              style: listMaps,
                            ),
                          ),
                        ),
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
        child: Stack(
          children: [
            FlutterGoogleStreetView(
              initPanoId: mapAnchors[panID],
              initSource: StreetViewSource.outdoor,
              initBearing: mapAngles[panID],
              zoomGesturesEnabled: true,
              onStreetViewCreated: (StreetViewController controller) async {},
            ),
            Positioned(
              top: 10.0,
              left: 10.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: theme[0],
                foregroundColor: theme[1],
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
