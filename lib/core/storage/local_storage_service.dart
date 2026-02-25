import 'package:hive/hive.dart';

class LocalStorageService {
  const LocalStorageService();

  Future<void> save(
    String boxName,
    String key,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }

  Map<String, dynamic>? get(String boxName, String key) {
    final box = Hive.box(boxName);
    final value = box.get(key);
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return null;
  }

  Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }
}
