// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import 'database_services.dart';
// import 'start_screen.dart';
// import 'formatted_text.dart';
// import 'styles.dart';
// import 'go_back_button.dart';
// import 'background_theme.dart';

// // // *****************************************************************************
// // // ATTN: THIS IS OBS AFTER THE DECISION TO ONLY GO FOR SPECIFIC ALERTS.
// // // *****************************************************************************

// // To get this to mirror SpecificScreen
// //   - Styling
// //   - Layout
// //   - Layout responsiveness

// // Firebase cloud firestore
// CollectionReference reminders =
//     FirebaseFirestore.instance.collection('reminders');

// class GenericScreen extends StatefulWidget {
//   const GenericScreen({Key? key}) : super(key: key);

//   @override
//   State<GenericScreen> createState() => _GenericScreenState();
// }

// class _GenericScreenState extends State<GenericScreen> {
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final DatabaseServices _dbServices = DatabaseServices();
//   final BackgroundTheme _background =
//       BackgroundTheme(Screen.GENERIC_ALERT_SCREEN);
//   String _reminderBody = '';
//   String _genericLocation = 'Grocery Store';
//   final double topPadding = 80;
//   final double textWidth = 325;
//   final double buttonWidth = 260;
//   final double buttonHeight = 60;
//   final double buttonSpacing = 10;

//   @override
//   Widget build(BuildContext context) {
//     // Wrapping the MaterialApp allows the user to tap anywhere on the screen
//     // to remove the keyboard focus
//     // See: https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
//     return GestureDetector(
//         onTap: () {
//           FocusScopeNode currentFocus = FocusScope.of(context);
//           if (!currentFocus.hasPrimaryFocus) {
//             currentFocus.unfocus();
//           }
//         },
//         child: MaterialApp(
//           title: 'Generic Screen',
//           home: Scaffold(
//             appBar: AppBar(
//               title: genericScreenTitle('Generic Alert'),
//               backgroundColor: const Color(s_aquarium),
//               centerTitle: true,
//             ),
//             resizeToAvoidBottomInset: false,
//             body: genericScreenBody(),
//           ),
//         ));
//   }

//   Widget genericScreenBody() {
//     return Container(
//         decoration: _background.getBackground(),
//         child: SizedBox(
//             height: 500,
//             width: 400,
//             child: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                     child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                       SizedBox(height: topPadding),
//                       titleText('Remind me to...'),
//                       SizedBox(width: textWidth, child: reminderEntry()),
//                       SizedBox(height: buttonSpacing),
//                       titleText('At the generic location...'),
//                       SizedBox(width: textWidth, child: locationEntry()),
//                       SizedBox(height: buttonSpacing * 2),
//                       submitButton(buttonWidth, buttonHeight),
//                       SizedBox(height: buttonSpacing / 2),
//                       cancelButton(buttonWidth, buttonHeight)
//                     ])))));
//   }

//   Widget reminderEntry() {
//     return TextFormField(
//         autofocus: true,
//         style: const TextStyle(color: Colors.black),
//         decoration: const InputDecoration(
//             labelStyle: TextStyle(
//                 color: Color(s_aquarium), fontWeight: FontWeight.bold),
//             hintText: 'Pick up some laundry detergent',
//             hintStyle: TextStyle(color: Color(s_disabledGray)),
//             errorStyle: TextStyle(
//                 color: Color(s_declineRed), fontWeight: FontWeight.bold),
//             border: OutlineInputBorder(),
//             focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(s_aquarium), width: 2.0))),
//         onSaved: (value) {
//           _reminderBody = value!;
//         },
//         validator: (value) {
//           if (value!.isEmpty) {
//             return 'Please enter a reminder';
//           } else {
//             return null;
//           }
//         });
//   }

//   Widget locationEntry() {
//     return Center(
//         child: DropdownButton<String>(
//             icon: const Icon(Icons.add_location_alt_outlined),
//             iconEnabledColor: const Color(s_aquarium),
//             items: generalLocations(),
//             value: _genericLocation,
//             onChanged: (value) {
//               setState(() {
//                 _genericLocation = value!;
//               });
//             }));
//   }

//   Widget submitButton(double buttonWidth, double buttonHeight) {
//     return ElevatedButton(
//         onPressed: () async {
//           if (formKey.currentState!.validate()) {
//             formKey.currentState?.save();
//             // Put in Firestore cloud database
//             _dbServices.addToRemindersDatabase(context, _reminderBody, false,
//                 false, _genericLocation, 404, 404, 404, 'null');
//             // Remove keyboard
//             FocusScopeNode currentFocus = FocusScope.of(context);
//             if (!currentFocus.hasPrimaryFocus) {
//               currentFocus.unfocus();
//             }
//             Navigator.pop(context);
//           }
//         },
//         style: ElevatedButton.styleFrom(
//             primary: const Color(s_aquarium),
//             fixedSize: Size(buttonWidth, buttonHeight)),
//         child:
//             Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
//           Icon(
//             Icons.add,
//             color: Colors.white,
//             size: 32,
//           ),
//           SizedBox(
//             width: 4,
//           ),
//           FormattedText(
//             text: 'Create Alert',
//             size: s_fontSizeMedium,
//             color: Colors.white,
//             font: s_font_BonaNova,
//             weight: FontWeight.bold,
//             align: TextAlign.center,
//           )
//         ]));
//   }

//   Widget cancelButton(double buttonWidth, double buttonHeight) {
//     return GoBackButton().back('Cancel', buttonWidth, buttonHeight, 20, 24, 10,
//         context, Color(s_declineRed));
//   }

//   Widget cancelText(String text) {
//     return FormattedText(
//       text: text,
//       size: s_fontSizeSmall,
//       color: Colors.white,
//       font: s_font_BonaNova,
//       weight: FontWeight.bold,
//     );
//   }

//   Widget genericScreenTitle(String title) {
//     return FormattedText(
//       text: title,
//       size: s_fontSizeLarge,
//       color: Colors.white,
//       font: s_font_BerkshireSwash,
//     );
//   }

//   Widget titleText(String title) {
//     return FormattedText(
//         text: title,
//         size: s_fontSizeMedLarge,
//         color: const Color(s_blackBlue),
//         font: s_font_BonaNova,
//         weight: FontWeight.bold);
//   }
// }
