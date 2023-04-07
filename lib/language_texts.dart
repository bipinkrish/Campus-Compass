import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

List<String> languages = [
  "English",
  "ಕನ್ನಡ",
  "हिंदी",
  "తెలుగు",
  "தமிழ்",
  "മലയാളം",
  "Español",
  "Français",
  "Deutsch"
];

List<String> languagCodes = [
  "en",
  "kn",
  "hi",
  "te",
  "ta",
  "ml",
  "es",
  "fr",
  "de"
];

const Map<String, Map<String, String>> translations = {
  "en": {
    "app_title": "Campus Compass",
    "close": "Close",
    "settings": "Settings",
    "languages": "Languages",
    "street_view": "Street View",
    "directions": "Directions"
  },
  "kn": {
    "app_title": "ಕ್ಯಾಂಪಸ್ ಕಂಪಾಸ್",
    "close": "ಮುಚ್ಚಿ",
    "settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
    "languages": "ಭಾಷೆಗಳು",
    "street_view": "ಗಲ್ಲಿ ವೀಕ್ಷಣೆ",
    "directions": "ದಿಕ್ಕುಗಳ"
  },
  "hi": {
    "app_title": "कैंपस कंपास",
    "close": "बंद करें",
    "settings": "सेटिंग्स",
    "languages": "भाषाएँ",
    "street_view": "सड़क दृश्य",
    "directions": "दिशाएँ"
  },
  "te": {
    "app_title": "క్యాంపస్ కంపాస్",
    "close": "దగ్గరకు",
    "settings": "సెట్టింగ్లు",
    "languages": "భాషలు",
    "street_view": "వీధి వీక్షణ",
    "directions": "దిశలు"
  },
  "ta": {
    "app_title": "கம்பஸ் கம்பாஸ்",
    "close": "மூடு",
    "settings": "அமைப்புகள்",
    "languages": "மொழிகள்",
    "street_view": "தொங்கு காட்சி",
    "directions": "திசைகள்"
  },
  "ml": {
    "app_title": "കമ്പാസ്",
    "close": "അടയ്ക്കുക",
    "settings": "ക്രമീകരണങ്ങൾ",
    "languages": "ഭാഷകൾ",
    "street_view": "വഴികാട്ടി",
    "directions": "ദിശകൾ"
  },
  "es": {
    "app_title": "Brújula del Campus",
    "close": "Cerrar",
    "settings": "Configuración",
    "languages": "Idiomas",
    "street_view": "Vista de la calle",
    "directions": "Direcciones"
  },
  "fr": {
    "app_title": "Boussole du Campus",
    "close": "Fermer",
    "settings": "Paramètres",
    "languages": "Langues",
    "street_view": "Vue de la rue",
    "directions": "Directions"
  },
  "de": {
    "app_title": "Campus-Kompass",
    "close": "Schließen",
    "settings": "Einstellungen",
    "languages": "Sprachen",
    "street_view": "Straßenansicht",
    "directions": "Wegbeschreibungen"
  }
};

void setLanguage(String lang) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lang', lang);
}

Future<Map<String, String>?> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return translations[prefs.getString("lang") ?? "en"];
}
