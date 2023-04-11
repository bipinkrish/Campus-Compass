// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart'
    show FlutterGoogleStreetView, StreetViewSource, StreetViewController;

import 'package:campusmap/main.dart' show THEME;
import 'package:campusmap/values.dart' show mapAnchors, mapAngles, mapNames;

class FreeView extends StatefulWidget {
  const FreeView({super.key});

  @override
  State<FreeView> createState() => _FreeViewState();
}

class _FreeViewState extends State<FreeView> {
  int panID = 1;

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
          // back button
          Positioned(
            top: 50,
            left: 12,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: THEME[0],
              foregroundColor: THEME[1],
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          // name panel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 55),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: THEME[0],
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        mapNames[panID],
                        style: TextStyle(
                            color: THEME[1],
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // destination button
          Positioned(
            top: 50,
            right: 12,
            child: FloatingActionButton(
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoTheme(
                      data: const CupertinoThemeData(),
                      child: CupertinoActionSheet(
                        actions: List<Widget>.generate(
                          mapNames.length,
                          (int i) => CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                panID = i;
                              });
                            },
                            child: Text(
                              mapNames[i],
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: THEME[1],
                              ),
                            ),
                          ),
                        ),
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: THEME[1],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              foregroundColor: THEME[1],
              backgroundColor: THEME[2],
              child: const Icon(
                Icons.map_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
