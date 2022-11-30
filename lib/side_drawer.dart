import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'database_services.dart';
import 'formatted_text.dart';
import 'styles.dart';

class SideDrawer extends StatelessWidget {
  SideDrawer({super.key});
  // Services
  final DatabaseServices _dbServices = DatabaseServices();
  userInfo _userInfo = userInfo.init();

  double _sideDrawerHeaderHeight = 0;
  double _sideDrawerTitleFontSize = 0;
  double _sideDrawerItemFontSize = 0;
  double _sideDrawerIconSize = 0;
  double _spacerHeight = 0;
  double _sideDrawerUserNoFontSize = 0;
  double _spacerBottomHeight = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout(context);
    return FutureBuilder(
        future: initFunctions(context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return sideDrawer();
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(s_darkSalmon),
            ));
          }
        });
  }

  Future<bool> initFunctions(BuildContext context) async {
    _userInfo = await _dbServices.getUsersSnapshot(context);
    return true;
  }

  Widget sideDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
              height: _sideDrawerHeaderHeight,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(s_darkSalmon),
                ),
                child: sideDrawerTitle('User Id: $UUID_GLOBAL'),
              )),
          listTileDate(_userInfo.firstLogin),
          listTileDate(_userInfo.lastLogin),
          listTileNoAction('Alerts Created: ${_userInfo.remindersCreated}'),
          listTileNoAction('Alerts Completed: ${_userInfo.remindersCompleted}'),
          listTileNoAction(
              'Alerts Completion: ${alertCompletion(_userInfo.remindersCompleted, _userInfo.remindersCreated)}%'),
          // ListTile(
          //   dense: true,
          //   title: settingDrawerItem('Dark Mode'),
          //   onTap: () {},
          // ),
          SizedBox(height: _spacerHeight),
          Divider(height: 2, thickness: 0.5, color: Colors.grey),
          SizedBox(height: _spacerBottomHeight),
          ListTile(
            dense: true,
            title: userNoText(_userInfo.userNo),
            onTap: () {},
          )
        ],
      ),
    );
  }

  String alertCompletion(int completed, int created) {
    if (completed > created) {
      return '-';
    } else if ((completed == 0) && (created == 0)) {
      return '-';
    } else {
      return ((created / completed) * 100).toString();
    }
  }

  Widget userNoText(int userNo) {
    int zeros = 6 - userNo.toString().length;
    String userNoString = ('0' * zeros) + userNo.toString();
    return FormattedText(
        text: 'User No: #$userNoString',
        size: _sideDrawerUserNoFontSize,
        color: Color(s_aquarium),
        font: s_font_IBMPlexSans,
        align: TextAlign.center,
        weight: FontWeight.bold);
  }

  Widget listTileDate(Timestamp timestamp) {
    return ListTile(
      dense: true,
      title: settingDrawerItem(
          'First Login: ${convertToDateTimeFormat(timestamp)}'),
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

  Widget sideDrawerTitle(String text) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            color: Colors.white,
            size: _sideDrawerIconSize,
          ),
          SizedBox(width: 2),
          FormattedText(
              text: text,
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
        color: Color(s_blackBlue),
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  String convertToDateTimeFormat(Timestamp timestamp) {
    return DateFormat.yMd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000));
  }

  void generateLayout(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _sideDrawerHeaderHeight = (80 / 781) * _screenHeight;
    _spacerHeight = (375 / 781) * _screenHeight;
    _spacerBottomHeight = (50 / 781) * _screenHeight;

    // Font
    _sideDrawerTitleFontSize = (15 / 781) * _screenHeight;
    _sideDrawerItemFontSize = (12 / 781) * _screenHeight;
    _sideDrawerUserNoFontSize = (16 / 781) * _screenHeight;

    // Icons
    _sideDrawerIconSize = (20 / 80) * _sideDrawerHeaderHeight;
  }
}
