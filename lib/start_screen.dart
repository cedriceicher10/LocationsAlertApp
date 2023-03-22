import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:background_location/background_location.dart';
import 'package:locationalertsapp/exception_services.dart';
import 'dart:math';
import 'location_services.dart';
import 'my_alerts_screen.dart';
import 'generic_screen.dart';
import 'specific_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'alerts_services.dart';
import 'background_theme.dart';
import 'side_drawer.dart';
//import 'logging_services.dart';
import 'language_services.dart';
import 'notification_services.dart';
import 'language_selection_alert_dialog.dart';

String UUID_GLOBAL = '';
int ALERTS_NUM_GLOBAL = 0;
List<String> GENERAL_LOCATIONS_GLOBAL = [
  'Grocery Store',
  'Drug Store',
  'Hardware Store',
  'Convenience Store',
  'Restaurant'
];

userInfo USER_INFO_SIDE_DRAWER_GLOBAL = userInfo.init();

List<DropdownMenuItem<String>> generalLocations() {
  List<DropdownMenuItem<String>> listGenericLocations = [];
  for (int index = 0; index < GENERAL_LOCATIONS_GLOBAL.length; ++index) {
    DropdownMenuItem<String> item = DropdownMenuItem(
      child: Text(GENERAL_LOCATIONS_GLOBAL[index]),
      value: GENERAL_LOCATIONS_GLOBAL[index],
      alignment: Alignment.center,
    );
    listGenericLocations.add(item);
  }
  return listGenericLocations;
}

// Firebase cloud firestore
CollectionReference reminders =
    FirebaseFirestore.instance.collection('reminders');

// Exceptions
ExceptionServices _exception = ExceptionServices();

// Enables screen transition to the right (instead of default bottom)
Route createRoute(Widget page, String direction) {
  Offset begin = Offset.zero;
  Offset end = Offset.zero;
  if (direction == 'from_left') {
    begin = const Offset(-1.0, 0.0);
  } else if (direction == 'from_right') {
    begin = const Offset(1.0, 0.0);
  }
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      begin;
      end;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Services
  final DatabaseServices _dbServices = DatabaseServices();
  final AlertServices _alertServices = AlertServices();
  final LocationServices _locationServices = LocationServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.START_SCREEN);
  //final LoggingServices _logger = LoggingServices();
  final LanguageServices _languageServices = LanguageServices();
  double _userBgLat = 0;
  double _userBgLon = 0;

  // Init
  bool __on_this_page__ = true;
  bool __uuid_complete__ = false;
  bool __sp_recent_locations_complete__ = false;
  bool __user_info_app_opens__ = false;
  bool _masterLocationToggle = false;
  bool _toggleJustDone = false;
  bool _toggleBack = false;
  Color _masterLocationColorOn = startScreenToggleSliderOn;
  Color _masterLocationColorOff = startScreenToggleSliderOff;
  Color _masterLocationColor = startScreenToggleSliderOff;

  // Layout
  double _topPadding = 0;
  double _buttonWidth = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _iconGap = 0;
  double _titleIconSize = 0;
  double _explainerTextPadding = 0;
  double _specificLocationIconSize = 0;
  double _locationDisclosureButtonHeight = 0;
  double _locationDisclosureButtonWidth = 0;
  double _locationDisclosureFontSize = 0;
  double _titleTextFontSize = 0;
  double _locationDisclosureIconSize = 0;
  double _explainerFontSize = 0;
  double _submitButtonFontSize = 0;
  double _helpFontSize = 0;
  double _signatureFontSize = 0;
  double _locationToggleFontSize = 0;
  double _locationDisclosureButtonCornerRadius = 0;
  double _submitButtonCornerRadius = 0;
  double _gapBeforeTitleIcon = 0;
  double _gapAfterTitleIcon = 0;
  double _gapBeforeButtons = 0;
  double _gapAfterButtons = 0;
  double _locationToggleScale = 0;
  double _locationToggleGapWidth = 0;
  double _bottomPadding = 0;
  double _alertPaddingRight = 0;
  double _logoSize = 0;
  double _logoBorderRadius = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'Start Screen',
      initialRoute: '/',
      // This Builder is here so that routes needing a up-the-tree context can
      // find it. See: https://stackoverflow.com/questions/44004451/navigator-operation-requested-with-a-context-that-does-not-include-a-navigator
      home: Builder(builder: (context) {
        // Prominent disclosure on location usage
        Future.delayed(Duration.zero, () {
          return showLocationDisclosureDetermination(context);
        });
        return Scaffold(
          appBar: AppBar(
            title: startScreenTitle(),
            backgroundColor: startScreenAppBar,
            centerTitle: true,
          ),
          drawer: SideDrawer(),
          body: FutureBuilder(
              future: initFunctions(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  return startScreenBody(context);
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: startScreenLoading,
                  ));
                }
              }),
        );
      }),
    );
  }

  Future<bool> initFunctions() async {
    if (__on_this_page__) {
      if (!__uuid_complete__) {
        // Generate (hidden) unique user id for the user to be used to identify their reminders in the db
        await generateUniqueUserId();
      }
      if (!__sp_recent_locations_complete__) {
        // Set up shared prefs for recently chosen locations
        await sharedPrefsSetup();
      }
      // Tally the number of uncompleted alerts for the My Alerts button
      await setAlertCount();
      // Check status of location services and toggle
      await locationToggleCheck();
      // Kickoff background location tracking
      await kickoffBackgroundLocation();
      if (!__user_info_app_opens__) {
        // User app opens
        await updateUserAppOpens();
        // User last login
        await updateUserLogin();
      }
      // Grab the information for the side drawer
      getSideDrawerUserInfo();
      // Set up future notifications to prompt user
      NotificationServices().scheduleNewNotification();
      // Language selection (first time only)
      languageSelection();
    }
    return true;
  }

  dynamic languageSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? languageSelectionFirstTime =
        prefs.getBool('languageSelectionFirstTime');
    if ((languageSelectionFirstTime == null) ||
        (languageSelectionFirstTime == false)) {
      prefs.setBool('languageSelectionFirstTime', true);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LanguageSelectionAlertDialogue(padding: _alertPaddingRight);
        },
      );
    } else {
      return;
    }
  }

  Future<void> getSideDrawerUserInfo() async {
    USER_INFO_SIDE_DRAWER_GLOBAL = await _dbServices.getUsersSnapshot(context);
  }

  Future<void> updateUserAppOpens() async {
    _dbServices.updateUsersAppOpens(context);
    __user_info_app_opens__ = true;
  }

  Future<void> updateUserLogin() async {
    _dbServices.updateUsersLastLogin(context);
  }

  Future<void> locationToggleCheck() async {
    // Check if the location services changed outside the toggle (turned off/on while closed, on another screen, etc)
    // Update masterLocationToggle (screen var _masterLocationToggle, shared prefs var masterLocationToggle, and toggle appearance)
    if (!_toggleJustDone) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
      if ((showLocationDisclosure != null) &&
          (showLocationDisclosure == false)) {
        if (await _locationServices.checkLocationEnabled()) {
          await _locationServices.getLocation();
          if (_locationServices.permitted) {
            _masterLocationToggle = true;
            prefs.setBool('masterLocationToggle', true);
            _masterLocationColor = _masterLocationColorOn;
          } else {
            _masterLocationToggle = false;
            prefs.setBool('masterLocationToggle', false);
            _masterLocationColor = _masterLocationColorOff;
          }
        }
      }
    } else {
      _toggleJustDone = false;
    }
    // Situation where user toggles on, then denies the location permissions
    if (_toggleBack) {
      _masterLocationToggle = false;
      _toggleBack = false;
    }
  }

  Future<void> kickoffBackgroundLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? masterLocationToggle = prefs.getBool('masterLocationToggle');
    // Only have masterLocationToggle determine if the location tracking is on
    if ((masterLocationToggle == true) && (masterLocationToggle != null)) {
      // Background location service
      await BackgroundLocation.setAndroidNotification(
        title: _languageServices.notificationsTitle,
        message: _languageServices.notificationsBody,
        icon: '@mipmap/ic_launcher',
      );
      await BackgroundLocation.setAndroidConfiguration(10000); // interval in ms
      await BackgroundLocation.startLocationService(distanceFilter: 0);
      BackgroundLocation.getLocationUpdates((bgLocationData) {
        _userBgLat = bgLocationData.latitude!;
        _userBgLon = bgLocationData.longitude!;
        setState(() async {
          print('BACKGROUND LOCATION TRIGGERED ==============');
          // print('Latitude : ${bgLocationData.latitude}');
          // print('Longitude: ${bgLocationData.longitude}');
          // print('Accuracy : ${bgLocationData.accuracy}');
          // print('Altitude : ${bgLocationData.altitude}');
          // print('Bearing  : ${bgLocationData.bearing}');
          // print('Speed    : ${bgLocationData.speed}');
          // print(
          //     'Time     : ${DateTime.fromMillisecondsSinceEpoch(bgLocationData.time!.toInt())}');

          // NOTIFICATION KICKOFF LOGIC
          // Retrieve alerts
          QuerySnapshot<Map<String, dynamic>> alerts =
              await _dbServices.getRemindersIsCompleteAlertsGetCall(context);

          // Alert trigger
          for (var index = 0; index < alerts.docs.length; ++index) {
            // For now only specific alerts
            if (alerts.docs[index]['isSpecific']) {
              _alertServices.alertDeterminationLogic(
                  _userBgLat, _userBgLon, alerts.docs[index]);
            }
          }
        });
      });
    } else {
      BackgroundLocation.stopLocationService();
      print('BACKGROUND LOCATION SERVICES OFF');
    }
  }

  Future<void> setAlertCount() async {
    ALERTS_NUM_GLOBAL = await _dbServices.getAlertCount(context);
  }

  Future<void> generateUniqueUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuidSP = prefs.getString('uuid');
    if (uuidSP == null) {
      // The unique user id (uuid) is 10 sequential numerals (0-9)
      // Ex: 0613108162
      String uuid = '';
      var rng = Random();
      bool isTaken = true;
      while (isTaken) {
        for (var i = 0; i < 10; i++) {
          uuid += rng.nextInt(9).toString();
        }
        isTaken = await _dbServices.isUuidTaken(context, uuid);
      }
      // Assign to prefs so can be accessed in the app
      prefs.setString('uuid', uuid);
      UUID_GLOBAL = uuid;
      // Add user to users table in db
      _dbServices.addToUsersDatabase(context);
    } else {
      UUID_GLOBAL = uuidSP;
    }
    __uuid_complete__ = true;
  }

  Future<void> sharedPrefsSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentLocationsList =
        prefs.getStringList('recentLocationsList');
    if (recentLocationsList == null) {
      List<String> emptyList = [];
      prefs.setStringList('recentLocationsList', emptyList);
    }
    __sp_recent_locations_complete__ = true;
  }

  showLocationDisclosureDetermination(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
    // Show the disclosure if it's the first time or user has previously dismissed location services
    if ((showLocationDisclosure == null) || (showLocationDisclosure == true)) {
      showLocationDisclosureAlert(context, prefs);
    }
  }

  dynamic showLocationDisclosureAlert(
      BuildContext context, SharedPreferences prefs) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return locationDisclosureAlert(context, prefs);
      },
    );
  }

  AlertDialog locationDisclosureAlert(
      BuildContext context, SharedPreferences prefs) {
    return AlertDialog(
      title: Text(
        _languageServices.disclosureLocationTitle,
        style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                  offset: Offset(0, -3),
                  color: startScreenLocationDisclosureText)
            ],
            decoration: TextDecoration.underline,
            decorationColor: startScreenLocationDisclosureAlertText,
            decorationThickness: 1),
      ),
      content: Text(_languageServices.disclosureLocation),
      actions: <Widget>[
        TextButton(
            child: Text(_languageServices.disclosureLocationDecline),
            style: TextButton.styleFrom(
                foregroundColor: startScreenLocationDisclosureAlertDeclineText),
            onPressed: () {
              Navigator.of(context).pop();
              prefs.setBool('showLocationDisclosure', true);
              // Notice that app will not deliver alerts based on location
              Future.delayed(Duration.zero, () {
                return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return locationOffNoticeAlert(context, prefs);
                    });
              });
            }),
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, _alertPaddingRight, 0),
            child: TextButton(
              child: Text(_languageServices.disclosureLocationAccept,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: startScreenLocationDisclosureAlertAccept,
                  foregroundColor:
                      startScreenLocationDisclosureAlertAcceptText),
              onPressed: () async {
                Navigator.of(context).pop();
                prefs.setBool('showLocationDisclosure', false);
              },
            ))
      ],
    );
  }

  AlertDialog locationOffNoticeAlert(
      BuildContext context, SharedPreferences prefs) {
    return AlertDialog(
        title: Text(
          _languageServices.disclosureLocationOffTitle,
          style: TextStyle(
              color: Colors.transparent,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
              decoration: TextDecoration.underline,
              decorationColor: startScreenLocationOffText,
              decorationThickness: 1),
        ),
        content: Text(_languageServices.disclosureLocationOff),
        actions: <Widget>[
          TextButton(
              child: Text(_languageServices.disclosureLocationOffClose),
              style: TextButton.styleFrom(
                  backgroundColor: startScreenLocationOffButton),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ]);
  }

  Widget startScreenBody(BuildContext context) {
    return SafeArea(
        child: Container(
            decoration: _background.getBackground(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: _topPadding),
                  Center(
                      child: Container(
                          padding: EdgeInsets.fromLTRB(_explainerTextPadding, 0,
                              _explainerTextPadding, 0),
                          child: explainerTitle(
                              'Phone alerts based on your current location!'))),
                  SizedBox(height: _gapBeforeTitleIcon),
                  // Icon(
                  //   Icons.add_location_alt_outlined,
                  //   color: Color(s_darkSalmon),
                  //   size: _titleIconSize,
                  // ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(_logoBorderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: startScreenLogoGlow,
                              spreadRadius: 4,
                              blurRadius: 8,
                              offset: Offset(0, 0),
                            ),
                          ]),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(_logoBorderRadius),
                          child: Image(
                              width: _logoSize,
                              image:
                                  AssetImage('assets/images/app_icon.png')))),
                  SizedBox(height: _gapAfterTitleIcon),
                  locationToggle(),
                  // Turning off generic alerts for first prod version
                  // genericLocationButton(context, 'Generic'),
                  // genericHelpText(),
                  SizedBox(height: _gapBeforeButtons),
                  //specificLocationButton(context, 'Create Alert'),
                  specificLocationButton(
                      context, _languageServices.startScreenCreateAlert),
                  //specificHelpText(),
                  SizedBox(height: _buttonSpacing),
                  // myAlertsButton(
                  //     context, 'View my Alerts ($ALERTS_NUM_GLOBAL)'),
                  myAlertsButton(context,
                      '${_languageServices.startScreenViewAlerts} ($ALERTS_NUM_GLOBAL)'),
                  SizedBox(height: _gapAfterButtons),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        locationDisclosureButton(context),
                        SizedBox(width: 5),
                        buyMeACoffee(context),
                      ]),
                  //locationDisclosureButton(context),
                  SizedBox(height: _buttonSpacing),
                  signatureText(),
                  SizedBox(height: _bottomPadding),
                ])));
  }

  Widget explainerTitle(String text) {
    return FormattedText(
        //text: text,
        text: _languageServices.startScreenExplainer,
        size: _explainerFontSize,
        color: startScreenExplainerText,
        font: font_nakedText,
        weight: FontWeight.bold,
        align: TextAlign.center);
  }

  Widget locationToggle() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      FormattedText(
          //text: 'Allow My Location: ',
          text: _languageServices.startScreenLocationToggle,
          size: _locationToggleFontSize,
          color: _masterLocationColor,
          font: font_plainText,
          weight: FontWeight.bold,
          align: TextAlign.center),
      SizedBox(width: _locationToggleGapWidth),
      Transform.scale(
          scale: _locationToggleScale,
          child: Switch(
            inactiveThumbColor: columbiaBlue,
            activeTrackColor: startScreenToggleSliderOn,
            activeColor: startScreenToggleOn,
            value: _masterLocationToggle,
            onChanged: (value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              _masterLocationToggle = value;
              if (_masterLocationToggle) {
                bool? showLocationDisclosure =
                    prefs.getBool('showLocationDisclosure');
                if ((showLocationDisclosure == false) &&
                    (showLocationDisclosure != null)) {
                  await _locationServices.getLocation();
                  setState(() {
                    if (_locationServices.permitted) {
                      _masterLocationColor = startScreenToggleOn;
                      prefs.setBool(
                          'masterLocationToggle', _masterLocationToggle);
                    } else {
                      _toggleBack = true;
                      prefs.setBool('masterLocationToggle',
                          false); // User backed out of location permissions
                    }
                  });
                } else {
                  showLocationDisclosureAlert(context, prefs);
                }
              } else {
                setState(() {
                  _masterLocationColor = startScreenToggleSliderOff;
                  prefs.setBool('masterLocationToggle', _masterLocationToggle);
                });
              }
              _toggleJustDone = true;
            },
          )),
    ]);
  }

  Widget genericLocationButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool? showLocationDisclosure =
              prefs.getBool('showLocationDisclosure');
          if ((showLocationDisclosure == null) ||
              (showLocationDisclosure == true)) {
            showLocationDisclosureAlert(context, prefs);
          } else {
            __on_this_page__ = false;
            Navigator.of(context)
                .push(createRoute(
                    SpecificScreen(
                        screen: ScreenType.CREATE, alert: AlertObject.empty()),
                    'from_right')) // was GenericScreen()
                .then((value) => setState(() {
                      __on_this_page__ = true;
                    })); // This allows for page rebuilding upon pop
          }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          buttonText(text),
          SizedBox(
            width: _iconGap,
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: startScreenCreateAlertIcon1,
            size: _specificLocationIconSize,
          )
        ]),
        style: ElevatedButton.styleFrom(
            backgroundColor: startScreenCreateAlertButton,
            fixedSize: Size(_buttonWidth, _buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_submitButtonCornerRadius))));
  }

  Widget specificLocationButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () async {
          // // LOG TEST
          // _logger.log(logType.INFO, 'start_screen', 637,
          //     'Going to Specific Creat Alert');
          __on_this_page__ = false;
          Navigator.of(context)
              .push(createRoute(
                  SpecificScreen(
                      screen: ScreenType.CREATE, alert: AlertObject.empty()),
                  'from_right'))
              .then((value) => setState(() {
                    __on_this_page__ = true;
                  }));
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.add_alert,
            color: startScreenCreateAlertIcon1,
            size: _specificLocationIconSize,
          ),
          SizedBox(width: _iconGap),
          buttonText(text),
          Expanded(
              child: SizedBox(
            width: 1,
          )),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: startScreenCreateAlertIcon2,
            size: _specificLocationIconSize,
          )
        ]),
        style: ElevatedButton.styleFrom(
            backgroundColor: startScreenCreateAlertButton,
            fixedSize: Size(_buttonWidth, _buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_submitButtonCornerRadius))));
  }

  Widget myAlertsButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () {
          __on_this_page__ = false;
          Navigator.of(context)
              .push(createRoute(
                  MyAlertsScreen(alertList: AlertList.NOT_COMPLETED),
                  'from_right'))
              .then((value) => setState(() {
                    __on_this_page__ = true;
                  }));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: startScreenMyAlertsButton,
            fixedSize: Size(_buttonWidth, _buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_submitButtonCornerRadius))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.doorbell,
              color: startScreenMyAlertsIcon1,
              size: _specificLocationIconSize,
            ),
            SizedBox(
              width: _iconGap,
            ),
            buttonText(text),
            Expanded(
                child: SizedBox(
              width: 1,
            )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: startScreenMyAlertsIcon1,
              size: _specificLocationIconSize,
            )
          ],
        ));
  }

  Widget startScreenTitle() {
    return FormattedText(
      text: _languageServices.startScreenTitle,
      size: _titleTextFontSize,
      color: startScreenTitleText,
      font: font_appBarText,
    );
  }

  Widget buttonText(String title) {
    return FormattedText(
        text: title,
        size: _submitButtonFontSize,
        color: startScreenCreateAlertText,
        font: font_bigButtonText,
        weight: FontWeight.bold);
  }

  Widget signatureText() {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: startScreenSignatureText,
              fontFamily: font_plainText,
              fontSize: _signatureFontSize,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          //text: 'An App by Cedric Eicher',
          text: _languageServices.startScreenSignature,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = "https://www.linkedin.com/in/cedriceicher/";
              if (!await launch(url)) {
                _exception.popUp(context, 'Launch URL: Could not launch $url');
                throw 'Could not launch $url';
              }
            }),
    );
  }

  Widget locationDisclosureButton(BuildContext context) {
    return SizedBox(
        height: _locationDisclosureButtonHeight,
        width: _locationDisclosureButtonWidth,
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: startScreenLocationDisclosureButton,
                borderRadius: BorderRadius.all(
                    Radius.circular(_locationDisclosureButtonCornerRadius))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,
                      size: _locationDisclosureIconSize,
                      color: startScreenLocationDisclosureIcon),
                  TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: locationDisclosureText(),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        showLocationDisclosureAlert(context, prefs);
                      })
                ])));
  }

  Widget buyMeACoffee(BuildContext context) {
    return SizedBox(
        height: _locationDisclosureButtonHeight,
        width: _locationDisclosureButtonWidth,
        child: ClipRRect(
            borderRadius:
                BorderRadius.circular(_locationDisclosureButtonCornerRadius),
            child: InkWell(
                onTap: () async {
                  var url = "https://www.buymeacoffee.com/cedriceicher";
                  if (!await launch(url)) {
                    _exception.popUp(
                        context, 'Launch URL: Could not launch $url');
                    throw 'Could not launch $url';
                  }
                },
                child: Image(
                    fit: BoxFit.fitWidth,
                    image: AssetImage(
                        'assets/images/buy_me_a_coffee_button.png')))));
  }

  Widget locationDisclosureText() {
    return FormattedText(
        //text: text,
        text: _languageServices.startScreenLocationDisclosure,
        size: _locationDisclosureFontSize,
        color: startScreenLocationDisclosureButtonText,
        font: font_plainText,
        weight: FontWeight.bold);
  }

  void generateLayout() {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    double langScale = _languageServices.getLanguageScale();

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _topPadding = (80 / 781) * _screenHeight;
    _buttonHeight = (60 / 781) * _screenHeight;
    _locationDisclosureButtonHeight = (30 / 781) * _screenHeight;
    _gapBeforeTitleIcon = (50 / 781) * _screenHeight;
    _gapAfterTitleIcon = (45 / 781) * _screenHeight;
    _gapBeforeButtons = (5 / 781) * _screenHeight;
    _gapAfterButtons = (20 / 781) * _screenHeight;
    _bottomPadding = (20 / 781) * _screenHeight;
    _logoSize = (190 / 781) * _screenHeight;

    // Width
    _buttonWidth = (325 / 392) * _screenWidth;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _iconGap = 8;
    _explainerTextPadding = (20 / 392) * _screenWidth;
    _locationDisclosureButtonWidth = (125 / 392) * _screenWidth;
    _locationToggleGapWidth = (10 / 392) * _screenWidth;
    _alertPaddingRight = (10 / 392) * _screenWidth;

    // Font
    _submitButtonFontSize = (20 / 60) * _buttonHeight * langScale;
    _locationDisclosureFontSize =
        (10 / 30) * _locationDisclosureButtonHeight * langScale;
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height * langScale;
    _explainerFontSize = (26 / 781) * _screenHeight * langScale;
    _helpFontSize = (16 / 781) * _screenHeight * langScale;
    _signatureFontSize = (12 / 781) * _screenHeight * langScale;
    _locationToggleFontSize = (14 / 781) * _screenHeight * langScale;

    // Icons
    _titleIconSize = (175 / 781) * _screenHeight;
    _specificLocationIconSize = (24 / 60) * _buttonHeight;
    _locationDisclosureIconSize = (12 / 30) * _locationDisclosureButtonHeight;

    // Styling
    _locationDisclosureButtonCornerRadius =
        (50 / 30) * _locationDisclosureButtonHeight;
    _submitButtonCornerRadius = (10 / 60) * _buttonHeight;
    _locationToggleScale = (_screenHeight / 781) * 1.15;
    _logoBorderRadius = (10 / 250) * _logoSize;
  }
}
