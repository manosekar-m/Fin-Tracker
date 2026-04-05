import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxName = "transactions";
  static const String settingsBox = "settings";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBox);
  }

  static Future<Box> openBox() async {
    return await Hive.openBox(boxName);
  }

  static Box getSettingsBox() {
    return Hive.box(settingsBox);
  }
}
