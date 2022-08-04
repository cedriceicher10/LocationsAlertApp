import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class ReminderTile {
  Timestamp dateTimeCreated;
  Timestamp dateTimeCompleted;
  bool isCompleted;
  bool isSpecific;
  String location;
  String reminder;
  String userId;
  ReminderTile(
      {required this.dateTimeCreated,
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
    return Column(children: [
      listViewReminderBuilder(),
      SizedBox(height: buttonSpacing),
      cancelButton(buttonWidth, buttonHeight)
    ]);
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
        .snapshots();
    return snapshot;
  }

  List<ReminderTile> createreminderObjects(
      AsyncSnapshot<QuerySnapshot> snapshotReminders) {
    List<ReminderTile> reminderObjects = [];
    for (var index = 0; index < snapshotReminders.data!.docs.length; ++index) {
      // Convert to lightweight reminder tile objects
      ReminderTile reminderTile = ReminderTile(
          dateTimeCompleted: snapshotReminders.data!.docs[index]
              ['dateTimeCompleted'],
          dateTimeCreated: snapshotReminders.data!.docs[index]
              ['dateTimeCreated'],
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
    return Flexible(
        child: ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: reminderObjects.length,
      itemBuilder: (context, index) {
        var post = reminderObjects[index];
        return reminderCard(post);
      },
    ));
  }

  Card reminderCard(ReminderTile reminderTile) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(s_aquarium), width: 3),
            borderRadius: BorderRadius.circular(15)),
        child: ListTile(
            isThreeLine: true,
            title: Text(reminderTile.reminder),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(reminderTile.location),
              Text('Date Created: ${reminderTile.dateTimeCreated}')
            ]),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 24,
            ),
            onTap: () {}));
  }

  Widget cancelButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const StartScreen()),
              (Route<dynamic> route) => false);
        },
        style: ElevatedButton.styleFrom(
            primary: const Color(s_darkSalmon),
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
}
