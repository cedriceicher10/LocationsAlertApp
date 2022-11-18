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
                child: sideDrawerTitle('User: #$UUID_GLOBAL'),
              )),
          listTileDate(_userInfo.firstLogin),
          listTileDate(_userInfo.lastLogin),
          listTileNoAction(
              'Reminders Completed: ${_userInfo.remindersCompleted}'),
          listTileNoAction('Reminders Created: ${_userInfo.remindersCreated}'),
          listTileNoAction('Reminders Updated: ${_userInfo.remindersUpdated}'),
          listTileNoAction('Reminders Deleted: ${_userInfo.remindersDeleted}'),
          ListTile(
            dense: true,
            title: settingDrawerItem('Light Mode'),
            onTap: () {},
          ),
          ListTile(
            dense: true,
            title: settingDrawerItem('Units'),
            onTap: () {},
          ),
        ],
      ),
    );
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

    // Font
    _sideDrawerTitleFontSize = (16 / 781) * _screenHeight;
    _sideDrawerItemFontSize = (12 / 781) * _screenHeight;

    // Icons
    _sideDrawerIconSize = (20 / 80) * _sideDrawerHeaderHeight;
  }
}
