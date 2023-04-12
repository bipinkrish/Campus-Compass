// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

const List<String> LANGUAGES = [
  "English",
  "ಕನ್ನಡ",
  "हिंदी",
];

const List<String> LANGUAGE_CODES = [
  "en",
  "kn",
  "hi",
];

const Map<String, Map<String, String>> TRANSLATIONS = {
  "en": {
    "app_title": "Campus Compass",
    "close": "Close",
    "settings": "Settings",
    "languages": "Languages",
    "street_view": "Street View",
    "directions": "Directions",
    "distance": "Distance",
    "km": "km",
    "dcs": "Distance Calculated Sucessfully",
    "ecd": "Error Calculating Distance",
    "destination": "Destination",
    "cd": "Choose destination",
    "sec":"sec"
  },
  "kn": {
    "app_title": "ಕ್ಯಾಂಪಸ್ ಕಂಪಾಸ್",
    "close": "ಮುಚ್ಚಿ",
    "settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
    "languages": "ಭಾಷೆಗಳು",
    "street_view": "ಗಲ್ಲಿ ವೀಕ್ಷಣೆ",
    "directions": "ದಿಕ್ಕುಗಳ",
    "distance": "ದೂರತೆ",
    "km": "ಕಿ.ಮೀ",
    "dcs": "ದೂರತೆ ಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಗಣನೆ ಮಾಡಲಾಗಿದೆ",
    "ecd": "ದೂರತೆಯನ್ನು ಗಣನೆ ಮಾಡುವಾಗ ತಪ್ಪಾಗಿದೆ",
    "destination": "ಗಮನಿಸುವಲ್ಲಿದೆ",
    "cd": "ಗಮನಿಸುವಲ್ಲಿದೆ ಆಯ್ಕೆಮಾಡಿ",
    "sec":"ಸೆಕೆಂ"
  },
  "hi": {
    "app_title": "कैंपस कंपास",
    "close": "बंद करें",
    "settings": "सेटिंग्स",
    "languages": "भाषाएँ",
    "street_view": "सड़क दृश्य",
    "directions": "दिशाएँ",
    "distance": "दूरी",
    "km": "कि.मी",
    "dcs": "दूरी सफलतापूर्वक हिसाब लिखी गई",
    "ecd": "दूरी की गणना करते समय त्रुटि हुई",
    "destination": "गंतव्य",
    "cd": "गंतव्य चुनें",
    "sec":"सेक"
  },
};

void setLanguage(String lang) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lang', lang);
}

Future<Map<String, String>?> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return TRANSLATIONS[prefs.getString("lang") ?? "en"];
}

Future<String> getLanguageCode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("lang") ?? "en";
}
