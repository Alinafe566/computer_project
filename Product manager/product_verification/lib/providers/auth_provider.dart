import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setBool('isLoggedIn', true);
    
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      final userJson = prefs.getString('user');
      if (userJson != null) {
        _user = User.fromJson(jsonDecode(userJson));
        _isLoggedIn = true;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}