import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

// SINGLETON
class LanguageServices {
  static final LanguageServices _instance = LanguageServices._internal();

  factory LanguageServices() {
    return _instance;
  }

  LanguageServices._internal() {}

  final _translator = GoogleTranslator();

  // [language]:[key]
  final Map<String, String> _masterLanguageMap = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'nl': 'Dutch',
    'haw': 'Hawaiian',
    'pt': 'Portuguese',
    'el': 'Greek',
    'it': 'Italian',
    'ga': 'Irish',
    'ja': 'Japanese',
    'hi': 'Hindi',
    'ar': 'Arabic',
    'hr': 'Croatian',
    'pl': 'Polish',
    'sv': 'Swedish',
    'no': 'Norwegian',
    'fi': 'Finnish',
    'id': 'Indonesian',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'ko': 'Korean',
    'cy': 'Welsh',
    'yi': 'Yiddish',
    'ru': 'Russian',
    'sr': 'Serbian',
    'ur': 'Urdu',
    'tr': 'Turkish',
    'af': 'Afrikaans',
    'hy': 'Armenian',
    'bg': 'Bulgarian',
    'fil': 'Tagalog',
    'he': 'Hebrew',
    'la': 'Latin',
    'ne': 'Nepali',
    'sm': 'Samoan',
    'so': 'Somali',
    'zu': 'Zulu',
  };

  // Default
  String _currentLanguageCode = 'en';
  String _currentLanguage = 'English';
  bool _translationNeeded = false;

  // Start Screen
  String startScreenTitle = 'Location Alerts';
  String startScreenExplainer = 'Phone alerts based on your current location!';
  String startScreenLocationToggle = 'Allow My Location:';
  String startScreenCreateAlert = 'Create Alert';
  String startScreenViewAlerts = 'View my Alerts';
  String startScreenLocationDisclosure = 'LocationDisclosure';
  String startScreenSignature = 'An App by Cedric Eicher';
  List<String> _startScreenList = [];

  // New Alert (Specific Screen) Screen

  // My Alerts Screen

  // Map View Screen

  // Edit Alert Screen

  // Pick On Map Screen

  // Side Drawer

  // Disclosures

  Future<bool> checkTranslationStatus() async {
    formLists();
    // Do this here since initLanguage bypasses with 'en' selected
    // Translate master language list
    _currentLanguage = (await _translator.translate(_currentLanguage,
            to: _currentLanguageCode))
        .text;
    _masterLanguageMap.forEach((code, language) async {
      _masterLanguageMap[code] =
          (await _translator.translate(language, to: code)).text;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // First time
    if (prefs.getBool('translationNeeded') == null) {
      prefs.setBool('translationNeeded', false);
    } else {
      _translationNeeded = prefs.getBool('translationNeeded')!;
    }
    return _translationNeeded;
  }

  Future<bool> initLanguage() async {
    await fetchCurrentLanguage();
    if (_currentLanguageCode != 'en') {
      await loadLanguageTranslations();
    }
    return true;
  }

  void formLists() {
    // Start Screen
    _startScreenList = [
      startScreenTitle,
      startScreenExplainer,
      startScreenLocationToggle,
      startScreenCreateAlert,
      startScreenViewAlerts,
      startScreenLocationDisclosure,
      startScreenSignature,
    ];
    // New Alert (Specific Screen) Screen

    // My Alerts Screen

    // Map View Screen

    // Edit Alert Screen

    // Pick On Map Screen

    // Side Drawer

    // Disclosures
  }

  Future<bool> fetchCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // First time
    if (prefs.getString('currentLanguage') == null) {
      prefs.setString('currentLanguage', _currentLanguageCode);
    } else {
      _currentLanguageCode = prefs.getString('currentLanguage')!;
    }
    _currentLanguage = _masterLanguageMap[_currentLanguageCode]!;
    return true;
  }

  Future<bool> loadLanguageTranslations() async {
    // Start Screen
    for (int index = 0; index < _startScreenList.length; ++index) {
      _startScreenList[index] = (await _translator
              .translate(_startScreenList[index], to: _currentLanguageCode))
          .text;
    }
    resetGettersStartScreen(_startScreenList);
    // New Alert (Specific Screen) Screen

    // My Alerts Screen

    // Map View Screen

    // Edit Alert Screen

    // Pick On Map Screen

    // Side Drawer

    // Disclosures

    // Reset translation flag
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('translationNeeded', false);

    return true;
  }

  // Start Screen
  void resetGettersStartScreen(List<String> newVars) {
    startScreenTitle = newVars[0];
    startScreenExplainer = newVars[1];
    startScreenLocationToggle = newVars[2];
    startScreenCreateAlert = newVars[3];
    startScreenViewAlerts = newVars[4];
    startScreenLocationDisclosure = newVars[5];
    startScreenSignature = newVars[6];
  }

  // New Alert (Specific Screen) Screen

  // My Alerts Screen

  // Map View Screen

  // Edit Alert Screen

  // Pick On Map Screen

  // Side Drawer

  // Disclosures

  void setNewLanguage(String newLanguage) async {
    String newLanguageCode = getLanguageCode(newLanguage);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentLanguage', newLanguageCode);
    prefs.setBool('translationNeeded', true);
  }

  List<String> getLanguageList() {
    List<String> languageListWithCurrentLanguageFirst = [];
    _masterLanguageMap.forEach((code, language) {
      languageListWithCurrentLanguageFirst.add(language);
    });
    String currentLanguage = '';
    for (int index = 0;
        index < languageListWithCurrentLanguageFirst.length;
        ++index) {
      if (_currentLanguage == languageListWithCurrentLanguageFirst[index]) {
        currentLanguage = languageListWithCurrentLanguageFirst[index];
      }
    }
    if (languageListWithCurrentLanguageFirst.remove(currentLanguage)) {
      languageListWithCurrentLanguageFirst.insertAll(0, [currentLanguage]);
    }
    return capitalizeFirstLetter(languageListWithCurrentLanguageFirst);
  }

  List<String> capitalizeFirstLetter(List<String> list) {
    for (int index = 0; index < list.length; ++index) {
      if (!(list[0].isEmpty)) {
        list[index] = list[index][0].toUpperCase() + list[index].substring(1);
      }
    }
    return list;
  }

  String getCurrentLanguage() {
    return _currentLanguage;
  }

  String getLanguageCode(String language) {
    // Query map
    return _masterLanguageMap.keys
        .firstWhere((code) => _masterLanguageMap[code] == language);
  }
}
