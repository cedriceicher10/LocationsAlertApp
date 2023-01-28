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

  // Create Alert (Specific Screen) Screen
  String createAlertTitle = 'Create Alert';
  String createAlertRemindMe = 'Remind me to...';
  String createAlertAtLocation = 'At the location...';
  String createAlertMyLocationButton = 'My Location';
  String createAlertPickOnMapButton = 'Pick on Map';
  String createAlertAtTrigger = 'At the trigger distance...';
  String createAlertCancelButton = 'Cancel';
  String createAlertCreateAlertButton = 'Create Alert';
  String createAlertReminderFieldEmpty = 'Please enter a reminder';
  String createAlertReminderTooLong =
      'Please shorten the reminder to less than 200 characters';
  String createAlertReminderHint = 'E.g. Pick up some limes';
  String createAlertLocationHint = 'E.g. Sprouts, Redlands, CA';
  String createAlertLocationEmpty = 'Please enter a location';
  String createAlertLocationTooLong =
      'Please shorten the reminder to less than 200 characters';
  String createAlertLocationNotFound =
      'Could not locate the location you entered. \nPlease be more specific.';
  List<String> _createAlertList = [];

  // My Alerts Screen

  // Map View Screen

  // Edit Alert Screen

  // Pick On Map Screen

  // Side Drawer

  // Disclosures

  // Units

  Future<bool> checkTranslationStatus() async {
    formLists();
    await fetchCurrentLanguage();
    // Do this here since initLanguage bypasses with 'en' selected
    // Translate master language list
    _currentLanguage = (await _translator.translate(_currentLanguage,
            to: _currentLanguageCode))
        .text;
    _masterLanguageMap.forEach((code, language) async {
      _masterLanguageMap[code] = capitalizeFirstLetter(
          (await _translator.translate(language, to: code)).text);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // First time
    if (prefs.getBool('translationNeeded') == null) {
      prefs.setBool('translationNeeded', false);
    } else {
      _translationNeeded = prefs.getBool('translationNeeded')!;
    }
    // Check for cached language translations
    if ((_translationNeeded) || (_currentLanguageCode != 'en')) {
      if (prefs.getStringList(_currentLanguageCode + '-startScreenList') ==
          null) {
        return true;
      } else {
        // Retrieve cached language translations and assign
        await retrieveCachedTranslations();
        return false;
      }
    }
    return false;
  }

  Future<bool> retrieveCachedTranslations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Start Screen
    _startScreenList =
        prefs.getStringList(_currentLanguageCode + '-startScreenList')!;
    resetGettersStartScreen(_startScreenList);

    // Create Alert (Specific Screen) Screen
    _createAlertList =
        prefs.getStringList(_currentLanguageCode + '-createAlertList')!;
    resetGettersCreateAlert(_createAlertList);

    // My Alerts Screen

    // Map View Screen

    // Edit Alert Screen

    // Pick On Map Screen

    // Side Drawer

    // Disclosures

    // Units

    return true;
  }

  Future<bool> translate() async {
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
    // Create Alert (Specific Screen) Screen
    _createAlertList = [
      createAlertTitle,
      createAlertRemindMe,
      createAlertAtLocation,
      createAlertMyLocationButton,
      createAlertPickOnMapButton,
      createAlertAtTrigger,
      createAlertCancelButton,
      createAlertCreateAlertButton,
      createAlertReminderFieldEmpty,
      createAlertReminderTooLong,
      createAlertReminderHint,
      createAlertLocationHint,
      createAlertLocationEmpty,
      createAlertLocationTooLong,
      createAlertLocationNotFound,
    ];

    // My Alerts Screen

    // Map View Screen

    // Edit Alert Screen

    // Pick On Map Screen

    // Side Drawer

    // Disclosures

    // Units
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Start Screen
    for (int index = 0; index < _startScreenList.length; ++index) {
      _startScreenList[index] = (await _translator
              .translate(_startScreenList[index], to: _currentLanguageCode))
          .text;
    }
    resetGettersStartScreen(_startScreenList);
    prefs.setStringList(
        _currentLanguageCode + '-startScreenList', _startScreenList);
    // Create Alert (Specific Screen) Screen
    for (int index = 0; index < _createAlertList.length; ++index) {
      _createAlertList[index] = (await _translator
              .translate(_createAlertList[index], to: _currentLanguageCode))
          .text;
    }
    resetGettersCreateAlert(_createAlertList);
    prefs.setStringList(
        _currentLanguageCode + '-createAlertList', _createAlertList);

    // My Alerts Screen

    // Map View Screen

    // Edit Alert Screen

    // Pick On Map Screen

    // Side Drawer

    // Disclosures

    // Units

    // Reset translation flag
    prefs = await SharedPreferences.getInstance();
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

  // Create Alert (Specific Screen) Screen
  void resetGettersCreateAlert(List<String> newVars) {
    createAlertTitle = newVars[0];
    createAlertRemindMe = newVars[1];
    createAlertAtLocation = newVars[2];
    createAlertMyLocationButton = newVars[3];
    createAlertPickOnMapButton = newVars[4];
    createAlertAtTrigger = newVars[5];
    createAlertCancelButton = newVars[6];
    createAlertCreateAlertButton = newVars[7];
    createAlertReminderFieldEmpty = newVars[8];
    createAlertReminderTooLong = newVars[9];
    createAlertReminderHint = newVars[10];
    createAlertLocationHint = newVars[11];
    createAlertLocationEmpty = newVars[12];
    createAlertLocationTooLong = newVars[13];
    createAlertLocationNotFound = newVars[14];
  }

  // My Alerts Screen

  // Map View Screen

  // Edit Alert Screen

  // Pick On Map Screen

  // Side Drawer

  // Disclosures

  // Units

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
    return languageListWithCurrentLanguageFirst;
  }

  String capitalizeFirstLetter(String language) {
    return language[0].toUpperCase() + language.substring(1);
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
