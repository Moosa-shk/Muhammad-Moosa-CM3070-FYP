// ===============================================================
// login_screen.dart
// ---------------------------------------------------------------
// This screen provides the login interface for the application.
// Users can enter their email and password to authenticate
// through Firebase Authentication.
//
// The screen uses reusable UI components defined in auth_ui.dart
// such as:
// • AuthGlassCard
// • AuthField
// • AuthPrimaryButton
//
// The AnimatedAuthScaffold widget provides a modern animated
// background and layout used across authentication screens.
// ===============================================================

import 'package:disaster_app_ui/screens/auth/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';

import 'animated_auth_scaffold.dart';
import '../dashboard/home_screen.dart';
import 'auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  /// Controllers for email and password input fields
  final email = TextEditingController();
  final password = TextEditingController();

  /// Indicates if login process is running
  bool loading = false;

  /// Controller used to animate the logo
  late final AnimationController _logoCtrl;

  // ===============================================================
  // initState()
  // ---------------------------------------------------------------
  // Initializes the logo animation which creates a subtle floating
  // and scaling effect for better visual interaction.
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  // ===============================================================
  // dispose()
  // ---------------------------------------------------------------
  // Cleans up controllers when the widget is removed from memory
  // to prevent memory leaks.
  // ===============================================================

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // LOGIN FUNCTION
  // ---------------------------------------------------------------
  // This method calls the AuthController to authenticate the user
  // using the provided email and password.
  // ===============================================================

  Future<void> _login() async {

    setState(() => loading = true);

    final err = await AuthController.to.login(
      email.text.trim(),
      password.text.trim(),
    );

    setState(() => loading = false);

    // Display error if login fails
    if (err != null) {
      Get.snackbar("Login Failed", err);
      return;
    }

    // Navigate to home screen if login succeeds
    Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn);
  }

  // ===============================================================
  // UI BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedAuthScaffold(
      title: "Welcome back",
      subtitle: "Sign in to continue",
      scroll: false,

      child: Expanded(
        child: Column(
          children: [

            const SizedBox(height: 18),

            // ===============================================================
            // LOGO ANIMATION
            // ---------------------------------------------------------------
            // Creates a floating animation effect for the app logo
            // to improve the visual appearance of the login screen.
            // ===============================================================

            AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, __) {

                final t = _logoCtrl.value;

                final dy = (t - 0.5) * 10;

                final scale =
                    1.0 + (0.04 * (0.5 - (t - 0.5).abs()) * 2);

                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 96,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // ===============================================================
            // LOGIN FORM CARD
            // ===============================================================

            AuthGlassCard(
              child: Column(
                children: [

                  /// Email input
                  AuthField(
                    controller: email,
                    label: "Email",
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  /// Password input
                  AuthField(
                    controller: password,
                    label: "Password",
                    icon: Icons.lock_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,

                    /// Allow login when user presses enter
                    onSubmitted: (_) => loading ? null : _login(),
                  ),

                  const SizedBox(height: 18),

                  /// Login button
                  AuthPrimaryButton(
                    title: "Login",
                    loading: loading,
                    onTap: loading ? null : _login,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ===============================================================
            // SIGNUP NAVIGATION
            // ---------------------------------------------------------------
            // Redirects users to the signup screen if they do not
            // already have an account.
            // ===============================================================

            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: GestureDetector(
                onTap: () => Get.to(
                  () => const SignupScreen(),
                  transition: Transition.rightToLeft,
                ),
                child: TextWidget(
                  "New user? Sign Up",
                  color: AppColor.primary,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}