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
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'am': 'Amharic',
    'ar': 'Arabic',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'eu': 'Basque',
    'be': 'Belarusian',
    'bn': 'Bengali',
    'bs': 'Bosnian',
    'bg': 'Bulgarian',
    'ca': 'Catalan',
    'ceb': 'Cebuano',
    'ny': 'Chichewa',
    'zh-cn': 'Chinese Simplified',
    'zh-tw': 'Chinese Traditional',
    'co': 'Corsican',
    'hr': 'Croatian',
    'cs': 'Czech',
    'da': 'Danish',
    'nl': 'Dutch',
    'eo': 'Esperanto',
    'et': 'Estonian',
    'tl': 'Filipino',
    'fi': 'Finnish',
    'fr': 'French',
    'fy': 'Frisian',
    'gl': 'Galician',
    'ka': 'Georgian',
    'de': 'German',
    'el': 'Greek',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'iw': 'Hebrew',
    'hi': 'Hindi',
    'hmn': 'Hmong',
    'hu': 'Hungarian',
    'is': 'Icelandic',
    'ig': 'Igbo',
    'id': 'Indonesian',
    'ga': 'Irish',
    'it': 'Italian',
    'ja': 'Japanese',
    'jw': 'Javanese',
    'kn': 'Kannada',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'ko': 'Korean',
    'ku': 'Kurdish (Kurmanji)',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'la': 'Latin',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'ms': 'Malay',
    'ml': 'Malayalam',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar (Burmese)',
    'ne': 'Nepali',
    'no': 'Norwegian',
    'ps': 'Pashto',
    'fa': 'Persian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'pa': 'Punjabi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sm': 'Samoan',
    'gd': 'Scots Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'es': 'Spanish',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'sv': 'Swedish',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'te': 'Telugu',
    'th': 'Thai',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'uz': 'Uzbek',
    'ug': 'Uyghur',
    'vi': 'Vietnamese',
    'cy': 'Welsh',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu',
  };

  // Default
  double _languageScale = 1.0;
  String _currentLanguageCode = 'en';
  String _currentLanguage = 'English';
  bool _translationNeeded = false;
  String _loading = 'Loading...';
  String _changingLanguageTitle = 'Changing Language\n to';
  String _changingLanguageBody =
      'This may take 2-3 minutes\nthe first time, if this\nis a new language';

  // Start Screen
  String startScreenTitle = 'Location Alerts';
  String startScreenExplainer = 'Phone alerts based on your current location!';
  String startScreenLocationToggle = 'Allow My Location:';
  String startScreenCreateAlert = 'Create Alert';
  String startScreenViewAlerts = 'View my Alerts';
  String startScreenLocationDisclosure = 'Location Disclosure';
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
  String restoreAlertsButton = 'Restore Previous Alerts';
  List<String> _createAlertList = [];

  // My Alerts Screen
  String myAlertsTitle = 'My Alerts';
  String myAlertsNoneYet = 'No alerts created yet!';
  String myAlertsExplainer =
      'These are your current active location alerts.\n Once an alert is marked as complete it will be removed.\n Tap an alert to edit it.';
  String myAlertsMapView = 'Map View';
  String myAlertsListView = 'List View';
  String myAlertsBackButton = 'Back';
  String myAlertsTileLocation = 'at';
  String myAlertsTileDate = 'Date Created';
  String myAlertsRestoreTitle = 'Completed Alerts';
  String myAlertsRestoreExplainer =
      'These are your previously completed alerts.\n Tap an alert to restore it.';
  String myAlertsRestoreNoneYet = 'No completed alerts yet!';
  List<String> _myAlertsList = [];

  // Map View Screen
  String mapViewTitle = 'My Alerts';
  String mapViewOSM = 'Maps courtesy of OpenStreetMap';
  String mapViewNoneYet = 'Create an alert to see it \non the map!';
  String mapViewNoAlertInformation = 'Alert Information Could Not Be Found!';
  String mapViewYourLocation = 'Your Location!';
  String mapViewTileLocation = 'at';
  String mapViewTileDate = 'Date Created';
  String mapViewCreateNewAlert = 'Create alert at this location?';
  List<String> _mapView = [];

  // Edit Alert Screen
  String editAlertTitle = 'Edit Alert';
  String editAlertRemindMe = 'Remind me to...';
  String editAlertAtLocation = 'At the location...';
  String editAlertMyLocationButton = 'My Location';
  String editAlertPickOnMapButton = 'Pick on Map';
  String editAlertMarkDoneButton = 'Mark Done';
  String editAlertDeleteButton = 'Delete Alert';
  String editAlertAtTrigger = 'At the trigger distance...';
  String editAlertCancelButton = 'Cancel';
  String editAlertUpdateAlertButton = 'Update Alert';
  String editAlertReminderFieldEmpty = 'Please enter a reminder';
  String editAlertReminderTooLong =
      'Please shorten the reminder to less than 200 characters';
  String editAlertReminderHint = 'E.g. Pick up some limes';
  String editAlertLocationHint = 'E.g. Sprouts, Redlands, CA';
  String editAlertLocationEmpty = 'Please enter a location';
  String editAlertLocationTooLong =
      'Please shorten the reminder to less than 200 characters';
  String editAlertLocationNotFound =
      'Could not locate the location you entered. \nPlease be more specific.';
  List<String> _editAlert = [];

  // Pick On Map Screen
  String pickOnMapTitle = 'Pick On Map';
  String pickOnMapSetAlertButton = 'Set Alert Location';
  String pickOnMapOSM = 'Maps courtesy of OpenStreetMap';
  List<String> _pickOnMap = [];

  // Side Drawer
  String sideDrawerTitle = 'Location Alerts';
  String sideDrawerDisclosureTitle = 'Disclosure';
  String sideDrawerDataDisclosureTitle = 'Data Disclosure';
  String sideDrawerAdsDisclosureTitle = 'Ads Disclosure';
  String sideDrawerAppTitle = 'App';
  String sideDrawerHowToUseTitle = 'How To Use This App';
  String sideDrawerPrivacyPolicyTitle = 'Privacy Policy';
  String sideDrawerAboutTitle = 'About';
  String sideDrawerCommunicateTitle = 'Communicate';
  String sideDrawerSendFeedbackTitle = 'Send Feedback';
  String sideDrawerRequestUserDataTitle = 'Request User Data';
  String sideDrawerLanguageTitle = 'Language';
  String sideDrawerChangeLanguageTitle = 'Change Language';
  String sideDrawerUserStatisticsTitle = 'User Statistics';
  String sideDrawerFirstLogin = 'First Login';
  String sideDrawerLastLogin = 'Last Login';
  String sideDrawerAlertsCreated = 'Alerts Created';
  String sideDrawerAlertsCompleted = 'Alerts Completed';
  String sideDrawerAlertsCompletion = 'Alerts Completion';
  String sideDrawerUserNo = 'User';
  String sideDrawerUuid = 'UUID';
  List<String> _sideDrawer = [];

  // Disclosures
  String disclosureDataTitle = 'Data Disclosure';
  String disclosureDataBody =
      'This app uses an encrypted cloud-based database (Google Firebase Cloud Firestore) to store your alerts and usage information. All data is strictly ANONYMOUS. No location or user data is tracked AT ANY TIME. \n\nA full user data dump may be requested at any time.';
  String disclosureAdsTitle = 'Ad Disclosure';
  String disclosureAdsBody =
      'This app uses Google Admob to serve interstitial ads between defined events in the app\'s use. These ads help fund the app\'s continued development and deployment.';
  String disclosureAboutTitle = 'About';
  String disclosureAboutBody =
      'Hello! My name is Cedric Eicher and I am the creator of this app. I love mobile development and this is one of my projects.\n\nIf you are enjoying this app, please consider leaving a review and feedback. Additionally, check out other CE Ventures apps like Simple Weather in the Google Play store.';
  String disclosureChangeLanguageTitle = 'Select Language';
  String disclosureChangeLanguageBody = 'Language';
  String disclosureChangeLanguageButton = 'Change Language';
  String dislcosureRestartRequired =
      'You must RESTART the app for this change to take effect.';
  String disclosureLinkedinButton = 'Visit my LinkedIn Page';
  String disclosureCloseButton = 'Close';
  String disclosureLocationTitle = 'Location Disclosure';
  String disclosureLocation =
      'Location Alerts collects background location data to deliver reminder alerts based on your location. This feature may be in use when the app is in the background or closed. \n\nLocation Alerts will ALWAYS ask your permission before turning on your location services.';
  String disclosureLocationDecline = 'Decline (No location services)';
  String disclosureLocationAccept = 'Acknowledge';
  String disclosureLocationOffTitle = 'Notice of Location Dismissal';
  String disclosureLocationOff =
      'To receive alerts based on your current location, tap on the Location Disclosure button at the bottom of the screen and Acknowledge.';
  String disclosureLocationOffClose = 'Close';
  List<String> _disclosure = [];

  // Recent Locations
  String recentLocationEmpty =
      'Make a few reminders to see their locations here!';
  List<String> _recentLocations = [];

  // Notifications
  String notificationsTitle = 'Location Alerts';
  String notificationsBody = 'Background services currently in progress';
  String notificationsMarkComplete = 'Mark Complete';
  String notificationsDismiss = 'Dismiss (next time)';
  List<String> _notifications = [];

  // Units
  String unitsMi = 'mi';
  String unitsKm = 'km';
  List<String> _unitsList = [];

  // Intro Slides
  String introSlidesGettingStartedTitle = 'Getting Started';
  String introSlidesGettingStartedDesc = 'Start by tapping Create Alert';
  String introSlidesCreatingAlertTitle = 'Creating an Alert';
  String introSlidesCreatingAlertDesc =
      '\nEnter what you want to be reminded about and where. Such as:\n\nGrab more sugar next time I\'m at my grocery store.';
  String introSlidesAlertTriggersTitle = 'Alert Triggers';
  String introSlidesAlertTriggersDesc =
      'After your alert is created, make sure the location toggle is ON and your location service is ACTIVE.\n\nThen just leave the app open in the background!';
  String introSlidesYourAlertsTitle = 'Your Alerts';
  String introSlidesYourAlertsDesc =
      'You can set multiple alerts for multiple locations! Let\'s get started!';
  List<String> _introSlides = [];

  Future<bool> init() async {
    await fetchCurrentLanguage();
    _loading =
        (await _translator.translate(_loading, to: _currentLanguageCode)).text;
    if (_currentLanguageCode != 'en') {
      _languageScale = 0.85;
    }
    return true;
  }

  Future<bool> checkTranslationStatus() async {
    formLists();
    // Changing language screen translations
    _changingLanguageTitle = (await _translator
            .translate(_changingLanguageTitle, to: _currentLanguageCode))
        .text;
    _changingLanguageBody = (await _translator.translate(_changingLanguageBody,
            to: _currentLanguageCode))
        .text;
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
      } else if (await isFullReTranslateNeeded()) {
        // Check if a full retranslate is necessary
        return true;
      } else {
        // Retrieve cached language translations and assign
        await retrieveCachedTranslations();
        return false;
      }
    }
    return false;
  }

  Future<bool> isFullReTranslateNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? updateFor_05312023 = prefs.getBool('updateFor_05312023');
    if (updateFor_05312023 == null) {
      prefs.setBool('updateFor_05312023', false);
      return true;
    } else {
      return updateFor_05312023;
    }
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
    _myAlertsList =
        prefs.getStringList(_currentLanguageCode + '-myAlertsList')!;
    resetGettersMyAlerts(_myAlertsList);

    // Map View Screen
    _mapView = prefs.getStringList(_currentLanguageCode + '-mapView')!;
    resetGettersMapView(_mapView);

    // Edit Alert Screen
    _editAlert = prefs.getStringList(_currentLanguageCode + '-editAlert')!;
    resetGettersEditAlert(_editAlert);

    // Pick On Map Screen
    _pickOnMap = prefs.getStringList(_currentLanguageCode + '-pickOnMap')!;
    resetGettersPickOnMap(_pickOnMap);

    // Side Drawer
    _sideDrawer = prefs.getStringList(_currentLanguageCode + '-sideDrawer')!;
    resetGettersSideDrawer(_sideDrawer);

    // Disclosures
    _disclosure = prefs.getStringList(_currentLanguageCode + '-disclosure')!;
    resetGettersDisclosure(_disclosure);

    // Recent Locations
    _recentLocations =
        prefs.getStringList(_currentLanguageCode + '-recentLocations')!;
    resetGettersRecentLocations(_recentLocations);

    // Notifications
    _notifications =
        prefs.getStringList(_currentLanguageCode + '-notifications')!;
    resetGettersNotifications(_notifications);

    // Units
    _unitsList = prefs.getStringList(_currentLanguageCode + '-unitsList')!;
    resetGettersUnits(_unitsList);

    // Intro Slides
    _introSlides = prefs.getStringList(_currentLanguageCode + '-introSlides')!;
    resetGettersIntroSlides(_introSlides);

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
      restoreAlertsButton,
    ];

    // My Alerts Screen
    _myAlertsList = [
      myAlertsTitle,
      myAlertsNoneYet,
      myAlertsExplainer,
      myAlertsMapView,
      myAlertsListView,
      myAlertsBackButton,
      myAlertsTileLocation,
      myAlertsTileDate,
      myAlertsRestoreTitle,
      myAlertsRestoreExplainer,
      myAlertsRestoreNoneYet,
    ];

    // Map View Screen
    _mapView = [
      mapViewTitle,
      mapViewOSM,
      mapViewNoneYet,
      mapViewNoAlertInformation,
      mapViewYourLocation,
      mapViewTileLocation,
      mapViewTileDate,
      mapViewCreateNewAlert,
    ];

    // Edit Alert Screen
    _editAlert = [
      editAlertTitle,
      editAlertRemindMe,
      editAlertAtLocation,
      editAlertMyLocationButton,
      editAlertPickOnMapButton,
      editAlertMarkDoneButton,
      editAlertDeleteButton,
      editAlertAtTrigger,
      editAlertCancelButton,
      editAlertUpdateAlertButton,
      editAlertReminderFieldEmpty,
      editAlertReminderTooLong,
      editAlertReminderHint,
      editAlertLocationHint,
      editAlertLocationEmpty,
      editAlertLocationTooLong,
      editAlertLocationNotFound,
    ];

    // Pick On Map Screen
    _pickOnMap = [
      pickOnMapTitle,
      pickOnMapSetAlertButton,
      pickOnMapOSM,
    ];

    // Side Drawer
    _sideDrawer = [
      sideDrawerTitle,
      sideDrawerDisclosureTitle,
      sideDrawerDataDisclosureTitle,
      sideDrawerAdsDisclosureTitle,
      sideDrawerAppTitle,
      sideDrawerHowToUseTitle,
      sideDrawerPrivacyPolicyTitle,
      sideDrawerAboutTitle,
      sideDrawerCommunicateTitle,
      sideDrawerSendFeedbackTitle,
      sideDrawerRequestUserDataTitle,
      sideDrawerLanguageTitle,
      sideDrawerChangeLanguageTitle,
      sideDrawerUserStatisticsTitle,
      sideDrawerFirstLogin,
      sideDrawerLastLogin,
      sideDrawerAlertsCreated,
      sideDrawerAlertsCompleted,
      sideDrawerAlertsCompletion,
      sideDrawerUserNo,
      sideDrawerUuid,
    ];

    // Disclosures
    _disclosure = [
      disclosureDataTitle,
      disclosureDataBody,
      disclosureAdsTitle,
      disclosureAdsBody,
      disclosureAboutTitle,
      disclosureAboutBody,
      disclosureChangeLanguageTitle,
      disclosureChangeLanguageBody,
      disclosureChangeLanguageButton,
      dislcosureRestartRequired,
      disclosureLinkedinButton,
      disclosureCloseButton,
      disclosureLocationTitle,
      disclosureLocation,
      disclosureLocationDecline,
      disclosureLocationAccept,
      disclosureLocationOffTitle,
      disclosureLocationOff,
      disclosureLocationOffClose,
    ];

    // Recent Locations
    _recentLocations = [
      recentLocationEmpty,
    ];

    // Notifications
    _notifications = [
      notificationsTitle,
      notificationsBody,
      notificationsMarkComplete,
      notificationsDismiss,
    ];

    // Units
    _unitsList = [unitsMi, unitsKm];

    // Intro Slides
    _introSlides = [
      introSlidesGettingStartedTitle,
      introSlidesGettingStartedDesc,
      introSlidesCreatingAlertTitle,
      introSlidesCreatingAlertDesc,
      introSlidesAlertTriggersTitle,
      introSlidesAlertTriggersDesc,
      introSlidesYourAlertsTitle,
      introSlidesYourAlertsDesc,
    ];
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
    for (int index = 0; index < _myAlertsList.length; ++index) {
      _myAlertsList[index] = (await _translator.translate(_myAlertsList[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersMyAlerts(_myAlertsList);
    prefs.setStringList(_currentLanguageCode + '-myAlertsList', _myAlertsList);

    // Map View Screen
    for (int index = 0; index < _mapView.length; ++index) {
      _mapView[index] = (await _translator.translate(_mapView[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersMapView(_mapView);
    prefs.setStringList(_currentLanguageCode + '-mapView', _mapView);

    // Edit Alert Screen
    for (int index = 0; index < _editAlert.length; ++index) {
      _editAlert[index] = (await _translator.translate(_editAlert[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersEditAlert(_editAlert);
    prefs.setStringList(_currentLanguageCode + '-editAlert', _editAlert);

    // Pick On Map Screen
    for (int index = 0; index < _pickOnMap.length; ++index) {
      _pickOnMap[index] = (await _translator.translate(_pickOnMap[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersPickOnMap(_pickOnMap);
    prefs.setStringList(_currentLanguageCode + '-pickOnMap', _pickOnMap);

    // Side Drawer
    for (int index = 0; index < _sideDrawer.length; ++index) {
      _sideDrawer[index] = (await _translator.translate(_sideDrawer[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersSideDrawer(_sideDrawer);
    prefs.setStringList(_currentLanguageCode + '-sideDrawer', _sideDrawer);

    // Disclosures
    for (int index = 0; index < _disclosure.length; ++index) {
      _disclosure[index] = (await _translator.translate(_disclosure[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersDisclosure(_disclosure);
    prefs.setStringList(_currentLanguageCode + '-disclosure', _disclosure);

    // Recent Locations
    for (int index = 0; index < _recentLocations.length; ++index) {
      _recentLocations[index] = (await _translator
              .translate(_recentLocations[index], to: _currentLanguageCode))
          .text;
    }
    resetGettersRecentLocations(_recentLocations);
    prefs.setStringList(
        _currentLanguageCode + '-recentLocations', _recentLocations);

    // Notifications
    for (int index = 0; index < _notifications.length; ++index) {
      _notifications[index] = (await _translator
              .translate(_notifications[index], to: _currentLanguageCode))
          .text;
    }
    resetGettersNotifications(_notifications);
    prefs.setStringList(
        _currentLanguageCode + '-notifications', _notifications);

    // Units
    for (int index = 0; index < _unitsList.length; ++index) {
      _unitsList[index] = (await _translator.translate(_unitsList[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersUnits(_unitsList);
    prefs.setStringList(_currentLanguageCode + '-unitsList', _unitsList);

    // Intro Slides
    for (int index = 0; index < _introSlides.length; ++index) {
      _introSlides[index] = (await _translator.translate(_introSlides[index],
              to: _currentLanguageCode))
          .text;
    }
    resetGettersIntroSlides(_introSlides);
    prefs.setStringList(_currentLanguageCode + '-introSlides', _introSlides);

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
    restoreAlertsButton = newVars[15];
  }

  // My Alerts Screen
  void resetGettersMyAlerts(List<String> newVars) {
    myAlertsTitle = newVars[0];
    myAlertsNoneYet = newVars[1];
    myAlertsExplainer = newVars[2];
    myAlertsMapView = newVars[3];
    myAlertsListView = newVars[4];
    myAlertsBackButton = newVars[5];
    myAlertsTileLocation = newVars[6];
    myAlertsTileDate = newVars[7];
    myAlertsRestoreTitle = newVars[8];
    myAlertsRestoreExplainer = newVars[9];
    myAlertsRestoreNoneYet = newVars[10];
  }

  // Map View Screen
  void resetGettersMapView(List<String> newVars) {
    mapViewTitle = newVars[0];
    mapViewOSM = newVars[1];
    mapViewNoneYet = newVars[2];
    mapViewNoAlertInformation = newVars[3];
    mapViewYourLocation = newVars[4];
    mapViewTileLocation = newVars[5];
    mapViewTileDate = newVars[6];
    mapViewCreateNewAlert = newVars[7];
  }

  // Edit Alert Screen
  void resetGettersEditAlert(List<String> newVars) {
    editAlertTitle = newVars[0];
    editAlertRemindMe = newVars[1];
    editAlertAtLocation = newVars[2];
    editAlertMyLocationButton = newVars[3];
    editAlertPickOnMapButton = newVars[4];
    editAlertMarkDoneButton = newVars[5];
    editAlertDeleteButton = newVars[6];
    editAlertAtTrigger = newVars[7];
    editAlertCancelButton = newVars[8];
    editAlertUpdateAlertButton = newVars[9];
    editAlertReminderFieldEmpty = newVars[10];
    editAlertReminderTooLong = newVars[11];
    editAlertReminderHint = newVars[12];
    editAlertLocationHint = newVars[13];
    editAlertLocationEmpty = newVars[14];
    editAlertLocationTooLong = newVars[15];
    editAlertLocationNotFound = newVars[16];
  }

  // Pick On Map Screen
  void resetGettersPickOnMap(List<String> newVars) {
    pickOnMapTitle = newVars[0];
    pickOnMapSetAlertButton = newVars[1];
    pickOnMapOSM = newVars[2];
  }

  // Side Drawer
  void resetGettersSideDrawer(List<String> newVars) {
    sideDrawerTitle = newVars[0];
    sideDrawerDisclosureTitle = newVars[1];
    sideDrawerDataDisclosureTitle = newVars[2];
    sideDrawerAdsDisclosureTitle = newVars[3];
    sideDrawerAppTitle = newVars[4];
    sideDrawerHowToUseTitle = newVars[5];
    sideDrawerPrivacyPolicyTitle = newVars[6];
    sideDrawerAboutTitle = newVars[7];
    sideDrawerCommunicateTitle = newVars[8];
    sideDrawerSendFeedbackTitle = newVars[9];
    sideDrawerRequestUserDataTitle = newVars[10];
    sideDrawerLanguageTitle = newVars[11];
    sideDrawerChangeLanguageTitle = newVars[12];
    sideDrawerUserStatisticsTitle = newVars[13];
    sideDrawerFirstLogin = newVars[14];
    sideDrawerLastLogin = newVars[15];
    sideDrawerAlertsCreated = newVars[16];
    sideDrawerAlertsCompleted = newVars[17];
    sideDrawerAlertsCompletion = newVars[18];
    sideDrawerUserNo = newVars[19];
    sideDrawerUuid = newVars[20];
  }

  // Disclosures
  void resetGettersDisclosure(List<String> newVars) {
    disclosureDataTitle = newVars[0];
    disclosureDataBody = newVars[1];
    disclosureAdsTitle = newVars[2];
    disclosureAdsBody = newVars[3];
    disclosureAboutTitle = newVars[4];
    disclosureAboutBody = newVars[5];
    disclosureChangeLanguageTitle = newVars[6];
    disclosureChangeLanguageBody = newVars[7];
    disclosureChangeLanguageButton = newVars[8];
    dislcosureRestartRequired = newVars[9];
    disclosureLinkedinButton = newVars[10];
    disclosureCloseButton = newVars[11];
    disclosureLocation = newVars[12];
    disclosureLocationDecline = newVars[13];
    disclosureLocationAccept = newVars[14];
    disclosureLocationOffTitle = newVars[15];
    disclosureLocationOff = newVars[16];
    disclosureLocationOffClose = newVars[17];
  }

  // Recent Locations
  void resetGettersRecentLocations(List<String> newVars) {
    recentLocationEmpty = newVars[0];
  }

  // Notifications
  void resetGettersNotifications(List<String> newVars) {
    notificationsTitle = newVars[0];
    notificationsBody = newVars[1];
    notificationsMarkComplete = newVars[2];
    notificationsDismiss = newVars[3];
  }

  // Units
  void resetGettersUnits(List<String> newVars) {
    unitsMi = newVars[0];
    unitsKm = newVars[1];
  }

  // Intro Slides
  void resetGettersIntroSlides(List<String> newVars) {
    introSlidesGettingStartedTitle = newVars[0];
    introSlidesGettingStartedDesc = newVars[1];
    introSlidesCreatingAlertTitle = newVars[2];
    introSlidesCreatingAlertDesc = newVars[3];
    introSlidesAlertTriggersTitle = newVars[4];
    introSlidesAlertTriggersDesc = newVars[5];
    introSlidesYourAlertsTitle = newVars[6];
    introSlidesYourAlertsDesc = newVars[7];
  }

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

  String getLoading() {
    return _loading;
  }

  String getChangingLanguageTitle() {
    return _changingLanguageTitle + ' ' + _currentLanguage + '...';
  }

  String getChangingLanguageBody() {
    return _changingLanguageBody;
  }

  double getLanguageScale() {
    return _languageScale;
  }
}
