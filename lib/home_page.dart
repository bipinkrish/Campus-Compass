import 'package:flutter/material.dart';

import 'package:campusmap/street_view.dart' show FreeView;
import 'package:campusmap/directions_map.dart' show MapView;
import 'package:campusmap/main.dart' show theme;
import 'package:campusmap/language_texts.dart' show getLanguage, setLanguage, languages, languagCodes;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String>? _translations;
  late List<String> names;

  List classes = const [
    FreeView(),
    MapView(),
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
    names = [
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
                    color: theme[0],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_rounded,
                          color: theme[3],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _translations!["settings"] ?? "Settings",
                          style: TextStyle(
                              color: theme[1],
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: theme[0],
                  hint: Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: theme[0],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        _translations!["languages"] ?? "Languages",
                        style: TextStyle(
                          color: theme[0],
                        ),
                      ),
                    ],
                  ),
                  items: [
                    for (int i = 0; i < languages.length; i++)
                      DropdownMenuItem(
                        value: languagCodes[i],
                        child: Center(
                          child: Text(
                            languages[i],
                            style: TextStyle(
                              color: theme[1],
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
              tileColor: theme[0],
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: theme[3],
                    ),
                    Text(
                      _translations!["close"] ?? "Close",
                      style: TextStyle(color: theme[1]),
                    ),
                    Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: theme[3],
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
      backgroundColor: theme[0],
      appBar: AppBar(
        backgroundColor: theme[2],
        elevation: 3,
        title: Text(
          _translations!["app_title"] ?? "Campus Compass",
          style: TextStyle(
            color: theme[1],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < names.length; i++)
            ListTile(
              title: Text(
                names[i],
                style: TextStyle(
                  color: theme[1],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => classes[i]),
                );
              },
              trailing: Icon(
                Icons.arrow_right_rounded,
                color: theme[1],
              ),
            ),
        ],
      ),
    );
  }
}
