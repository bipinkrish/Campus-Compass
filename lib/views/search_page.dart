// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:campusmap/presets/values.dart' show Destinations;

Map<String, IconData> IconsPacks = {
  "place": Icons.school_rounded,
  "building": Icons.location_city_rounded,
  "laboratory": Icons.science_rounded,
  "playground": Icons.sports_cricket_rounded,
  "library": Icons.local_library_rounded,
  "canteen" : Icons.restaurant_rounded,
  "temple" : Icons.temple_hindu_rounded,
  "parking" : Icons.local_parking_rounded,
};

TextField getTextField({
  required TextEditingController controller,
  required FocusNode focusNode,
  required String label,
  required String hint,
  required IconButton prefixIcon,
  required Function(String) locationCallback,
  required THEME,
  required hasValue,
}) {
  return TextField(
    onChanged: (value) {
      locationCallback(value);
    },
    style: TextStyle(
      color: THEME[1],
    ),
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(
        color: THEME[3],
      ),
      filled: true,
      fillColor: THEME[0],
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(
          color: THEME[0],
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(
          color: THEME[1],
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.all(2),
      hintText: hint,
      hintStyle: TextStyle(color: THEME[3]),
      suffixIcon: hasValue
          ? GestureDetector(
              onTap: () {
                controller.clear();
                locationCallback("");
              },
              child: Icon(
                Icons.clear,
                color: THEME[3],
              ),
            )
          : Icon(
              Icons.place_rounded,
              color: THEME[1],
            ),
    ),
    cursorColor: THEME[3],
  );
}

class SearchPage extends StatefulWidget {
  TextEditingController controller;
  FocusNode focusNode;
  Function(String, double, double) locationCallback;
  List THEME;
  Map translations;

  SearchPage({
    required this.controller,
    required this.focusNode,
    required this.locationCallback,
    required this.THEME,
    required this.translations,
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late bool hasValue;
  List filteredDestinations = List.from(Destinations);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.requestFocus();
    });
  }

  void filterDestinations(String query) {
    setState(() {
      filteredDestinations = Destinations.where((destination) {
        final name = destination['name'].toString().toLowerCase();
        final queryLowercase = query.toLowerCase();
        return name.contains(queryLowercase);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasValue = widget.controller.text.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        widget.locationCallback("", 0, 0);
        return true;
      },
      child: Scaffold(
        backgroundColor: widget.THEME[2],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 50, left: 10, right: 10, bottom: 0),
              child: Center(
                child: getTextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  label: widget.translations["destination"] ?? "Destination",
                  hint: widget.translations["cd"] ?? "Choose destination",
                  prefixIcon: IconButton(
                    onPressed: () {
                      widget.locationCallback("", 0, 0);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: widget.THEME[1],
                    ),
                  ),
                  locationCallback: filterDestinations,
                  THEME: widget.THEME,
                  hasValue: hasValue,
                ),
              ),
            ),
            filteredDestinations.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "No Results Found",
                      style: TextStyle(
                        color: widget.THEME[1],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredDestinations.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: ListTile(
                            iconColor: widget.THEME[1],
                            textColor: widget.THEME[1],
                            tileColor: widget.THEME[0],
                            leading: Icon(
                              IconsPacks[filteredDestinations[index]['type']] ??
                                  Icons.abc_rounded,
                            ),
                            title: Text(
                              filteredDestinations[index]['name'],
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              widget.locationCallback(
                                filteredDestinations[index]['name'],
                                filteredDestinations[index]['coordinates'][1],
                                filteredDestinations[index]['coordinates'][0],
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
