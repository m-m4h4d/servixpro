import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool('isDarkMode', isDark);
  }

  static bool get isDarkMode => _prefs.getBool('isDarkMode') ?? true;

  static Future<void> setLoggedInUserId(String id) async {
    await _prefs.setString('loggedInUserId', id);
  }

  static String? get loggedInUserId => _prefs.getString('loggedInUserId');

  static Future<void> clearSession() async {
    await _prefs.remove('loggedInUserId');
  }
}
