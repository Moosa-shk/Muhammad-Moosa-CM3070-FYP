// ===============================================================
// AuthGate
// ---------------------------------------------------------------
// This widget acts as a central authentication gate for the app.
// It checks whether a user is currently authenticated.
//
// If a user is logged in → the HomeScreen is displayed.
// If no user is logged in → the LoginScreen is displayed.
//
// The widget uses GetX reactive state (Obx) to automatically
// update the UI whenever the authentication state changes.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dashboard/home_screen.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Retrieve the currently authenticated user from AuthController
      final user = AuthController.to.currentUser.value;

      // If no user is logged in, show the login screen
      if (user == null) {
        return const LoginScreen();
      }

      // If a user is logged in, navigate to the main home screen
      return const HomeScreen();
    });
  }
}