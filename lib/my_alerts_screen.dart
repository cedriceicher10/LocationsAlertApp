import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:locationalertsapp/fab_bar.dart';
import 'edit_alert_screen.dart';
import 'specific_screen.dart';
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
  AlertObject.empty()
      : id = '',
        dateTimeCreated = '',
        dateTimeCompleted = '',
        isCompleted = false,
        isSpecific = true,
        location = '',
        latitude = 0,
        longitude = 0,
        reminder = '',
        userId = '',
        triggerDistance = 0,
        triggerUnits = '';
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
  double _toggleButtonFontSize = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'Alerts Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle(),
          backgroundColor: myAlertsAppBar,
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
            return Center(
                child: CircularProgressIndicator(
              color: myAlertsProgressIndicator,
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

  Card reminderCard(AlertObject alertObject) {
    Icon icon;
    if (this.widget.alertList == AlertList.NOT_COMPLETED) {
      icon = Icon(
        Icons.edit,
        color: myAlertsCardIcon,
        size: _cardIconSize,
      );
    } else {
      icon = Icon(
        Icons.restore,
        color: restoreAlertsCardIcon,
        size: _cardIconSize,
      );
    }

    return Card(
        elevation: 2,
        color: myAlertsCardBackground,
        margin: EdgeInsets.fromLTRB(0, _cardGap, 0, _cardGap),
        shape: RoundedRectangleBorder(
            side:
                BorderSide(color: myAlertsCardBorder, width: _cardBorderWidth),
            borderRadius: BorderRadius.circular(_cardCornerRadius)),
        child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(
                _cardPaddingRightLeft,
                _cardPaddingTopBottom,
                _cardPaddingRightLeft,
                _cardPaddingTopBottom),
            isThreeLine: true,
            title: reminderCardTitleText(alertObject.reminder),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              reminderCardLocationText(
                  '${_languageServices.myAlertsTileLocation}: ${alertObject.location}'),
              reminderCardDateText(
                  '${_languageServices.myAlertsTileDate}: ${alertObject.dateTimeCreated}')
            ]),
            trailing: Container(
                height: double.infinity,
                child: icon), // This vertically centers the icon
            onTap: () {
              if (this.widget.alertList == AlertList.NOT_COMPLETED) {
                Navigator.of(context)
                    .push(createRoute(
                        //EditAlertScreen(alert: alertObject), 'from_right'))
                        SpecificScreen(
                            screen: ScreenType.EDIT, alert: alertObject),
                        'from_right'))
                    .then((value) => setState(() {
                          checkIfInstaPop(value);
                        }));
              } else {
                // Set reminder field isComplete to false
                _dbServices.updateRemindersSpecificAlertRestore(
                    context, alertObject.id);
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
          _toggleButtonFontSize,
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
            backgroundColor: restoreAlertsBackButton,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(_backButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: restoreAlertsBackIcon,
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
      color: myAlertsFirstLine,
      font: font_cards,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardLocationText(String text) {
    return FormattedText(
      text: text,
      size: _cardBodyFontSize,
      color: myAlertsSecondLine,
      font: font_cards,
      decoration: TextDecoration.underline,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardDateText(String text) {
    return FormattedText(
      text: text,
      size: _cardSubtitleFontSize,
      color: myAlertsThirdLine,
      font: font_cards,
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
      color: myAlertsTitleText,
      font: font_appBarText,
      weight: FontWeight.bold,
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
      color: myAlertsExplainerText,
      align: TextAlign.center,
      font: font_cards,
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
      color: myAlertsNoneYetText,
      font: font_nakedText,
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
    _cardGap = (3 / 781) * _screenHeight;
    _cardPaddingTopBottom = (8 / 781) * _screenHeight;
    _bottomPadding = (90 / 781) * _screenHeight;

    // Width
    _buttonWidthMaster = (325 / 392) * _screenWidth;
    _fabSpacing = (5 / 392) * _screenWidth;
    _buttonWidth = (_buttonWidthMaster - _fabSpacing) * 0.70;
    _fabMapWidth = (_buttonWidthMaster - _fabSpacing) * 0.30;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _explainerTextPadding = (12 / 392) * _screenWidth;
    _listViewPaddingSides = (12 / 392) * _screenWidth;
    _cardPaddingRightLeft = (12 / 392) * _screenWidth;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height * langScale;
    _cardTitleFontSize = (26 / 60) * _buttonHeight * langScale;
    _cardBodyFontSize = (19 / 60) * _buttonHeight * langScale;
    _cardSubtitleFontSize = (16 / 60) * _buttonHeight * langScale;
    _explainerTextFontSize = (16 / 781) * _screenHeight * langScale;
    _backButtonFontSize = (24 / 60) * _buttonHeight * langScale;
    _noAlertsYetText = (26 / 781) * _screenHeight * langScale;
    _toggleButtonFontSize = (16 / 781) * _screenHeight;

    // Icons
    _cardIconSize = (34 / 60) * _buttonHeight;
    _backButtonIconSize = (24 / 60) * _buttonHeight;
    _mapButtonIconSize = (30 / 60) * _buttonHeight;

    // Styling
    _cardBorderWidth = (3 / 60) * _buttonHeight;
    _cardCornerRadius = 15;
    _backButtonCornerRadius = (10 / 60) * _buttonHeight;
  }
}
