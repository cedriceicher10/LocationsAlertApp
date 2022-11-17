import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'edit_alert_screen.dart';
import 'start_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'background_theme.dart';
import 'go_back_button.dart';

class ReminderTile {
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
  ReminderTile(
      {required this.id,
      required this.dateTimeCreated,
      required this.dateTimeCompleted,
      required this.isCompleted,
      required this.isSpecific,
      required this.location,
      required this.latitude,
      required this.longitude,
      required this.reminder,
      required this.userId});
}

class MyAlertsScreen extends StatefulWidget {
  const MyAlertsScreen({Key? key}) : super(key: key);

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'My Alerts Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle('My Alerts'),
          backgroundColor: const Color(s_darkSalmon),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: myAlertsScreenBody(),
        floatingActionButton: backButtonFAB(),
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

  // Widget myAlertsScreenBody() {
  //   return SingleChildScrollView(
  //       child: Container(
  //           decoration: _background.getBackground(),
  //           child: ConstrainedBox(
  //               constraints: BoxConstraints(minHeight: _screenHeight),
  //               child: Column(children: [
  //                 listViewReminderBuilder(),
  //                 SizedBox(height: _buttonSpacing),
  //                 Container(
  //                     padding: EdgeInsets.fromLTRB(
  //                         _explainerTextPadding, 0, _explainerTextPadding, 0),
  //                     child: explainerText()),
  //                 SizedBox(height: _bottomPadding),
  //                 // backButton(_buttonWidth, _buttonHeight),
  //                 // SizedBox(height: _bottomPadding)
  //               ]))));
  // }

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
              return Center(child: noAlertsYetText('No alerts created yet!'));
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
    return _dbServices.getRemindersIncompleteAlertsSnapshotCall();
  }

  List<ReminderTile> createReminderObjects(
      AsyncSnapshot<QuerySnapshot> snapshotReminders) {
    List<ReminderTile> reminderObjects = [];
    for (var index = 0; index < snapshotReminders.data!.docs.length; ++index) {
      // Convert to lightweight reminder tile objects
      ReminderTile reminderTile = ReminderTile(
          id: snapshotReminders.data!.docs[index].id,
          dateTimeCompleted: DateFormat.yMMMMd('en_US').add_jm().format(
              snapshotReminders.data!.docs[index]['dateTimeCompleted']
                  .toDate()),
          dateTimeCreated: DateFormat.yMMMMd('en_US').add_jm().format(
              snapshotReminders.data!.docs[index]['dateTimeCreated'].toDate()),
          isCompleted: snapshotReminders.data!.docs[index]['isCompleted'],
          isSpecific: snapshotReminders.data!.docs[index]['isSpecific'],
          location: snapshotReminders.data!.docs[index]['location'],
          latitude: snapshotReminders.data!.docs[index]['latitude'],
          longitude: snapshotReminders.data!.docs[index]['longitude'],
          reminder: snapshotReminders.data!.docs[index]['reminderBody'],
          userId: snapshotReminders.data!.docs[index]['userId']);
      reminderObjects.add(reminderTile);
    }
    return reminderObjects;
  }

  Widget listViewReminders(List<ReminderTile> reminderObjects) {
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

  Card reminderCard(ReminderTile reminderTile) {
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
            title: reminderCardTitleText(reminderTile.reminder),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              reminderCardLocationText('at: ${reminderTile.location}'),
              reminderCardDateText(
                  'Date Created: ${reminderTile.dateTimeCreated}')
            ]),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(s_darkSalmon),
              size: _cardIconSize,
            ),
            onTap: () {
              Navigator.of(context)
                  .push(createRoute(EditAlertScreen(reminderTile: reminderTile),
                      'from_right'))
                  .then((value) => setState(() {
                        checkIfInstaPop(value);
                      }));
            }));
  }

  void checkIfInstaPop(bool value) {
    if (value) {
      Navigator.pop(context);
    }
  }

  Widget backButtonFAB() {
    return Container(
        height: _buttonHeight,
        width: _buttonWidth,
        child: FloatingActionButton.extended(
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
              // Expanded(
              //     child: SizedBox(
              //   width: 1,
              // )),
              SizedBox(
                width: 8,
              ),
              buttonText('Back', _backButtonFontSize)
            ])));
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

  // This was the old back button at the bottom of the list instead of the current FAB
  Widget backButton(double buttonWidth, double buttonHeight) {
    return GoBackButton().back(
        'Back',
        buttonWidth,
        buttonHeight,
        _backButtonFontSize,
        _backButtonIconSize,
        _backButtonCornerRadius,
        context,
        Color(s_darkSalmon));
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

  Widget myAlertsScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget explainerText() {
    return FormattedText(
      text:
          'These are your current active location alerts.\n Once an alert is marked as complete it will be removed.\n Tap an alert to edit it.',
      size: _explainerTextFontSize,
      color: Color(s_darkSalmon),
      align: TextAlign.center,
      font: s_font_IBMPlexSans,
    );
  }

  Widget noAlertsYetText(String text) {
    return FormattedText(
      text: text,
      size: _noAlertsYetText,
      color: Color(s_darkSalmon),
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
    _buttonWidth = (325 / 392) * _screenWidth;
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
    _cardIconSize = (24 / 60) * _buttonHeight;
    _backButtonIconSize = (24 / 60) * _buttonHeight;

    // Styling
    _cardBorderWidth = (3 / 60) * _buttonHeight;
    _cardCornerRadius = 15;
    _backButtonCornerRadius = (10 / 60) * _buttonHeight;
  }
}
