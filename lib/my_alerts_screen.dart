import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'edit_alert_screen.dart';
import 'start_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
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

  final double buttonWidth = 260;
  final double buttonHeight = 60;
  final double buttonSpacing = 10;

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }

  Widget myAlertsScreenBody() {
    return SingleChildScrollView(
        child: Column(children: [
      listViewReminderBuilder(),
      SizedBox(height: buttonSpacing),
      Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: explainerText()),
      SizedBox(height: buttonSpacing),
      backButton(buttonWidth, buttonHeight)
    ]));
  }

  Widget listViewReminderBuilder() {
    return StreamBuilder(
        stream: retrieveReminders(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshotReminders) {
          if (snapshotReminders.hasData) {
            // Create list view
            return listViewReminders(createReminderObjects(snapshotReminders));
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(s_blackBlue),
            ));
          }
        });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveReminders() {
    return _dbServices.getIncompleteAlertsSnapshotCall();
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
      physics:
          NeverScrollableScrollPhysics(), // allows precedence to be taken by SingleChildScrollView()?
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(s_aquarium), width: 3),
            borderRadius: BorderRadius.circular(15)),
        child: ListTile(
            isThreeLine: true,
            title: reminderCardTitleText(reminderTile.reminder),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              reminderCardLocationText('at: ${reminderTile.location}'),
              reminderCardDateText(
                  'Date Created: ${reminderTile.dateTimeCreated}')
            ]),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(s_darkSalmon),
              size: 24,
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

  Widget reminderCardTitleText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeMedium,
      color: const Color(s_blackBlue),
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardLocationText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall - 2,
      color: const Color(s_darkSalmon),
      font: s_font_IBMPlexSans,
      decoration: TextDecoration.underline,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardDateText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeExtraSmall,
      color: const Color(s_blackBlue),
      font: s_font_IBMPlexSans,
      style: FontStyle.italic,
      weight: FontWeight.bold,
    );
  }

  Widget backButton(double buttonWidth, double buttonHeight) {
    return GoBackButton().back('Back', buttonWidth, buttonHeight, 20, 24, 10,
        context, Color(s_darkSalmon));
  }

  Widget backText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget myAlertsScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget explainerText() {
    return const FormattedText(
      text:
          'These are your current active location alerts.\n An alert will notify you when it is at the location specified!\n Once an alert is marked as finished it will be removed.\n Tap an alert to edit it.',
      size: s_fontSizeExtraSmall,
      color: Color(s_blackBlue),
      align: TextAlign.center,
      font: s_font_IBMPlexSans,
    );
  }
}
