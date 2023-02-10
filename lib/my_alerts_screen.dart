import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:locationalertsapp/fab_bar.dart';
import 'edit_alert_screen.dart';
import 'start_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'background_theme.dart';
import 'go_back_button.dart';
import 'language_services.dart';
import 'fab_bar.dart';

enum AlertList {
  NOT_COMPLETED,
  COMPLETED,
}

class AlertObject {
  String id;
  String dateTimeCreated;
  String dateTimeCompleted;
  bool isCompleted;
  bool isSpecific;
  String location;
  double latitude;
  double longitude;
  String reminder;
  String userId;
  double triggerDistance;
  String triggerUnits;
  AlertObject(
      {required this.id,
      required this.dateTimeCreated,
      required this.dateTimeCompleted,
      required this.isCompleted,
      required this.isSpecific,
      required this.location,
      required this.latitude,
      required this.longitude,
      required this.reminder,
      required this.userId,
      required this.triggerDistance,
      required this.triggerUnits});
}

class MyAlertsScreen extends StatefulWidget {
  final AlertList alertList;
  const MyAlertsScreen({required this.alertList, Key? key}) : super(key: key);

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.MY_ALERTS_SCREEN);
  final LanguageServices _languageServices = LanguageServices();

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
      title: 'Alerts Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle(),
          backgroundColor: const Color(s_darkSalmon),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: myAlertsScreenBody(),
        floatingActionButton: fabRow(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // Help from https://stackoverflow.com/questions/74216763/how-to-make-a-background-gradient-fill-the-screen-in-a-singlechildscrollview-b
  Widget myAlertsScreenBody() {
    return Container(
        width: double.infinity,
        // here you can set height if you want.
        // but since we use Column,by default it will expand the maximum height.
        decoration: _background.getBackground(),
        child: Column(children: [
          // using Listview will make you widget not overflowing.
          // wrap with expanded to make it fill available screen.
          Expanded(
            child: listViewReminderBuilder(),
          ),
          SizedBox(height: _buttonSpacing),
          Container(
              padding: EdgeInsets.fromLTRB(
                  _explainerTextPadding, 0, _explainerTextPadding, 0),
              child: explainerText()),
          SizedBox(height: _bottomPadding),
        ]));
  }

  Widget listViewReminderBuilder() {
    return StreamBuilder(
        stream: retrieveReminders(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshotReminders) {
          if (snapshotReminders.hasData) {
            if (snapshotReminders.data!.size > 0) {
              // Create list view
              return listViewReminders(
                  createReminderObjects(snapshotReminders));
            } else {
              return Center(child: noAlertsYetText());
            }
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(s_blackBlue),
            ));
          }
        });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveReminders() {
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      return _dbServices.getRemindersIncompleteAlertsSnapshotCall();
    } else {
      return _dbServices.getRemindersCompleteAlertsSnapshotCall();
    }
  }

  List<AlertObject> createReminderObjects(
      AsyncSnapshot<QuerySnapshot> snapshotReminders) {
    List<AlertObject> reminderObjects = [];
    for (var index = 0; index < snapshotReminders.data!.docs.length; ++index) {
      // Convert to lightweight reminder tile objects
      AlertObject alertObj = AlertObject(
        id: snapshotReminders.data!.docs[index].id,
        dateTimeCompleted: DateFormat.yMMMMd('en_US').add_jm().format(
            snapshotReminders.data!.docs[index]['dateTimeCompleted'].toDate()),
        dateTimeCreated: DateFormat.yMMMMd('en_US').add_jm().format(
            snapshotReminders.data!.docs[index]['dateTimeCreated'].toDate()),
        isCompleted: snapshotReminders.data!.docs[index]['isCompleted'],
        isSpecific: snapshotReminders.data!.docs[index]['isSpecific'],
        location: snapshotReminders.data!.docs[index]['location'],
        latitude: snapshotReminders.data!.docs[index]['latitude'],
        longitude: snapshotReminders.data!.docs[index]['longitude'],
        reminder: snapshotReminders.data!.docs[index]['reminderBody'],
        userId: snapshotReminders.data!.docs[index]['userId'],
        triggerDistance: snapshotReminders.data!.docs[index]['triggerDistance'],
        triggerUnits: snapshotReminders.data!.docs[index]['triggerUnits'],
      );
      reminderObjects.add(alertObj);
    }
    return reminderObjects;
  }

  Widget listViewReminders(List<AlertObject> reminderObjects) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(
          _listViewPaddingSides, _listViewPaddingTop, _listViewPaddingSides, 0),
      itemCount: reminderObjects.length,
      itemBuilder: (context, index) {
        var tile = reminderObjects[index];
        return reminderCard(tile);
      },
    );
  }

  Card reminderCard(AlertObject AlertObject) {
    Icon icon;
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      icon = Icon(
        Icons.edit,
        color: Color(s_darkSalmon),
        size: _cardIconSize,
      );
    } else {
      icon = Icon(
        Icons.restore,
        color: Color(s_darkSalmon),
        size: _cardIconSize,
      );
    }

    return Card(
        elevation: 2,
        margin: EdgeInsets.fromLTRB(0, _cardGap, 0, _cardGap),
        //color: Color.fromARGB(255, 188, 227, 245),
        shape: RoundedRectangleBorder(
            side:
                BorderSide(color: Color(s_darkSalmon), width: _cardBorderWidth),
            borderRadius: BorderRadius.circular(_cardCornerRadius)),
        child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(
                _cardPaddingTopBottom,
                _cardPaddingRightLeft,
                _cardPaddingTopBottom,
                _cardPaddingRightLeft),
            isThreeLine: true,
            title: reminderCardTitleText(AlertObject.reminder),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              reminderCardLocationText(
                  '${_languageServices.myAlertsTileLocation}: ${AlertObject.location}'),
              reminderCardDateText(
                  '${_languageServices.myAlertsTileDate}: ${AlertObject.dateTimeCreated}')
            ]),
            trailing: icon,
            onTap: () {
              if (this.widget.alertList == AlertList.NOT_COMPLETED) {
                Navigator.of(context)
                    .push(createRoute(
                        EditAlertScreen(alert: AlertObject), 'from_right'))
                    .then((value) => setState(() {
                          checkIfInstaPop(value);
                        }));
              } else {
                // Set reminder field isComplete to false
                _dbServices.updateRemindersSpecificAlertRestore(
                    context, AlertObject.id);
                // Return to start screen
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
            }));
  }

  void checkIfInstaPop(bool value) {
    if (value) {
      Navigator.pop(context);
    }
  }

  Widget fabRow() {
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      return fabBar(
          context,
          FAB.MAP,
          _buttonHeight,
          _buttonWidth,
          _backButtonFontSize,
          _backButtonIconSize,
          _backButtonCornerRadius,
          _fabSpacing,
          _fabMapWidth,
          _mapButtonIconSize);
    } else {
      return Container(
        height: _buttonHeight,
        width: _buttonWidth + _fabSpacing + _fabMapWidth,
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
              buttonText(_backButtonFontSize)
            ])),
      );
    }
  }

  Widget reminderCardTitleText(String text) {
    return FormattedText(
      text: text,
      size: _cardTitleFontSize,
      color: const Color(s_blackBlue),
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardLocationText(String text) {
    return FormattedText(
      text: text,
      size: _cardBodyFontSize,
      color: const Color(s_aquarium),
      font: s_font_IBMPlexSans,
      decoration: TextDecoration.underline,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardDateText(String text) {
    return FormattedText(
      text: text,
      size: _cardSubtitleFontSize,
      color: const Color(s_blackBlue),
      font: s_font_IBMPlexSans,
      style: FontStyle.italic,
      weight: FontWeight.bold,
    );
  }

  Widget myAlertsScreenTitle() {
    String text;
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      text = _languageServices.myAlertsTitle;
    } else {
      text = _languageServices.myAlertsRestoreTitle;
    }
    return FormattedText(
      text: text,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget explainerText() {
    String text;
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      text = _languageServices.myAlertsExplainer;
    } else {
      text = _languageServices.myAlertsRestoreExplainer;
    }
    return FormattedText(
      text: text,
      size: _explainerTextFontSize,
      color: Color(s_darkSalmon),
      align: TextAlign.center,
      font: s_font_IBMPlexSans,
    );
  }

  Widget noAlertsYetText() {
    String text;
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      text = _languageServices.myAlertsNoneYet;
    } else {
      text = _languageServices.myAlertsRestoreNoneYet;
    }
    return FormattedText(
      text: text,
      size: _noAlertsYetText,
      color: Color(s_darkSalmon),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
      align: TextAlign.center,
    );
  }

  void generateLayout() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    double langScale = _languageServices.getLanguageScale();

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
    _buttonWidth = (_buttonWidthMaster - _fabSpacing) * 0.70;
    _fabMapWidth = (_buttonWidthMaster - _fabSpacing) * 0.30;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _explainerTextPadding = (12 / 392) * _screenWidth;
    _listViewPaddingSides = (12 / 392) * _screenWidth;
    _cardPaddingRightLeft = (5 / 392) * _screenWidth;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height * langScale;
    _cardTitleFontSize = (20 / 60) * _buttonHeight * langScale;
    _cardBodyFontSize = (14 / 60) * _buttonHeight * langScale;
    _cardSubtitleFontSize = (12 / 60) * _buttonHeight * langScale;
    _explainerTextFontSize = (14 / 781) * _screenHeight * langScale;
    _backButtonFontSize = (20 / 60) * _buttonHeight * langScale;
    _noAlertsYetText = (26 / 781) * _screenHeight * langScale;

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
