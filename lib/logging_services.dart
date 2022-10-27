import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

enum logType { INFO, WARNING, CRITICAL }

class LoggingServices {
  String _filename = 'logs_LocationAlerts.log';

  void setFilename(String filename) {
    _filename = filename;
  }

  String getFilename(String filename) {
    return _filename;
  }

  Future<void> log(
      logType type, String location, int lineNum, String content) async {
    final directory = await getExternalStorageDirectory();
    print('Writing to: ${directory?.path}/$_filename');
    File logFile = File('${directory?.path}/$_filename');
    logFile.writeAsString(generatePayload(type, location, lineNum, content));

    // TEST
    final contents = await logFile.readAsString();
    print('TEST: contents = $contents');
  }

  String generatePayload(
      logType type, String location, int lineNum, String content) {
    String time = getTimeNow();
    return '$time:\t$type\t$location:$lineNum\t$content';
  }

  String getTimeNow() {
    // 'Thu, 5/23/2013 10:21:47 AM'
    return DateFormat.yMEd().add_jms().format(DateTime.now());
  }
}
