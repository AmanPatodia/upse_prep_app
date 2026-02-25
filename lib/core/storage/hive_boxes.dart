import 'package:hive/hive.dart';

import '../constants/app_constants.dart';

class HiveBoxes {
  HiveBoxes._();

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox(AppConstants.subjectsBox),
      Hive.openBox(AppConstants.mcqAttemptsBox),
      Hive.openBox(AppConstants.pyqAttemptsBox),
      Hive.openBox(AppConstants.pyqBankBox),
      Hive.openBox(AppConstants.currentAffairsBox),
      Hive.openBox(AppConstants.bookmarksBox),
      Hive.openBox(AppConstants.settingsBox),
      Hive.openBox(AppConstants.authBox),
    ]);
  }
}
