import 'package:flutter/material.dart';
import 'package:locationalertsapp/my_alerts_screen.dart';
import 'formatted_text.dart';
import 'database_services.dart';
import 'background_theme.dart';
import 'styles.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.MY_ALERTS_SCREEN);

  double _screenHeight = 0;
  double _screenWidth = 0;
  double _buttonWidth = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _titleTextFontSize = 0;
  double _explainerTextPadding = 0;
  double _listViewPaddingTop = 0;
  double _listViewPaddingSides = 0;
  double _cardBorderWidth = 0;
  double _cardCornerRadius = 0;
  double _cardIconSize = 0;
  double _cardTitleFontSize = 0;
  double _cardBodyFontSize = 0;
  double _cardSubtitleFontSize = 0;
  double _explainerTextFontSize = 0;
  double _backButtonFontSize = 0;
  double _backButtonIconSize = 0;
  double _backButtonCornerRadius = 0;
  double _cardGap = 0;
  double _cardPaddingRightLeft = 0;
  double _cardPaddingTopBottom = 0;
  double _bottomPadding = 0;
  double _noAlertsYetText = 0;
  double _fabSpacing = 0;
  double _fabMapWidth = 0;
  double _buttonWidthMaster = 0;
  double _mapButtonIconSize = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'My Alerts Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle('My Alerts'),
          backgroundColor: Color(s_darkSalmon),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: mapBody(),
        floatingActionButton: fabBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget mapBody() {
    return Center(
        child: Container(
            decoration: _background.getBackground(),
            child: Text('This is the Map Screen.')));
  }

  Widget fabBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        height: _buttonHeight,
        width: _buttonWidth,
        child: FloatingActionButton.extended(
            heroTag: 'FAB_back',
            onPressed: () {
              // Remove keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              Navigator.pop(context);
            },
            backgroundColor: Color(s_darkSalmon),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(_backButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: _backButtonIconSize,
              ),
              SizedBox(
                width: 8,
              ),
              buttonText('Back', _backButtonFontSize)
            ])),
      ),
      SizedBox(width: _fabSpacing),
      Container(
          height: _buttonHeight,
          width: _fabMapWidth,
          child: FloatingActionButton.extended(
              heroTag: 'FAB_map',
              onPressed: () {
                // Navigate to my alerts screen
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        MyAlertsScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              backgroundColor: Color(s_aquarium),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(_backButtonCornerRadius))),
              label: Icon(
                Icons.list,
                color: Colors.white,
                size: _mapButtonIconSize,
              )))
    ]);
  }

  Widget myAlertsScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget buttonText(String text, double fontSize) {
    return FormattedText(
      text: text,
      size: fontSize,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  void generateLayout() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _buttonHeight = (60 / 781) * _screenHeight;
    _listViewPaddingTop = (10 / 781) * _screenHeight;
    _cardGap = (4 / 781) * _screenHeight;
    _cardPaddingTopBottom = (10 / 781) * _screenHeight;
    _bottomPadding = (90 / 781) * _screenHeight;

    // Width
    _buttonWidthMaster = (325 / 392) * _screenWidth;
    _fabSpacing = (5 / 392) * _screenWidth;
    _buttonWidth = (_buttonWidthMaster - _fabSpacing) * 0.80;
    _fabMapWidth = (_buttonWidthMaster - _fabSpacing) * 0.20;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _explainerTextPadding = (12 / 392) * _screenWidth;
    _listViewPaddingSides = (12 / 392) * _screenWidth;
    _cardPaddingRightLeft = (5 / 392) * _screenWidth;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height;
    _cardTitleFontSize = (20 / 60) * _buttonHeight;
    _cardBodyFontSize = (14 / 60) * _buttonHeight;
    _cardSubtitleFontSize = (12 / 60) * _buttonHeight;
    _explainerTextFontSize = (14 / 781) * _screenHeight;
    _backButtonFontSize = (20 / 60) * _buttonHeight;
    _noAlertsYetText = (26 / 781) * _screenHeight;

    // Icons
    _cardIconSize = (30 / 60) * _buttonHeight;
    _backButtonIconSize = (24 / 60) * _buttonHeight;
    _mapButtonIconSize = (30 / 60) * _buttonHeight;

    // Styling
    _cardBorderWidth = (3 / 60) * _buttonHeight;
    _cardCornerRadius = 15;
    _backButtonCornerRadius = (10 / 60) * _buttonHeight;
  }
}
