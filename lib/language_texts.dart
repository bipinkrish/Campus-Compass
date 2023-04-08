// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

const List<String> LANGUAGES = [
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

const List<String> LANGUAGE_CODES = [
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
    "start": "Start",
    "csp": "Choose starting point",
    "destination": "Destination",
    "cd": "Choose destination",
  },
  "kn": {
    "app_title": "ಕ್ಯಾಂಪಸ್ ಕಂಪಾಸ್",
    "close": "ಮುಚ್ಚಿ",
    "settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
    "languages": "ಭಾಷೆಗಳು",
    "street_view": "ಗಲ್ಲಿ ವೀಕ್ಷಣೆ",
    "directions": "ದಿಕ್ಕುಗಳ",
    "distance": "ದೂರತೆ",
    "km": "ಕಿಮೀ",
    "dcs": "ದೂರತೆ ಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಗಣನೆ ಮಾಡಲಾಗಿದೆ",
    "ecd": "ದೂರತೆಯನ್ನು ಗಣನೆ ಮಾಡುವಾಗ ತಪ್ಪಾಗಿದೆ",
    "start": "ಪ್ರಾರಂಭ",
    "csp": "ಆರಂಭದ ಪಾರ್ಟ್ ಆಯ್ಕೆಮಾಡಿ",
    "destination": "ಗಮನಿಸುವಲ್ಲಿದೆ",
    "cd": "ಗಮನಿಸುವಲ್ಲಿದೆ ಆಯ್ಕೆಮಾಡಿ",
  },
  "hi": {
    "app_title": "कैंपस कंपास",
    "close": "बंद करें",
    "settings": "सेटिंग्स",
    "languages": "भाषाएँ",
    "street_view": "सड़क दृश्य",
    "directions": "दिशाएँ",
    "distance": "दूरी",
    "km": "किलोमीटर",
    "dcs": "दूरी सफलतापूर्वक हिसाब लिखी गई",
    "ecd": "दूरी की गणना करते समय त्रुटि हुई",
    "start": "प्रारंभ",
    "csp": "शुरुआती बिंदु चुनें",
    "destination": "गंतव्य",
    "cd": "गंतव्य चुनें",
  },
  "te": {
    "app_title": "క్యాంపస్ కంపాస్",
    "close": "దగ్గరకు",
    "settings": "సెట్టింగ్లు",
    "languages": "భాషలు",
    "street_view": "వీధి వీక్షణ",
    "directions": "దిశలు",
    "distance": "దూరం",
    "km": "కిలోమీటర్లు",
    "dcs": "దూరం వినియోగం పూర్తయింది",
    "ecd": "దూరం లెక్కించుకోడం లోపం కలిగింది",
    "start": "தொடங்கு",
    "csp": "தொடங்குவதற்கு புள்ளி குறியீடுகள்",
    "destination": "இலக்கு",
    "cd": "இலக்கை தேர்வு செய்க",
  },
  "ta": {
    "app_title": "கம்பஸ் கம்பாஸ்",
    "close": "மூடு",
    "settings": "அமைப்புகள்",
    "languages": "மொழிகள்",
    "street_view": "தொங்கு காட்சி",
    "directions": "திசைகள்",
    "distance": "தூரம்",
    "km": "கிலோமீட்டர்",
    "dcs": "தூரம் வெற்றிகரமாக கணக்கிடப்பட்டத",
    "ecd": "தூரம் கணக்கிடும் போது பிழை ஏற்பட்டது",
    "start": "தொடங்கு",
    "csp": "தொடங்குவதற்கு புள்ளி குறியீடுகள்",
    "destination": "இலக்கு",
    "cd": "இலக்கை தேர்வு செய்க",
  },
  "ml": {
    "app_title": "കമ്പാസ്",
    "close": "അടയ്ക്കുക",
    "settings": "ക്രമീകരണങ്ങൾ",
    "languages": "ഭാഷകൾ",
    "street_view": "വഴികാട്ടി",
    "directions": "ദിശകൾ",
    "distance": "ദൂരം",
    "km": "കി.മീ.",
    "dcs": "ദൂരം വിജയകരമായി കണക്കാക്കപ്പെട്ടു",
    "ecd": "ദൂരം കണക്കാക്കുന്നതിൽ പിഴവ് സംഭവിച്ചു",
    "start": "ആരംഭിക്കുക",
    "csp": "ആരംഭം തിരഞ്ഞെടുക്കുക",
    "destination": "ലക്ഷ്യസ്ഥാനം",
    "cd": "ലക്ഷ്യസ്ഥാനം തിരഞ്ഞെടുക്കുക",
  },
  "es": {
    "app_title": "Brújula del Campus",
    "close": "Cerrar",
    "settings": "Configuración",
    "languages": "Idiomas",
    "street_view": "Vista de la calle",
    "directions": "Direcciones",
    "distance": "Distancia",
    "km": "km",
    "dcs": "Distancia Calculada Exitosamente",
    "ecd": "Error al Calcular la Distancia",
    "start": "Inicio",
    "csp": "Elija el punto de inicio",
    "destination": "Destino",
    "cd": "Elija el destino",
  },
  "fr": {
    "app_title": "Boussole du Campus",
    "close": "Fermer",
    "settings": "Paramètres",
    "languages": "Langues",
    "street_view": "Vue de la rue",
    "directions": "Directions",
    "distance": "Distance",
    "km": "km",
    "dcs": "Distance Calculée avec Succès",
    "ecd": "Erreur de Calcul de Distance",
    "start": "Départ",
    "csp": "Choisir le point de départ",
    "destination": "Destination",
    "cd": "Choisir la destination"
  },
  "de": {
    "app_title": "Campus-Kompass",
    "close": "Schließen",
    "settings": "Einstellungen",
    "languages": "Sprachen",
    "street_view": "Straßenansicht",
    "directions": "Wegbeschreibungen",
    "distance": "Entfernung",
    "km": "km",
    "dcs": "Entfernung erfolgreich berechnet",
    "ecd": "Fehler bei der Berechnung der Entfernung",
    "start": "Start",
    "csp": "Startpunkt auswählen",
    "destination": "Ziel",
    "cd": "Ziel auswählen",
  }
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
