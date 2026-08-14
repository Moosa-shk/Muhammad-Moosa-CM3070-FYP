// lib/screens/sos/sos_screen.dart

import 'dart:ui';

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/text_widget.dart';

/// SOS screen used to send an emergency request.
/// This feature allows users to quickly notify responders
/// and share their location during a disaster or emergency situation.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {

  /// Animation controller used to create the pulsing SOS indicator
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    /// Initialize pulse animation for the SOS visual indicator
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {

    /// Dispose animation controller when screen is closed
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Send SOS Request",
      subtitle: "Share location with responders",
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      /// Bottom navigation used across the DisasterAid application
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      child: Column(
        children: [
          const SizedBox(height: 14),

          /// Main information card explaining the SOS feature
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColor.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [

                /// Animated SOS indicator
                SizedBox(
                  height: 220,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) {

                        /// Animation values used for scaling and pulse effect
                        final t = _pulseCtrl.value;
                        final s = 0.92 + (t * 0.08);
                        final ringOpacity = 0.08 + (t * 0.10);

                        return Stack(
                          alignment: Alignment.center,
                          children: [

                            /// Outer pulse ring
                            Transform.scale(
                              scale: 1.35 + (t * 0.12),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.primary.withOpacity(ringOpacity),
                                ),
                              ),
                            ),

                            /// Middle pulse ring
                            Transform.scale(
                              scale: 1.05 + (t * 0.06),
                              child: Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.primary.withOpacity(0.16),
                                  border: Border.all(
                                    color: AppColor.primary.withOpacity(0.22),
                                  ),
                                ),
                              ),
                            ),

                            /// Central SOS icon
                            Transform.scale(
                              scale: s,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColor.primary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.primary.withOpacity(0.35),
                                          blurRadius: 24,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 46,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// Short explanation of the SOS feature
                const TextWidget(
                  "In case of emergency, press below to send an SOS request with your location.",
                  size: 14,
                  color: AppColor.textMuted,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),

          /// Main button used to trigger the SOS request
          CustomButton(
            title: "SEND SOS NOW",
            onTap: () async => _showConfirmation(context),
          ),

          const SizedBox(height: 12),

          /// Cancel button to return to the main screen
          CustomButton(
            title: "Cancel",
            onTap: () async => Get.offAll(() => const BottomNavBar(currentIndex: 0)),
            filled: false,
          ),

          const SizedBox(height: 22),
        ],
      ),
    );
  }

  /// Displays confirmation dialog after the SOS request is triggered
  Future<void> _showConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColor.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// Success icon displayed after sending SOS
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColor.safeGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColor.safeGreen.withOpacity(0.20)),
                ),
                child: const Icon(Icons.verified_rounded,
                    color: AppColor.safeGreen, size: 34),
              ),

              const SizedBox(height: 12),

              const TextWidget(
                "SOS Request Sent!",
                size: 18,
                weight: FontWeight.w900,
                color: AppColor.text,
                align: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const TextWidget(
                "Your location and details have been shared with nearby responders.",
                size: 14,
                color: AppColor.textMuted,
                align: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// Button to return to the main application screen
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    elevation: 10,
                    shadowColor: AppColor.primary.withOpacity(0.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Get.offAll(() => const BottomNavBar(currentIndex: 0)),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}