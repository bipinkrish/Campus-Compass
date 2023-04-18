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
    "language": "Language",
    "distance": "Distance",
    "km": "km",
    "dfs": "Direction Found Successfully",
    "efd": "Error Finding Direction",
    "destination": "Destination",
    "cd": "Choose destination",
    "sec": "sec",
    "nrf": 'No Results Found',
    "du" : "Destination Updated",
    "cancel" : "Cancel",
    "search" : "Search",
  },
  "kn": {
    "app_title": "ಕ್ಯಾಂಪಸ್ ಕಂಪಾಸ್",
    "close": "ಮುಚ್ಚು",
    "settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
    "language": "ಭಾಷೆ",
    "distance": "ದೂರತೆ",
    "km": "ಕಿ.ಮೀ",
    "dfs": "ದಿಕ್ಕೆ ಸಫಲವಾಗಿ ಕಂಡುಹಿಡಿದಿದೆ",
    "efd": "ದಿಕ್ಕೆ ಹುಡುಕಲು ತಪ್ಪಾಗಿದೆ",
    "destination": "ಗಮನಿಸಬೇಕಾದ ಸ್ಥಳ",
    "cd": "ಗಮನಿಸಬೇಕಾದ ಸ್ಥಳವನ್ನು ಆರಿಸಿ",
    "sec": "ಸೆಕೆಂ",
    "nrf": "ಯಾವುದೇ ಫಲಿತಾಂಶಗಳು ಸಿಗಲಿಲ್ಲ",
    "du" : "ಗಮನಿಸಬೇಕಾದ ಸ್ಥಳ ನವೀಕರಣಗೊಂಡಿದೆ",
    "cancel" : "ರದ್ದುಮಾಡಿ",
    "search" : "ಹುಡುಕು",
  },
  "hi": {
    "app_title": "कैंपस कंपास",
    "close": "बंद करें",
    "settings": "सेटिंग्स",
    "language": "भाषा",
    "distance": "दूरी",
    "km": "कि.मी",
    "dfs": "दिशा सफलतापूर्वक मिल गई",
    "efd": "दिशा ढूंढने में त्रुटि",
    "destination": "गंतव्य",
    "cd": "गंतव्य चुनें",
    "sec": "सेक",
    "nrf" : "कोई परिणाम नहीं मिला",
    'du' : "गंतव्य अपडेट हो गया है",
    "cancel" : "रद्द करें",
    "search" : "खोज",
  },
};

void setLanguage(String lang) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lang', lang);
}

Future<Map<String, String>> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return TRANSLATIONS[prefs.getString("lang") ?? "en"] ?? TRANSLATIONS["en"]!;
}

Future<String> getLanguageCode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("lang") ?? "en";
}
