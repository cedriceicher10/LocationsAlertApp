import 'package:shared_preferences/shared_preferences.dart';

class RecentLocations {
  var recentLocations = ['Make a few reminders to see their locations here!'];
  Map recentLocationsMap = new Map();

  Future<void> retrieveRecentLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentLocationsList =
        prefs.getStringList('recentLocationsList');
    if ((recentLocationsList != null) && (recentLocationsList.length != 0)) {
      recentLocations.clear();
      for (int index = 0; index < recentLocationsList.length; ++index) {
        recentLocations
            .add(_shortenRecentLocations(recentLocationsList[index]));
        recentLocationsMap[
                _shortenRecentLocations(recentLocationsList[index])] =
            recentLocationsList[index];
      }
    }
    // Remove duplicates
    recentLocations = recentLocations.toSet().toList();
  }

  String _shortenRecentLocations(String longRecentLocation) {
    int RECENT_LOCATION_MAX_STRING_LENGTH = 70;
    // Shorten recent location strings that are >RECENT_LOCATION_MAX_STRING_LENGTH characters long
    if (longRecentLocation.length < RECENT_LOCATION_MAX_STRING_LENGTH) {
      return longRecentLocation;
    } else {
      // Split by commas
      List<String> longRecentLocationSplit = longRecentLocation.split(',');
      int stringLength = 0;
      String shortRecentLocation = '';
      for (int index = 0; index < longRecentLocationSplit.length; ++index) {
        stringLength += longRecentLocationSplit[index].length;
        if (stringLength < RECENT_LOCATION_MAX_STRING_LENGTH) {
          shortRecentLocation += longRecentLocationSplit[index];
          shortRecentLocation += ',';
        } else {
          if (shortRecentLocation.endsWith(',')) {
            shortRecentLocation = shortRecentLocation.substring(
                0, shortRecentLocation.length - 1);
          }
        }
      }
      return shortRecentLocation;
    }
  }

  Future<void> add(String locationToUse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentLocationsList =
        prefs.getStringList('recentLocationsList');
    if ((recentLocationsList == null) || (recentLocationsList.length < 5)) {
      recentLocationsList!.insert(0, locationToUse);
      // Remove duplicates
      recentLocationsList = recentLocationsList.toSet().toList();
      prefs.setStringList('recentLocationsList', recentLocationsList);
    } else {
      recentLocationsList.removeLast();
      recentLocationsList.insert(0, locationToUse);
      // Remove duplicates
      recentLocationsList = recentLocationsList.toSet().toList();
      prefs.setStringList('recentLocationsList', recentLocationsList);
    }
  }
}
