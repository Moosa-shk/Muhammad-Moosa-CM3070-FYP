// lib/screens/auth/signup_screen.dart

import 'dart:io';

import 'package:disaster_app_ui/screens/auth/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';
import 'animated_auth_scaffold.dart';
import '../dashboard/home_screen.dart';
import 'auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final emergency = TextEditingController();

  String bloodGroup = "A+";

  File? photo;

  bool loading = false;

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
  // IMAGE PICKER - PRESERVED
  // ===============================================================

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (img != null) {
      setState(() {
        photo = File(img.path);
      });
    }
  }

  // ===============================================================
  // VALIDATION - PRESERVED
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
  // SIGNUP - PRESERVED
  // ===============================================================

  Future<void> _signup() async {
    if (!_validate()) return;

    setState(() {
      loading = true;
    });

    final err = await AuthController.to.registerFull(
      email: email.text.trim(),
      password: password.text.trim(),
      name: name.text.trim(),
      phone: phone.text.trim(),
      emergency: emergency.text.trim(),
      bloodGroup: bloodGroup,
      profileFile: photo,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (err != null) {
      Get.snackbar(
        "Signup Failed",
        err,
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
      return;
    }

    Get.offAll(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedAuthScaffold(
      showBack: true,
      title: null,
      subtitle: null,
      scroll: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // =====================================================
          // PAGE TITLE
          // =====================================================

          const TextWidget(
            "Create account",
            size: 28,
            weight: FontWeight.w900,
            color: AppColor.text,
          ),

          const SizedBox(height: 6),

          const TextWidget(
            "Add your details to get started.",
            size: 13.5,
            weight: FontWeight.w500,
            color: AppColor.textMuted,
          ),

          const SizedBox(height: 26),

          // =====================================================
          // PROFILE PHOTO
          // =====================================================

          _ProfilePhotoRow(
            photo: photo,
            onTap: pickImage,
          ),

          const SizedBox(height: 30),

          // =====================================================
          // ACCOUNT SECTION
          // =====================================================

          const _SectionLabel(
            title: "Account",
          ),

          const SizedBox(height: 12),

          AuthField(
            controller: name,
            label: "Full name",
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          AuthField(
            controller: email,
            label: "Email address",
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          AuthField(
            controller: password,
            label: "Password",
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 28),

          // =====================================================
          // CONTACT & SAFETY SECTION
          // =====================================================

          const _SectionLabel(
            title: "Contact & safety",
          ),

          const SizedBox(height: 12),

          AuthField(
            controller: phone,
            label: "Phone number",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          AuthField(
            controller: emergency,
            label: "Emergency contact",
            icon: Icons.contact_phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!loading) {
                _signup();
              }
            },
          ),

          const SizedBox(height: 14),

          _bloodGroupField(),

          const SizedBox(height: 30),

          // =====================================================
          // CTA
          // =====================================================

          AuthPrimaryButton(
            title: "Create account",
            loading: loading,
            onTap: loading ? null : _signup,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ===============================================================
  // BLOOD GROUP
  // ===============================================================

  Widget _bloodGroupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          "Blood group",
          size: 12,
          weight: FontWeight.w800,
          color: AppColor.text,
        ),

        const SizedBox(height: 8),

        AuthBloodDropdown(
          value: bloodGroup,
          onChanged: (value) {
            setState(() {
              bloodGroup = value;
            });
          },
        ),
      ],
    );
  }
}

// =================================================================
// SECTION LABEL
// =================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextWidget(
          title,
          size: 14.5,
          weight: FontWeight.w900,
          color: AppColor.text,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Container(
            height: 1,
            color: AppColor.border,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// PROFILE PHOTO
// =================================================================

class _ProfilePhotoRow extends StatelessWidget {
  const _ProfilePhotoRow({
    required this.photo,
    required this.onTap,
  });

  final File? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ---------------------------------------------------------
        // PHOTO
        // ---------------------------------------------------------

        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.border,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: photo != null
                      ? Image.file(
                          photo!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColor.inputFill,
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 30,
                            color: AppColor.textMuted,
                          ),
                        ),
                ),
              ),

              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.bg,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // ---------------------------------------------------------
        // TEXT
        // ---------------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                "Profile photo",
                size: 14,
                weight: FontWeight.w800,
                color: AppColor.text,
              ),

              const SizedBox(height: 4),

              TextWidget(
                photo == null
                    ? "Optional"
                    : "Photo selected",
                size: 12,
                color: AppColor.textMuted,
              ),

              const SizedBox(height: 7),

              GestureDetector(
                onTap: onTap,
                child: const TextWidget(
                  "Choose photo",
                  size: 12,
                  weight: FontWeight.w900,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}