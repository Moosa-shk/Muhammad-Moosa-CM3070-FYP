// lib/screens/auth/login_screen.dart

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
    with SingleTickerProviderStateMixin {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    final err = await AuthController.to.login(
      email.text.trim(),
      password.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (err != null) {
      Get.snackbar(
        "Login Failed",
        err,
      );
      return;
    }

    Get.offAll(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAuthScaffold(
      title: null,
      subtitle: null,
      scroll: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Expanded(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),

                _brand(),

                const SizedBox(height: 42),

                const TextWidget(
                  "Welcome back",
                  size: 29,
                  weight: FontWeight.w900,
                  color: AppColor.text,
                ),

                const SizedBox(height: 8),

                const TextWidget(
                  "Sign in to your account",
                  size: 14,
                  weight: FontWeight.w500,
                  color: AppColor.textMuted,
                ),

                const SizedBox(height: 30),

                const TextWidget(
                  "Email",
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColor.text,
                ),

                const SizedBox(height: 8),

                AuthField(
                  controller: email,
                  label: "Email address",
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 18),

                const TextWidget(
                  "Password",
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColor.text,
                ),

                const SizedBox(height: 8),

                AuthField(
                  controller: password,
                  label: "Password",
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!loading) {
                      _login();
                    }
                  },
                ),

                const SizedBox(height: 26),

                AuthPrimaryButton(
                  title: "Sign in",
                  loading: loading,
                  onTap: loading ? null : _login,
                ),

                const Spacer(),

                _signupLink(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColor.border,
            ),
          ),
          child: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 12),

        const TextWidget(
          "RescueAid",
          size: 18,
          weight: FontWeight.w900,
          color: AppColor.text,
        ),
      ],
    );
  }

  Widget _signupLink() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TextWidget(
            "Don't have an account?",
            size: 13,
            weight: FontWeight.w500,
            color: AppColor.textMuted,
          ),

          const SizedBox(width: 5),

          GestureDetector(
            onTap: () {
              Get.to(
                () => const SignupScreen(),
                transition: Transition.rightToLeft,
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: TextWidget(
                "Sign up",
                size: 13,
                weight: FontWeight.w900,
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}