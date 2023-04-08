// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart'
    show FlutterGoogleStreetView, StreetViewSource, StreetViewController;

import 'package:campusmap/main.dart' show THEME;

const String SIT =
    "CAoSLEFGMVFpcE4tLTl2NFFuQndobjdzaXhOSFpPQlhzQkcwUUxBWF9lbVdDajdJ";
const String CSdept =
    "CAoSLEFGMVFpcE5QZG1fV1c4OUlnTmh0VEh6LXRUUjdrV3AtUWYxNUVDNEVxYUJu";

List<String> mapAnchors = [SIT, CSdept];
List<String> mapNames = ["Admin Block", "CS Department"];
List<double> mapAngles = [90, -130];

TextStyle listMaps = TextStyle(
  color: THEME[1],
  fontSize: 16,
  fontStyle: FontStyle.italic,
);

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
      body: Stack(
        children: [
          FlutterGoogleStreetView(
            initPanoId: mapAnchors[panID],
            initSource: StreetViewSource.outdoor,
            initBearing: mapAngles[panID],
            zoomGesturesEnabled: true,
            onStreetViewCreated: (StreetViewController controller) async {},
          ),
          Positioned(
            top: 50.0,
            left: 12.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: THEME[0],
              foregroundColor: THEME[1],
              child: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            top: 50.0,
            right: 12.0,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        backgroundColor: THEME[0],
                        title: Column(
                          children: [
                            Text(
                              "Jump To",
                              style: TextStyle(
                                color: THEME[1],
                              ),
                            ),
                            Divider(
                              height: 10,
                              color: THEME[1],
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
              foregroundColor: THEME[1],
              backgroundColor: THEME[2],
              child: const Icon(
                Icons.map_outlined,
              ),
            ),
          )
        ],
      ),
    );
  }
}
