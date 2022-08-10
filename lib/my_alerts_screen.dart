import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'edit_alert_screen.dart';
import 'start_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class ReminderTile {
  String id;
  String dateTimeCreated;
  String dateTimeCompleted;
  bool isCompleted;
  bool isSpecific;
  String location;
  String reminder;
  String userId;
  ReminderTile(
      {required this.id,
      required this.dateTimeCreated,
      required this.dateTimeCompleted,
      required this.isCompleted,
      required this.isSpecific,
      required this.location,
      required this.reminder,
      required this.userId});
}

// Firebase cloud firestore
CollectionReference reminders =
    FirebaseFirestore.instance.collection('reminders');

class MyAlertsScreen extends StatefulWidget {
  const MyAlertsScreen({Key? key}) : super(key: key);

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            return listViewReminders(createreminderObjects(snapshotReminders));
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(s_blackBlue),
            ));
          }
        });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveReminders() {
    var snapshot = FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .snapshots();
    return snapshot;
  }

  List<ReminderTile> createreminderObjects(
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
              // Old way: From the bottom
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditAlertScreen(reminderTile: reminderTile)),
              // );
              // New way: From a direction
              Navigator.of(context).push(createRoute(
                  EditAlertScreen(reminderTile: reminderTile), 'from_right'));
            }));
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
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pop(context, createRoute(const StartScreen(), 'from_left'));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_darkSalmon),
            fixedSize: Size(buttonWidth / 2, buttonHeight / 2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(
            width: buttonWidth / 12,
          ),
          backText('Back')
        ]));
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
