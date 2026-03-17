import 'package:flutter/material.dart' show BuildContext, StatelessWidget, Widget;
import 'package:green_pill/models/auth_model.dart';
import 'package:green_pill/pages/home.dart';
import 'package:green_pill/pages/login.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();

    if (auth.isAuthenticated) {
      return const HomePage(title: 'Green Pill Demo');
    } else {
      return const LoginPage();
    }
  }
}