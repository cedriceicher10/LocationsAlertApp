import 'dart:io';

bool TEST_FLAG = true;

class AdServices {
  String getInterstitialAdUnitId() {
    if (TEST_FLAG) {
      return 'ca-app-pub-3940256099942544/1033173712'; // TEST AD UNIT
    } else {
      return 'ca-app-pub-3290345787469920/2842420292'; // REAL AD UNIT
    }
  }
}
