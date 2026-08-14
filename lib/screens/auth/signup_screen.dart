// ===============================================================
// signup_screen.dart
// ---------------------------------------------------------------
// This screen allows a new user to create an account for the
// application. The user provides personal information such as:
//
// • Full Name
// • Email
// • Password
// • Phone Number
// • Emergency Contact
// • Blood Group
// • Profile Image
//
// The collected data is sent to Firebase Authentication for
// account creation and stored in Firestore as a user profile.
//
// Profile images are uploaded to Cloudinary and the returned
// URL is saved with the user profile.
//
// This information is important for emergency situations,
// allowing responders or contacts to quickly access critical
// user details.
// ===============================================================

import 'dart:io';

import 'package:disaster_app_ui/screens/auth/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/colors.dart';
import 'animated_auth_scaffold.dart';
import '../dashboard/home_screen.dart';
import 'auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  /// Controllers for user input fields
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final emergency = TextEditingController();

  /// Selected blood group
  String bloodGroup = "A+";

  /// Selected profile photo (optional)
  File? photo;

  /// Indicates whether signup is currently processing
  bool loading = false;

  // ===============================================================
  // dispose()
  // ---------------------------------------------------------------
  // Cleans up controllers to avoid memory leaks when the widget
  // is removed from the widget tree.
  // ===============================================================

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    phone.dispose();
    emergency.dispose();
    super.dispose();
  }

  // ===============================================================
  // pickImage()
  // ---------------------------------------------------------------
  // Opens the device gallery and allows the user to select
  // a profile image.
  // ===============================================================

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() => photo = File(img.path));
    }
  }

  // ===============================================================
  // _validate()
  // ---------------------------------------------------------------
  // Ensures that required fields are not empty before allowing
  // the signup process to start.
  // ===============================================================

  bool _validate() {
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.trim().isEmpty) {

      Get.snackbar(
        "Missing Fields",
        "Name, email and password required",
      );

      return false;
    }

    return true;
  }

  // ===============================================================
  // SIGNUP FUNCTION
  // ---------------------------------------------------------------
  // Sends the entered user data to AuthController which performs:
  // 1. Firebase account creation
  // 2. Profile image upload
  // 3. Firestore user profile storage
  // ===============================================================

  Future<void> _signup() async {

    if (!_validate()) return;

    setState(() => loading = true);

    final err = await AuthController.to.registerFull(
      email: email.text.trim(),
      password: password.text.trim(),
      name: name.text.trim(),
      phone: phone.text.trim(),
      emergency: emergency.text.trim(),
      bloodGroup: bloodGroup,
      profileFile: photo,
    );

    setState(() => loading = false);

    // Show error message if signup fails
    if (err != null) {
      Get.snackbar(
        "Signup Failed",
        err,
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
      return;
    }

    // Navigate to main application after successful signup
    Get.offAll(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
    );
  }

  // ===============================================================
  // UI BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {

    return AnimatedAuthScaffold(
      showBack: true,
      title: "Create account",
      subtitle: "Set up your safety profile",
      scroll: true,

      child: Column(
        children: [

          const SizedBox(height: 12),

          // ===============================================================
          // PROFILE IMAGE PICKER
          // ===============================================================

          _AvatarPicker(photo: photo, onTap: pickImage),

          const SizedBox(height: 18),

          // ===============================================================
          // SIGNUP FORM
          // ===============================================================

          AuthGlassCard(
            child: Column(
              children: [

                AuthField(
                  controller: name,
                  label: "Full Name",
                  icon: Icons.person_rounded,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 14),

                AuthField(
                  controller: email,
                  label: "Email",
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 14),

                AuthField(
                  controller: password,
                  label: "Password",
                  icon: Icons.lock_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 14),

                AuthField(
                  controller: phone,
                  label: "Phone",
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 14),

                AuthField(
                  controller: emergency,
                  label: "Emergency Contact",
                  icon: Icons.emergency_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,

                  /// Allow signup submission when pressing Enter
                  onSubmitted: (_) => loading ? null : _signup(),
                ),

                const SizedBox(height: 14),

                // ===============================================================
                // BLOOD GROUP SELECTOR
                // ===============================================================

                AuthBloodDropdown(
                  value: bloodGroup,
                  onChanged: (v) => setState(() => bloodGroup = v),
                ),

                const SizedBox(height: 18),

                // ===============================================================
                // SIGNUP BUTTON
                // ===============================================================

                AuthPrimaryButton(
                  title: "Sign Up",
                  loading: loading,
                  onTap: loading ? null : _signup,
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

// ===============================================================
// AVATAR PICKER WIDGET
// ---------------------------------------------------------------
// Displays the user's profile image and allows them to select
// a new one from the device gallery.
// ===============================================================

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.photo, required this.onTap});

  final File? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primary.withOpacity(0.25),
              AppColor.primary.withOpacity(0.70),
            ],
          ),

          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 12),
              color: AppColor.primary.withOpacity(0.18),
            ),
          ],
        ),

        child: CircleAvatar(
          radius: 46,
          backgroundColor: Colors.white.withOpacity(0.90),
          backgroundImage: photo != null ? FileImage(photo!) : null,

          child: photo == null
              ? Icon(
                  Icons.camera_alt_rounded,
                  color: AppColor.primary.withOpacity(0.90),
                  size: 32,
                )
              : null,
        ),
      ),
    );
  }
}