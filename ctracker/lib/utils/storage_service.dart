import 'dart:convert';

import 'package:ctracker/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveUser(User user) async {
    String userJson =
        jsonEncode(user.toJson()); // Convert user data to a JSON string
    await _prefs.setString('user', userJson);
  }

  User? getUser() {
    String? userJson = _prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(
          jsonDecode(userJson)); // Convert JSON string back to a User object
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }
}
