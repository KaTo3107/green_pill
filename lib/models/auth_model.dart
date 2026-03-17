import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier{
  static bool isLoggedIn = false;
  static String authenticationToken = '';

  bool get isAuthenticated => isLoggedIn;
  String get token => authenticationToken;

  Future<void> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (username == 'user' && password == 'password') {
      isLoggedIn = true;
      authenticationToken = 'dummy_token';
      notifyListeners();
    } else {
      throw Exception('Ungültige Anmeldedaten');
    }
  }

  void logout() {
    isLoggedIn = false;
    authenticationToken = '';
    notifyListeners();
  }
}