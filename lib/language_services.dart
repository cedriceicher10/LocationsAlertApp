import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

// SINGLETON
class LanguageServices {
  static final LanguageServices _instance = LanguageServices._internal();

  final _translator = GoogleTranslator();
  String _currentLanguage = 'en';

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
    fetchCurrentLanguage();
    formLists();
    //loadLanguageTranslations(false, 'en');
    // DEBUG
    loadLanguageTranslations(true, 'es');
  }

  void fetchCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('currentLanguage') == null) {
      prefs.setString('currentLanguage', _currentLanguage);
    } else {
      _currentLanguage = prefs.getString('currentLanguage')!;
    }
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
  }

  void newLanguage(String newLanguage) async {
    loadLanguageTranslations(true, newLanguage);
  }

  void loadLanguageTranslations(
      bool newLanguageTranslations, String newLanguage) async {
    // New language check
    if (newLanguageTranslations) {
      _currentLanguage = newLanguage;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('currentLanguage', newLanguage);
    }
    // Start Screen
    for (int index = 0; index < _startScreenList.length; ++index) {
      _startScreenList[index] = (await _translator
              .translate(_startScreenList[index], to: _currentLanguage))
          .text;
    }
    resetGettersStartScreen(_startScreenList);
  }

  void resetGettersStartScreen(List<String> newVars) {
    startScreenTitle = newVars[0];
    startScreenExplainer = newVars[1];
    startScreenLocationToggle = newVars[2];
    startScreenCreateAlert = newVars[3];
    startScreenViewAlerts = newVars[4];
    startScreenLocationDisclosure = newVars[5];
    startScreenSignature = newVars[6];
  }
}
