import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

// SINGLETON
class LanguageServices {
  static final LanguageServices _instance = LanguageServices._internal();

  final _translator = GoogleTranslator();
  final List<String> _masterLanguageList = [
    'English',
    'Spanish',
    'French',
    'German'
  ];
  final List<String> _masterLanguageCodeList = ['en', 'es', 'fr', 'de'];
  final Map<String, String> _masterLanguageMap = {}; // [code]:[language]

  String _currentLanguageCode = 'en';
  String _currentLanguage = 'English';

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

  factory LanguageServices() {
    return _instance;
  }

  LanguageServices._internal() {
    formMap();
    fetchCurrentLanguage();
    formLists();
    //loadLanguageTranslations(false, 'en');

    // DEBUG
    loadLanguageTranslations(true, 'es');
  }

  void formMap() {
    for (int index = 0; index < _masterLanguageList.length; ++index) {
      _masterLanguageMap[_masterLanguageCodeList[index]] =
          _masterLanguageList[index];
    }
  }

  void fetchCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('currentLanguage') == null) {
      prefs.setString('currentLanguage', _currentLanguageCode);
    } else {
      _currentLanguageCode = prefs.getString('currentLanguage')!;
    }
    _currentLanguage = _masterLanguageMap[_currentLanguageCode]!;
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

  void newLanguage(String newLanguage) async {
    loadLanguageTranslations(true, newLanguage);
  }

  void loadLanguageTranslations(
      bool newLanguageTranslations, String newLanguage) async {
    // New language check
    if (newLanguageTranslations) {
      _currentLanguageCode = newLanguage;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('currentLanguage', newLanguage);
    }
    // Translate master language list
    _currentLanguage = (await _translator.translate(_currentLanguage,
            to: _currentLanguageCode))
        .text;
    for (int index = 0; index < _masterLanguageList.length; ++index) {
      _masterLanguageList[index] = (await _translator.translate(
              _masterLanguageList[index],
              to: _masterLanguageCodeList[index]))
          .text;
    }
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

  List<String> getLanguageList() {
    List<String> languageListWithCurrentLanguageFirst = _masterLanguageList;
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

  String getCurrentLanguage() {
    return _currentLanguage;
  }

  List<String> capitalizeFirstLetter(List<String> list) {
    for (int index = 0; index < list.length; ++index) {
      if (!(list[0].isEmpty)) {
        list[0] = list[0][0].toUpperCase() + list[0].substring(1);
      }
    }
    return list;
  }
}
