// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, library_private_types_in_public_api, camel_case_types, must_be_immutable, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:campusmap/language_texts.dart'
    show setLanguage, LANGUAGES, LANGUAGE_CODES;

// -----------------------------------------------------------------------------------------------

Drawer getDrawer(
    THEME, _translations, BuildContext context, _loadTranslationsAndLang) {
  return Drawer(
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
              borderRadius: BorderRadius.circular(10),
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
                    _translations!["language"] ?? "Language",
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
                setLanguage(value ?? "en");
                _loadTranslationsAndLang();
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
  );
}

// -----------------------------------------------------------------------------------------------

FloatingActionButton getMenuButton(THEME, BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      Scaffold.of(context).openDrawer();
    },
    backgroundColor: THEME[0],
    foregroundColor: THEME[1],
    child: const Icon(
      Icons.menu_rounded,
    ),
  );
}
