// lib/screens/auth/info_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/colors.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/text_widget.dart';
import '../dashboard/home_screen.dart';
import 'auth_controller.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  bool _saving = false;
  File? _pickedImage;

  final name = TextEditingController();
  final phone = TextEditingController();
  final emergency = TextEditingController();

  String bloodGroup = "A+";

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

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    emergency.dispose();
    super.dispose();
  }

  // ===============================================================
  // IMAGE PICKER - PRESERVED
  // ===============================================================

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (img != null) {
      setState(() {
        _pickedImage = File(img.path);
      });
    }
  }

  // ===============================================================
  // SAVE PROFILE - PRESERVED
  // ===============================================================

  Future<void> _saveProfile() async {
    final user = AuthController.to.currentUser.value;

    if (name.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Name is required",
        backgroundColor: AppColor.danger,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    String? imgUrl = user?.profileImage;

    if (_pickedImage != null) {
      try {
        imgUrl = await CloudinaryService.uploadImageUnsigned(
          _pickedImage!,
        );
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _saving = false;
        });

        Get.snackbar(
          "Upload Failed",
          "$e",
          backgroundColor: AppColor.danger,
          colorText: Colors.white,
        );

        return;
      }
    }

    final err = await AuthController.to.updateProfileSafe(
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

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    if (err != null) {
      Get.snackbar(
        "Save Failed",
        err,
        backgroundColor: AppColor.danger,
        colorText: Colors.white,
      );
      return;
    }

    Get.offAll(
      () => const HomeScreen(),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final user = AuthController.to.currentUser.value;

    ImageProvider? provider;

    if (_pickedImage != null) {
      provider = FileImage(_pickedImage!);
    } else if ((user?.profileImage ?? "").isNotEmpty) {
      provider = NetworkImage(
        user!.profileImage!,
      );
    }

    return Scaffold(
      backgroundColor: AppColor.bg,
      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // TOP BAR
            // =====================================================

            _topBar(),

            // =====================================================
            // CONTENT
            // =====================================================

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // PROFILE PHOTO AREA
                    // =================================================

                    _profileHeader(
                      provider: provider,
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // PERSONAL DETAILS
                    // =================================================

                    const _SectionTitle(
                      title: "Personal details",
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller: name,
                      label: "Full name",
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 14),

                    _field(
                      controller: phone,
                      label: "Phone number",
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // EMERGENCY DETAILS
                    // =================================================

                    const _SectionTitle(
                      title: "Emergency details",
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller: emergency,
                      label: "Emergency contact",
                      icon: Icons.contact_phone_outlined,
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 14),

                    _bloodDropdown(),

                    const SizedBox(height: 30),

                    // =================================================
                    // SAVE
                    // =================================================

                    CustomButton(
                      title: _saving
                          ? "Saving..."
                          : "Save changes",
                      onTap: _saving
                          ? null
                          : _saveProfile,
                      loading: _saving,
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // TOP BAR
  // ===============================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        8,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: TextWidget(
              "Profile",
              size: 18,
              weight: FontWeight.w900,
              color: AppColor.text,
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColor.border,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 21,
                    color: AppColor.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PROFILE HEADER
  // ===============================================================

  Widget _profileHeader({
    required ImageProvider? provider,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColor.inputFill,
                  backgroundImage: provider,
                  child: provider == null
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 34,
                          color: AppColor.textMuted,
                        )
                      : null,
                ),
              ),

              Positioned(
                right: -1,
                bottom: 1,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.bg,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                "Profile photo",
                size: 16,
                weight: FontWeight.w900,
                color: AppColor.text,
              ),

              const SizedBox(height: 5),

              const TextWidget(
                "Tap the photo to update it",
                size: 12,
                color: AppColor.textMuted,
              ),

              const SizedBox(height: 9),

              GestureDetector(
                onTap: _pickImage,
                child: const TextWidget(
                  "Change photo",
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

  // ===============================================================
  // FIELD
  // ===============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.borderStrong,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        cursorColor: AppColor.primary,
        style: const TextStyle(
          color: AppColor.text,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColor.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(11),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColor.inputFill,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColor.primary,
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // BLOOD GROUP
  // ===============================================================

  Widget _bloodDropdown() {
    const groups = [
      "A+",
      "A-",
      "B+",
      "B-",
      "O+",
      "O-",
      "AB+",
      "AB-",
    ];

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.borderStrong,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.dangerSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.bloodtype_outlined,
              size: 18,
              color: AppColor.danger,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: bloodGroup,
                isExpanded: true,
                dropdownColor: AppColor.surface,
                borderRadius: BorderRadius.circular(14),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColor.textMuted,
                ),
                style: const TextStyle(
                  color: AppColor.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                items: groups
                    .map(
                      (group) => DropdownMenuItem<String>(
                        value: group,
                        child: Text(
                          group,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      bloodGroup = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SECTION TITLE
// =================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextWidget(
          title,
          size: 14,
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