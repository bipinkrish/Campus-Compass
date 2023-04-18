// ignore_for_file: constant_identifier_names, must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart'
    show FlutterGoogleStreetView, StreetViewSource, StreetViewController;
import 'package:flutter/cupertino.dart'
    show
        showCupertinoModalPopup,
        CupertinoTheme,
        CupertinoThemeData,
        CupertinoActionSheet,
        CupertinoActionSheetAction;
import 'package:campusmap/presets/values.dart' show INFO;

FloatingActionButton getFreeView(
    List<Color> THEME, translations, BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FreeView(
                  THEME: THEME,
                  translations: translations,
                )),
      );
    },
    backgroundColor: THEME[0],
    foregroundColor: THEME[1],
    child: const Icon(
      Icons.streetview_rounded,
    ),
  );
}

class FreeView extends StatefulWidget {
  List<Color> THEME;
  Map translations;
  FreeView({required this.THEME, required this.translations, super.key});

  @override
  State<FreeView> createState() => _FreeViewState();
}

class _FreeViewState extends State<FreeView> {
  int panID = 1;
  late StreetViewController streetMapController;
  String _mapName = INFO[1]["name"];
  String _mapAnchor = INFO[1]["pid"];
  double _mapAngle = INFO[1]["angle"].toDouble();

  void updateValues(List<Map<String, dynamic>> filteredInfo, int i) {
    setState(() {
      panID = INFO.indexOf(filteredInfo[i]);
      _mapAnchor = INFO[panID]["pid"];
      _mapName = INFO[panID]["name"];
      _mapAngle = INFO[panID]["angle"].toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterGoogleStreetView(
            initPanoId: _mapAnchor,
            initSource: StreetViewSource.outdoor,
            initBearing: _mapAngle,
            zoomGesturesEnabled: true,
            onStreetViewCreated: (StreetViewController controller) {
              streetMapController = controller;
            },
          ),
          // back button
          Positioned(
            top: 50,
            left: 12,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: widget.THEME[0],
              foregroundColor: widget.THEME[1],
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          // name panel
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 55, bottom: 20, left: 10, right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: widget.THEME[0],
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _mapName,
                          style: TextStyle(
                            color: widget.THEME[1],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                    List<Map<String, dynamic>> filteredInfo = List.from(INFO);
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return CupertinoTheme(
                          data: const CupertinoThemeData(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // search bar
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 120, left: 10, right: 10, bottom: 10),
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: TextField(
                                    style: TextStyle(
                                      color: widget.THEME[1],
                                    ),
                                    cursorColor: widget.THEME[3],
                                    decoration: InputDecoration(
                                      hintStyle:
                                          TextStyle(color: widget.THEME[3]),
                                      hintText: widget.translations["seacrh"] ??
                                          "Search",
                                      prefixIconColor: widget.THEME[1],
                                      prefixIcon:
                                          const Icon(Icons.search_rounded),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        borderSide: BorderSide(
                                          color: widget.THEME[0],
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        borderSide: BorderSide(
                                          color: widget.THEME[1],
                                          width: 2,
                                        ),
                                      ),
                                      fillColor: widget.THEME[2],
                                      filled: true,
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        filteredInfo = INFO
                                            .where((info) => info["name"]
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                      });
                                    },
                                  ),
                                ),
                              ),
                              // list
                              Expanded(
                                child: SingleChildScrollView(
                                  child: CupertinoActionSheet(
                                    actions: filteredInfo.isEmpty
                                        ? [
                                            Material(
                                              type: MaterialType.transparency,
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    widget.translations[
                                                            "nrf"] ??
                                                        "No Results Found",
                                                    style: TextStyle(
                                                        color: widget.THEME[1]),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]
                                        : List<Widget>.generate(
                                            filteredInfo.length,
                                            (int i) =>
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(
                                                  () => updateValues(
                                                      filteredInfo, i),
                                                );
                                              },
                                              child: Text(
                                                filteredInfo[i]["name"],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontStyle: FontStyle.italic,
                                                  color: widget.THEME[1],
                                                ),
                                              ),
                                            ),
                                          ),
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        widget.translations["cancel"] ??
                                            "Cancel",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: widget.THEME[1],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              foregroundColor: widget.THEME[1],
              backgroundColor: widget.THEME[0],
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
