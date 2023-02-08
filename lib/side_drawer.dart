import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:locationalertsapp/language_selection_alert_dialog.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'exception_services.dart';
import 'intro_slides_screen.dart';
import 'database_services.dart';
import 'language_services.dart';
import 'formatted_text.dart';
import 'styles.dart';

class SideDrawer extends StatelessWidget {
  SideDrawer({Key? key}) : super(key: key);

  // Services
  final DatabaseServices _dbServices = DatabaseServices();
  final LanguageServices _languageServices = LanguageServices();
  userInfo userSideDrawerInfo = userInfo.init();

  // Exceptions
  ExceptionServices _exception = ExceptionServices();

  double _screenWidth = 0;
  double _screenHeight = 0;
  double _sideDrawerHeaderHeight = 0;
  double _sideDrawerTitleFontSize = 0;
  double _sideDrawerItemFontSize = 0;
  double _sideDrawerIconSize = 0;
  double _dataDisclosureIconSize = 0;
  double _dataIconSpacer = 0;
  double _adDisclosureIconSize = 0;
  double _adIconSpacer = 0;
  double _howToUseIconSize = 0;
  double _howToUseIconSpacer = 0;
  double _alertPaddingRight = 0;
  double _sideDrawerDividerFontSize = 0;
  double _sideDrawerDividerTextPaddingLeft = 0;
  double _sideDrawerDividerTextPaddingTop = 0;
  double _sideDrawerDividerTextPaddingBottom = 0;
  double _sideDrawerDividerBottomPadding = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout(context);
    if (USER_INFO_SIDE_DRAWER_GLOBAL.userNo == -1) {
      return FutureBuilder(
          future: initFunctions(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return sideDrawer(context);
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: Color(s_darkSalmon),
              ));
            }
          });
    } else {
      userSideDrawerInfo = USER_INFO_SIDE_DRAWER_GLOBAL;
      return sideDrawer(context);
    }
  }

  Future<bool> initFunctions(BuildContext context) async {
    userSideDrawerInfo = await _dbServices.getUsersSnapshot(context);
    return true;
  }

  Widget sideDrawer(BuildContext context) {
    return Container(
        width: _screenWidth * 0.70,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                  height: _sideDrawerHeaderHeight,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(s_darkSalmon),
                    ),
                    child: sideDrawerTitle(),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      _sideDrawerDividerTextPaddingLeft,
                      _sideDrawerDividerTextPaddingTop,
                      0,
                      _sideDrawerDividerTextPaddingBottom),
                  child:
                      dividerText(_languageServices.sideDrawerDisclosureTitle)),
              ListTile(
                dense: true,
                title: dataDisclosure(context),
                onTap: () {
                  showDataDisclosure(context);
                },
              ),
              ListTile(
                dense: true,
                title: adDisclosure(context),
                onTap: () {
                  showAdDisclosure(context);
                },
              ),
              SizedBox(height: _sideDrawerDividerBottomPadding),
              Divider(),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      _sideDrawerDividerTextPaddingLeft,
                      _sideDrawerDividerTextPaddingTop,
                      0,
                      _sideDrawerDividerTextPaddingBottom),
                  child: dividerText(_languageServices.sideDrawerAppTitle)),
              ListTile(
                dense: true,
                title: howToUse(context),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new IntroSlidesScreen(
                                  screenWidth: _screenWidth,
                                  screenHeight: _screenHeight)));
                },
              ),
              ListTile(
                dense: true,
                title: privacyPolicy(context),
                onTap: () {
                  // URL to privacy policy
                },
              ),
              ListTile(
                dense: true,
                title: about(context),
                onTap: () {
                  showAboutMe(context);
                },
              ),
              SizedBox(height: _sideDrawerDividerBottomPadding),
              Divider(),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      _sideDrawerDividerTextPaddingLeft,
                      _sideDrawerDividerTextPaddingTop,
                      0,
                      _sideDrawerDividerTextPaddingBottom),
                  child: dividerText(
                      _languageServices.sideDrawerCommunicateTitle)),
              ListTile(
                dense: true,
                title: sendFeedback(context),
                onTap: () async {
                  String email = 'cedriceicher10@gmail.com';
                  String subject =
                      'Feedback for Location Alerts (UUID #$UUID_GLOBAL)';
                  if (!(await launch('mailto:$email?subject=$subject'))) {
                    _exception.popUp(
                        context, 'Launch email: Could not launch $email');
                    throw 'Could not launch $email';
                  }
                },
              ),
              ListTile(
                dense: true,
                title: requestUserData(context),
                onTap: () async {
                  String email = 'cedriceicher10@gmail.com';
                  String subject = 'Request User Data for UUID #$UUID_GLOBAL';
                  if (!(await launch('mailto:$email?subject=$subject'))) {
                    _exception.popUp(
                        context, 'Launch email: Could not launch $email');
                    throw 'Could not launch $email';
                  }
                },
              ),
              SizedBox(height: _sideDrawerDividerBottomPadding),
              Divider(),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      _sideDrawerDividerTextPaddingLeft,
                      _sideDrawerDividerTextPaddingTop,
                      0,
                      _sideDrawerDividerTextPaddingBottom),
                  child:
                      dividerText(_languageServices.sideDrawerLanguageTitle)),
              ListTile(
                dense: true,
                title: language(context),
                onTap: () {
                  languageSelection(context);
                },
              ),
              SizedBox(height: _sideDrawerDividerBottomPadding),
              Divider(),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      _sideDrawerDividerTextPaddingLeft,
                      _sideDrawerDividerTextPaddingTop,
                      0,
                      _sideDrawerDividerTextPaddingBottom),
                  child: dividerText(
                      _languageServices.sideDrawerUserStatisticsTitle)),
              listTileDate('${_languageServices.sideDrawerFirstLogin}:',
                  userSideDrawerInfo.firstLogin),
              listTileDate('${_languageServices.sideDrawerLastLogin}:',
                  userSideDrawerInfo.lastLogin),
              listTileNoAction(
                  '${_languageServices.sideDrawerAlertsCreated}: ${userSideDrawerInfo.remindersCreated}'),
              listTileNoAction(
                  '${_languageServices.sideDrawerAlertsCompleted}: ${userSideDrawerInfo.remindersCompleted}'),
              listTileNoAction(
                  '${_languageServices.sideDrawerAlertsCompletion}: ${alertCompletion(userSideDrawerInfo.remindersCompleted, userSideDrawerInfo.remindersCreated)}%'),
              ListTile(
                dense: true,
                title: userNo(userSideDrawerInfo.userNo),
                onTap: () {},
              ),
              ListTile(
                dense: true,
                title: uuidNo(),
                onTap: () {},
              ),
              SizedBox(height: _sideDrawerDividerBottomPadding),
            ],
          ),
        ));
  }

  dynamic showDataDisclosure(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return showDataDisclosureAlert(context);
      },
    );
  }

  dynamic showAdDisclosure(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return showAdDisclosureAlert(context);
      },
    );
  }

  dynamic showAboutMe(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return showAboutMeAlert(context);
      },
    );
  }

  dynamic languageSelection(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return LanguageSelectionAlertDialogue(padding: _alertPaddingRight);
      },
    );
  }

  AlertDialog showDataDisclosureAlert(BuildContext context) {
    return AlertDialog(
      title: Text(
        _languageServices.disclosureDataTitle,
        style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
            decoration: TextDecoration.underline,
            decorationColor: Colors.black,
            decorationThickness: 1),
      ),
      content: Text(_languageServices.disclosureDataBody),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, _alertPaddingRight, 0),
            child: TextButton(
              child: Text(_languageServices.disclosureCloseButton,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: Color(s_aquarium),
                  foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }

  AlertDialog showAdDisclosureAlert(BuildContext context) {
    return AlertDialog(
      title: Text(
        _languageServices.disclosureAdsTitle,
        style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
            decoration: TextDecoration.underline,
            decorationColor: Colors.black,
            decorationThickness: 1),
      ),
      content: Text(_languageServices.disclosureAdsBody),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, _alertPaddingRight, 0),
            child: TextButton(
              child: Text(_languageServices.disclosureCloseButton,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: Color(s_aquarium),
                  foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }

  AlertDialog showAboutMeAlert(BuildContext context) {
    return AlertDialog(
      title: Text(
        _languageServices.disclosureAboutTitle,
        style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
            decoration: TextDecoration.underline,
            decorationColor: Colors.black,
            decorationThickness: 1),
      ),
      content: Text(_languageServices.disclosureAboutBody),
      actions: <Widget>[
        TextButton(
            child: Text(_languageServices.disclosureLinkedinButton),
            style: TextButton.styleFrom(
                backgroundColor: Color(s_linkedin),
                foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).pop();
              String url = 'https://www.linkedin.com/in/cedriceicher/';
              if (!(await launch(url))) {
                _exception.popUp(context, 'Launch URL: Could not launch $url');
                throw 'Could not launch $url';
              }
            }),
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, _alertPaddingRight, 0),
            child: TextButton(
              child: Text(_languageServices.disclosureCloseButton,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: Color(s_aquarium),
                  foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }

  Widget dataDisclosure(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_outlined,
              size: _dataDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _dataIconSpacer),
          listText(_languageServices.sideDrawerDataDisclosureTitle)
        ]);
  }

  Widget adDisclosure(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.attach_money_outlined,
              size: _adDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _adIconSpacer),
          listText(_languageServices.sideDrawerAdsDisclosureTitle)
        ]);
  }

  Widget howToUse(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.question_mark,
              size: _howToUseIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _howToUseIconSpacer),
          listText(_languageServices.sideDrawerHowToUseTitle)
        ]);
  }

  Widget sendFeedback(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.email_outlined,
              size: _dataDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _dataIconSpacer),
          listText(_languageServices.sideDrawerSendFeedbackTitle)
        ]);
  }

  Widget requestUserData(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.perm_device_information_rounded,
              size: _dataDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _dataIconSpacer),
          listText(_languageServices.sideDrawerRequestUserDataTitle)
        ]);
  }

  Widget privacyPolicy(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.privacy_tip_outlined,
              size: _adDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _adIconSpacer),
          listText(_languageServices.sideDrawerPrivacyPolicyTitle)
        ]);
  }

  Widget about(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline,
              size: _adDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _adIconSpacer),
          listText(_languageServices.sideDrawerAboutTitle)
        ]);
  }

  Widget language(BuildContext context) {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.language,
              size: _adDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _adIconSpacer),
          listText(_languageServices.sideDrawerChangeLanguageTitle)
        ]);
  }

  Widget userNo(int userNo) {
    String userNoString = userNoText(userNo);
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.numbers_rounded,
              size: _adDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _adIconSpacer),
          listText('${_languageServices.sideDrawerUserNo}: $userNoString')
        ]);
  }

  Widget uuidNo() {
    return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.person,
              size: _adDisclosureIconSize, color: Color(s_blackBlue)),
          SizedBox(width: _adIconSpacer),
          listText('${_languageServices.sideDrawerUuid}: $UUID_GLOBAL')
        ]);
  }

  Widget listText(String text) {
    return FormattedText(
        text: text,
        size: _sideDrawerItemFontSize,
        color: Color(s_aquarium),
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget dividerText(String text) {
    return FormattedText(
        text: text,
        size: _sideDrawerDividerFontSize,
        color: Color.fromARGB(255, 117, 114, 114),
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  String alertCompletion(int completed, int created) {
    if (completed > created) {
      return '-';
    } else if ((completed == 0) && (created == 0)) {
      return '0';
    } else if (completed > created) {
      return '-';
    } else {
      return ((completed / created) * 100).toStringAsFixed(2);
    }
  }

  String userNoText(int userNo) {
    int zeros = 6 - userNo.toString().length;
    String userNoString = ('0' * zeros) + userNo.toString();
    return userNoString;
  }

  Widget listTileDate(String text, Timestamp timestamp) {
    return ListTile(
      dense: true,
      title: settingDrawerItem('$text ${convertToDateTimeFormat(timestamp)}'),
      onTap: () {},
    );
  }

  Widget listTileNoAction(String text) {
    return ListTile(
      dense: true,
      title: settingDrawerItem(text),
      onTap: () {},
    );
  }

  Widget sideDrawerTitle() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.location_pin,
            color: Colors.white,
            size: _sideDrawerIconSize,
          ),
          SizedBox(width: 2),
          FormattedText(
              text: _languageServices.sideDrawerTitle,
              size: _sideDrawerTitleFontSize,
              color: Colors.white,
              font: s_font_IBMPlexSans,
              align: TextAlign.center,
              weight: FontWeight.bold)
        ]);
  }

  Widget settingDrawerItem(String text) {
    return FormattedText(
        text: text,
        size: _sideDrawerItemFontSize,
        color: Color(s_aquarium),
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  String convertToDateTimeFormat(Timestamp timestamp) {
    return DateFormat.yMd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000));
  }

  void generateLayout(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    double langScale = _languageServices.getLanguageScale();

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _sideDrawerHeaderHeight = (80 / 781) * _screenHeight;
    _sideDrawerDividerTextPaddingTop = (10 / 781) * _screenHeight;
    _sideDrawerDividerTextPaddingBottom = (10 / 781) * _screenHeight;
    _sideDrawerDividerBottomPadding = (0 / 781) * _screenHeight;

    // Width
    _dataIconSpacer = 4;
    _adIconSpacer = 4;
    _howToUseIconSpacer = 4;
    _alertPaddingRight = (10 / 392) * _screenWidth;
    _sideDrawerDividerTextPaddingLeft = 6;

    // Font
    _sideDrawerTitleFontSize = (18 / 392) * _screenWidth * langScale;
    _sideDrawerItemFontSize = (14 / 392) * _screenWidth * langScale;
    _sideDrawerDividerFontSize = (14 / 392) * _screenWidth * langScale;

    // Icons
    _sideDrawerIconSize = (20 / 80) * _sideDrawerHeaderHeight;
    _dataDisclosureIconSize = (16 / 80) * _sideDrawerHeaderHeight;
    _adDisclosureIconSize = (16 / 80) * _sideDrawerHeaderHeight;
    _howToUseIconSize = (16 / 80) * _sideDrawerHeaderHeight;
  }
}
