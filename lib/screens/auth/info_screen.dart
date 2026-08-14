// ===============================================================
// InfoScreen
// ---------------------------------------------------------------
// This screen allows the user to complete or update their
// personal profile information after authentication.
//
// The screen collects important user details such as:
// • Full name
// • Phone number
// • Emergency contact
// • Blood group
// • Profile picture
//
// The data is stored in Firebase Firestore and the profile
// image is uploaded to Cloudinary.
//
// This information can be important during emergencies
// in disaster scenarios, allowing responders or contacts
// to access critical personal details quickly.
// ===============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/text_widget.dart';
import '../../services/cloudinary_service.dart';
import '../dashboard/home_screen.dart';
import 'auth_controller.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  /// Indicates whether the profile is currently being saved
  bool _saving = false;

  /// Stores the locally selected image before uploading
  File? _pickedImage;

  /// Controllers for user input fields
  final name = TextEditingController();
  final phone = TextEditingController();
  final emergency = TextEditingController();

  /// Default blood group
  String bloodGroup = "A+";

  // ===============================================================
  // initState()
  // ---------------------------------------------------------------
  // When the screen loads, existing user data is retrieved from
  // AuthController and used to pre-fill the form fields.
  // ===============================================================

  @override
  void initState() {
    super.initState();

    final user = AuthController.to.currentUser.value;

    if (user != null) {
      name.text = user.name;
      phone.text = user.phone ?? "";
      emergency.text = user.emergencyContact ?? "";
      bloodGroup = user.bloodGroup ?? "A+";
    }
  }

  // ===============================================================
  // _pickImage()
  // ---------------------------------------------------------------
  // Opens the device gallery and allows the user to select
  // a profile picture. The image is stored locally until it
  // is uploaded during the save process.
  // ===============================================================

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() => _pickedImage = File(img.path));
    }
  }

  // ===============================================================
  // UI BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final user = AuthController.to.currentUser.value;

    /// Determines which image should be displayed
    ImageProvider? provider;

    if (_pickedImage != null) {
      provider = FileImage(_pickedImage!);
    } else if ((user?.profileImage ?? "").isNotEmpty) {
      provider = NetworkImage(user!.profileImage!);
    }

    return Scaffold(
      backgroundColor: AppColor.bg,

      // ===============================================================
      // APP BAR
      // ===============================================================

      appBar: AppBar(
        backgroundColor: AppColor.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.secondary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const TextWidget(
          "Profile Information",
          weight: FontWeight.w900,
          size: 18,
          color: AppColor.secondary,
        ),
      ),

      // ===============================================================
      // BODY
      // ===============================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ===============================================================
            // PROFILE AVATAR
            // ---------------------------------------------------------------
            // Allows the user to tap and select a profile image.
            // ===============================================================

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.primary.withOpacity(0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: provider,
                  backgroundColor: Colors.white,
                  child: provider == null
                      ? Icon(
                          Icons.camera_alt_rounded,
                          size: 30,
                          color: AppColor.textMuted.withOpacity(0.9),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===============================================================
            // INPUT FIELDS
            // ===============================================================

            _field(name, "Full Name"),
            const SizedBox(height: 14),

            _field(phone, "Phone", keyboard: TextInputType.phone),
            const SizedBox(height: 14),

            _field(
              emergency,
              "Emergency Contact",
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _dropdown(),
            const SizedBox(height: 26),

            // ===============================================================
            // SAVE BUTTON
            // ===============================================================

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: _saving ? "Saving..." : "Save",
                onTap: _saving
                    ? null
                    : () async {
                        // Validate name field
                        if (name.text.trim().isEmpty) {
                          Get.snackbar(
                            "Missing Info",
                            "Name is required",
                            backgroundColor: AppColor.danger,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        setState(() => _saving = true);

                        String? imgUrl = user?.profileImage;

                        // Upload image if user selected a new one
                        if (_pickedImage != null) {
                          try {
                            imgUrl =
                                await CloudinaryService.uploadImageUnsigned(
                                    _pickedImage!);
                          } catch (e) {
                            setState(() => _saving = false);

                            Get.snackbar(
                              "Upload Failed",
                              "$e",
                              backgroundColor: AppColor.danger,
                              colorText: Colors.white,
                            );
                            return;
                          }
                        }

                        // Update profile in Firestore
                        final err =
                            await AuthController.to.updateProfileSafe(
                          name: name.text.trim(),
                          phone: phone.text.trim().isEmpty
                              ? null
                              : phone.text.trim(),
                          emergencyContact: emergency.text.trim().isEmpty
                              ? null
                              : emergency.text.trim(),
                          bloodGroup: bloodGroup,
                          profileImage: imgUrl,
                        );

                        setState(() => _saving = false);

                        if (err != null) {
                          Get.snackbar(
                            "Save Failed",
                            err,
                            backgroundColor: AppColor.danger,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Navigate to home screen after success
                        Get.offAll(() => const HomeScreen());
                      },
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // BLOOD GROUP DROPDOWN
  // ===============================================================

  Widget _dropdown() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: bloodGroup,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColor.textMuted,
        ),
        items: const ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: TextWidget(
                    e,
                    weight: FontWeight.w700,
                    color: AppColor.secondary,
                  ),
                ))
            .toList(),
        onChanged: (val) => setState(() => bloodGroup = val!),
      ),
    );
  }

  // ===============================================================
  // TEXT FIELD UI COMPONENT
  // ===============================================================

  Widget _field(
    TextEditingController c,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    bool highlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? AppColor.primary.withOpacity(0.55)
              : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        style: const TextStyle(
          color: AppColor.text,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: AppColor.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColor.textMuted.withOpacity(0.8),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      ),
    );
  }
}