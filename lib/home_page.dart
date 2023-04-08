// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'package:campusmap/street_view.dart' show FreeView;
import 'package:campusmap/directions_map.dart' show MapView;
import 'package:campusmap/main.dart' show THEME;
import 'package:campusmap/language_texts.dart'
    show getLanguage, setLanguage, LANGUAGES, LANGUAGE_CODES;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String>? _translations;
  late List<String> LIST_NAMES;

  List CLASSES = const [
    FreeView(),
    MapView(),
  ];

  List<IconData> ICONS_LIST = const [
    Icons.streetview_rounded,
    Icons.directions_walk_rounded
  ];

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  void _loadTranslations() async {
    Map<String, String>? translations = await getLanguage();
    setState(() {
      _translations = translations;
    });
  }

  void _setLanguage(String lang) async {
    setLanguage(lang);
    _loadTranslations();
  }

  @override
  Widget build(BuildContext context) {
    LIST_NAMES = [
      _translations!["street_view"] ?? "Street View",
      _translations!["directions"] ?? "Directions",
    ];

    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: THEME[0],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_rounded,
                          color: THEME[3],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _translations!["settings"] ?? "Settings",
                          style: TextStyle(
                              color: THEME[1],
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: THEME[0],
                  hint: Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: THEME[0],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        _translations!["languages"] ?? "Languages",
                        style: TextStyle(
                          color: THEME[0],
                        ),
                      ),
                    ],
                  ),
                  items: [
                    for (int i = 0; i < LANGUAGES.length; i++)
                      DropdownMenuItem(
                        value: LANGUAGE_CODES[i],
                        child: Center(
                          child: Text(
                            LANGUAGES[i],
                            style: TextStyle(
                              color: THEME[1],
                            ),
                          ),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _setLanguage(value ?? "en");
                    });
                  },
                ),
              ],
            ),
            ListTile(
              tileColor: THEME[0],
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: THEME[3],
                    ),
                    Text(
                      _translations!["close"] ?? "Close",
                      style: TextStyle(color: THEME[1]),
                    ),
                    Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: THEME[3],
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      backgroundColor: THEME[0],
      appBar: AppBar(
        backgroundColor: THEME[2],
        elevation: 3,
        title: Text(
          _translations!["app_title"] ?? "Campus Compass",
          style: TextStyle(
            color: THEME[1],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < LIST_NAMES.length; i++)
            ListTile(
              leading: Icon(
                ICONS_LIST[i],
                color: THEME[1],
              ),
              title: Text(
                LIST_NAMES[i],
                style: TextStyle(
                  color: THEME[1],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CLASSES[i]),
                );
              },
              trailing: Icon(
                Icons.arrow_right_rounded,
                color: THEME[1],
              ),
            ),
        ],
      ),
    );
  }
}
