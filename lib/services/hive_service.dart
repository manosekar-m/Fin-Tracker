import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxName = "transactions";
  static const String settingsBox = "settings";
  static const String userBox = "user_profile";
  static const String roughPlansBox = "rough_plans";
  static const String investmentsBox = "investments";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBox);
    await Hive.openBox(userBox);
    await Hive.openBox(roughPlansBox);
    await Hive.openBox(investmentsBox);
  }

  static Future<Box> openBox() async {
    return await Hive.openBox(boxName);
  }

  static Box getSettingsBox() {
    return Hive.box(settingsBox);
  }

  static Box getUserBox() {
    return Hive.box(userBox);
  }

  static Box getRoughPlansBox() {
    return Hive.box(roughPlansBox);
  }

  static Box getInvestmentsBox() {
    return Hive.box(investmentsBox);
  }
}
