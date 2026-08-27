// lib/widgets/sos_bottom_sheet.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../services/sos_service.dart';
import '../services/notification_service.dart';
import '../widgets/popup_utils.dart';
import 'text_widget.dart';

class SosBottomSheet extends StatefulWidget {
  const SosBottomSheet({
    super.key,
    required this.userName,
    required this.emergencyContact,
  });

  final String userName;
  final String emergencyContact;

  @override
  State<SosBottomSheet> createState() => _SosBottomSheetState();
}

class _SosBottomSheetState extends State<SosBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _busy = false;

  EmergencyType _type = EmergencyType.medical;

  final TextEditingController _noteC =
      TextEditingController();

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _noteC.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // EXISTING SOS LOGIC
  // ===============================================================

  Future<SosPayload> _payload({
    required bool tryLocation,
  }) {
    return SosService.buildPayload(
      userName: widget.userName,
      type: _type,
      tryLocation: tryLocation,
      customNote: _noteC.text,
    );
  }

  Future<void> _openSimulatorTestMode() async {
    final payload = await _payload(
      tryLocation: false,
    );

    if (!mounted) return;

    PopupUtils.info(
      'Test Mode',
      'Simulator detected. Preview + copy + fetch/manual location.',
    );

    await Get.bottomSheet(
      _SosTestPanel(
        userName: widget.userName,
        emergency: widget.emergencyContact,
        initialPayload: payload,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _sendSmsComposer() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      final physical =
          await SosService.isPhysicalDevice();

      if (!physical) {
        await _openSimulatorTestMode();
        return;
      }

      final payload = await _payload(
        tryLocation: true,
      );

      final controller = TextEditingController(
        text: payload.message,
      );

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColor.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Send SOS SMS',
          ),
          content: TextField(
            controller: controller,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: 'Message (edit if needed)',
              filled: true,
              fillColor: AppColor.inputFill,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColor.borderStrong,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Get.back(result: false),
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColor.primary,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () =>
                  Get.back(result: true),
              child: const Text(
                'Open SMS',
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }

      await SosService.openSmsComposer(
        phone: widget.emergencyContact,
        message: controller.text.trim().isEmpty
            ? payload.message
            : controller.text.trim(),
      );

      await LocalNotificationService.sosPrepared(
        channel: 'SMS',
        emergency: widget.emergencyContact,
      );

      await LocalNotificationService.sosOpened(
        channel: 'SMS Composer',
      );
    } catch (e) {
      await LocalNotificationService.sosFailed(
        e.toString(),
      );

      PopupUtils.warning(
        'SOS',
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _sendWhatsApp() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      final payload = await _payload(
        tryLocation:
            await SosService.isPhysicalDevice(),
      );

      await SosService.openWhatsApp(
        phone: widget.emergencyContact,
        message: payload.message,
      );

      await LocalNotificationService.sosPrepared(
        channel: 'WhatsApp',
        emergency: widget.emergencyContact,
      );

      await LocalNotificationService.sosOpened(
        channel: 'WhatsApp',
      );
    } catch (e) {
      await LocalNotificationService.sosFailed(
        e.toString(),
      );

      PopupUtils.warning(
        'WhatsApp',
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _sendDirectSmsAndroid() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      final physical =
          await SosService.isPhysicalDevice();

      if (!physical) {
        await _openSimulatorTestMode();
        return;
      }

      if (!Platform.isAndroid) {
        PopupUtils.warning(
          'Direct SMS',
          'Android-only. Use SMS Composer on iOS.',
        );
        return;
      }

      final payload = await _payload(
        tryLocation: true,
      );

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColor.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Send Direct SMS (Android)',
          ),
          content: const Text(
            'This will send SMS directly without opening Messages.\n\nProceed?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Get.back(result: false),
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColor.primary,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () =>
                  Get.back(result: true),
              child: const Text(
                'Send',
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }

      try {
        await SosService.sendDirectSmsAndroid(
          phone: widget.emergencyContact,
          message: payload.message,
        );

        await LocalNotificationService
            .sosSentAndroidDirect();
      } catch (e) {
        await LocalNotificationService.sosFailed(
          'Direct SMS failed/denied. Opening composer...',
        );

        await SosService.openSmsComposer(
          phone: widget.emergencyContact,
          message: payload.message,
        );

        await LocalNotificationService.sosOpened(
          channel: 'SMS Composer',
        );
      }
    } catch (e) {
      await LocalNotificationService.sosFailed(
        e.toString(),
      );

      PopupUtils.warning(
        'Direct SMS',
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _call() async {
    try {
      await SosService.callEmergency(
        widget.emergencyContact,
      );

      await LocalNotificationService.sosPrepared(
        channel: 'Call',
        emergency: widget.emergencyContact,
      );

      await LocalNotificationService.sosOpened(
        channel: 'Dialer',
      );
    } catch (e) {
      await LocalNotificationService.sosFailed(
        e.toString(),
      );

      PopupUtils.warning(
        'Call',
        e.toString(),
      );
    }
  }

  // ===============================================================
  // UI
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final keyboard =
        MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: keyboard,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------
                // HANDLE
                // -------------------------------------------------

                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.borderStrong,
                      borderRadius:
                          BorderRadius.circular(99),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // -------------------------------------------------
                // HEADER
                // -------------------------------------------------

                _header(),

                const SizedBox(height: 22),

                // -------------------------------------------------
                // TYPE
                // -------------------------------------------------

                const TextWidget(
                  'What happened?',
                  size: 14,
                  weight: FontWeight.w900,
                  color: AppColor.text,
                ),

                const SizedBox(height: 4),

                const TextWidget(
                  'Choose the closest emergency type',
                  size: 11,
                  color: AppColor.textMuted,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _typeCard(
                        EmergencyType.medical,
                        Icons.medical_services_outlined,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _typeCard(
                        EmergencyType.fire,
                        Icons.local_fire_department_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _typeCard(
                        EmergencyType.flood,
                        Icons.water_outlined,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _typeCard(
                        EmergencyType.other,
                        Icons.emergency_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // -------------------------------------------------
                // NOTE
                // -------------------------------------------------

                _noteField(),

                const SizedBox(height: 20),

                // -------------------------------------------------
                // PRIMARY ACTION
                // -------------------------------------------------

                _mainSmsAction(),

                const SizedBox(height: 12),

                // -------------------------------------------------
                // SECONDARY ACTIONS
                // -------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: _compactAction(
                        icon:
                            FontAwesomeIcons.whatsapp,
                        title: 'WhatsApp',
                        color:
                            const Color(0xFF1FAF64),
                        onTap: _sendWhatsApp,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _compactAction(
                        icon: Icons.send_outlined,
                        title: 'Direct SMS',
                        color:
                            AppColor.secondary,
                        onTap:
                            _sendDirectSmsAndroid,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // -------------------------------------------------
                // CALL
                // -------------------------------------------------

                _callAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _header() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final scale =
                1 + (_pulseCtrl.value * 0.04);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      AppColor.primary,
                  borderRadius:
                      BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary
                          .withOpacity(0.22),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const TextWidget(
                'Emergency SOS',
                size: 19,
                weight: FontWeight.w900,
                color: AppColor.text,
              ),

              const SizedBox(height: 5),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColor.inputFill,
                  borderRadius:
                      BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color:
                          AppColor.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: TextWidget(
                        widget.emergencyContact,
                        size: 10.5,
                        weight:
                            FontWeight.w800,
                        color:
                            AppColor.textMuted,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius:
                BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColor.inputFill,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: AppColor.border,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColor.text,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // EMERGENCY TYPE
  // ===============================================================

  Widget _typeCard(
    EmergencyType type,
    IconData icon,
  ) {
    final selected =
        _type == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _type = type;
          });
        },
        borderRadius:
            BorderRadius.circular(17),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.secondary
                : AppColor.surface,
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? AppColor.secondary
                  : AppColor.border,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColor.secondary
                          .withOpacity(0.13),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                          .withOpacity(0.10)
                      : AppColor.inputFill,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected
                      ? Colors.white
                      : AppColor.primary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextWidget(
                  type.label,
                  size: 12,
                  weight: FontWeight.w800,
                  color: selected
                      ? Colors.white
                      : AppColor.text,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColor.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColor.primary
                        : AppColor.borderStrong,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // NOTE
  // ===============================================================

  Widget _noteField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const TextWidget(
          'Add a note',
          size: 14,
          weight: FontWeight.w900,
          color: AppColor.text,
        ),

        const SizedBox(height: 4),

        const TextWidget(
          'Optional — include anything the contact should know',
          size: 11,
          color: AppColor.textMuted,
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _noteC,
          maxLines: 2,
          minLines: 2,
          cursorColor: AppColor.primary,
          style: const TextStyle(
            color: AppColor.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText:
                'Example: I am injured and need help...',
            hintStyle: TextStyle(
              color: AppColor.textMuted
                  .withOpacity(0.72),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppColor.inputFill,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(
                left: 14,
                right: 10,
                bottom: 30,
              ),
              child: Icon(
                Icons.notes_rounded,
                color: AppColor.textMuted,
                size: 19,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColor.border,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColor.border,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColor.primary
                    .withOpacity(0.45),
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // MAIN SMS ACTION
  // ===============================================================

  Widget _mainSmsAction() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            _busy ? null : _sendSmsComposer,
        borderRadius:
            BorderRadius.circular(20),
        child: AnimatedOpacity(
          duration:
              const Duration(milliseconds: 180),
          opacity: _busy ? 0.65 : 1,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius:
                  BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary
                      .withOpacity(0.22),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.14),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    color: Colors.white,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        'Send SOS message',
                        size: 15,
                        weight:
                            FontWeight.w900,
                        color: Colors.white,
                      ),
                      SizedBox(height: 3),
                      TextWidget(
                        'Opens SMS with your emergency details',
                        size: 10.5,
                        color:
                            Color(0xD9FFFFFF),
                      ),
                    ],
                  ),
                ),

                if (_busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.13),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // COMPACT SECONDARY ACTION
  // ===============================================================

  Widget _compactAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _busy ? null : onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: AnimatedOpacity(
          duration:
              const Duration(milliseconds: 180),
          opacity: _busy ? 0.55 : 1,
          child: Container(
            height: 104,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: AppColor.border,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color
                            .withOpacity(0.09),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Center(
                        child: icon ==
                                FontAwesomeIcons
                                    .whatsapp
                            ? FaIcon(
                                icon,
                                size: 19,
                                color: color,
                              )
                            : Icon(
                                icon,
                                size: 20,
                                color: color,
                              ),
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons
                          .north_east_rounded,
                      size: 17,
                      color:
                          AppColor.textMuted,
                    ),
                  ],
                ),

                const Spacer(),

                TextWidget(
                  title,
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColor.text,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CALL ACTION
  // ===============================================================

  Widget _callAction() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _busy ? null : _call,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color:
                AppColor.danger.withOpacity(0.07),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: AppColor.danger
                  .withOpacity(0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColor.danger
                      .withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: AppColor.danger,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      'Call emergency contact',
                      size: 13.5,
                      weight:
                          FontWeight.w900,
                      color: AppColor.text,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      widget.emergencyContact,
                      size: 11,
                      weight:
                          FontWeight.w700,
                      color: AppColor.danger,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.call_made_rounded,
                color: AppColor.danger,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// SIMULATOR TEST PANEL
// =================================================================

class _SosTestPanel extends StatefulWidget {
  const _SosTestPanel({
    required this.userName,
    required this.emergency,
    required this.initialPayload,
  });

  final String userName;
  final String emergency;
  final SosPayload initialPayload;

  @override
  State<_SosTestPanel> createState() =>
      _SosTestPanelState();
}

class _SosTestPanelState
    extends State<_SosTestPanel> {
  late SosPayload _payload;

  bool _fetching = false;

  String? _status;

  final _latC =
      TextEditingController();

  final _lngC =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _payload =
        widget.initialPayload;
  }

  @override
  void dispose() {
    _latC.dispose();
    _lngC.dispose();
    super.dispose();
  }

  // ===============================================================
  // ORIGINAL TEST LOGIC PRESERVED
  // ===============================================================

  String _messageWithLink(
    String link,
  ) {
    final msg = _payload.message;

    final lines =
        msg.split('\n');

    final idx = lines.indexWhere(
      (l) =>
          l.trim().startsWith(
            'My location:',
          ),
    );

    if (idx >= 0) {
      lines[idx] =
          'My location: $link';

      return lines
          .join('\n')
          .trim();
    }

    return '$msg\n\nMy location: $link'
        .trim();
  }

  bool _validLatLng(
    double lat,
    double lng,
  ) {
    return lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }

  Future<void> _fetchLocation() async {
    if (_fetching) return;

    setState(() {
      _fetching = true;
      _status = null;
    });

    try {
      final link =
          await SosService.fetchMapsLink();

      if (link == null) {
        setState(() {
          _status =
              'Timed out. Use Manual Lat/Lng below (demo-safe).';
        });

        PopupUtils.warning(
          'Location',
          _status!,
        );

        return;
      }

      setState(() {
        _payload =
            _payload.copyWith(
          mapsLink: link,
          message:
              _messageWithLink(link),
        );

        _status =
            'Location attached ✅';
      });

      PopupUtils.success(
        'Location',
        'Location attached ✅',
      );
    } catch (e) {
      setState(() {
        _status =
            'Error: $e';
      });

      PopupUtils.warning(
        'Location',
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _fetching = false;
        });
      }
    }
  }

  void _attachManualLocation() {
    final lat =
        double.tryParse(
      _latC.text.trim(),
    );

    final lng =
        double.tryParse(
      _lngC.text.trim(),
    );

    if (lat == null ||
        lng == null) {
      PopupUtils.warning(
        'Manual Location',
        'Enter valid numbers for lat/lng.',
      );
      return;
    }

    if (!_validLatLng(
      lat,
      lng,
    )) {
      PopupUtils.warning(
        'Manual Location',
        'Lat/Lng out of range.',
      );
      return;
    }

    final link =
        SosService.mapsLink(
      lat,
      lng,
    );

    setState(() {
      _payload =
          _payload.copyWith(
        mapsLink: link,
        message:
            _messageWithLink(link),
      );

      _status =
          'Manual location attached ✅';
    });

    PopupUtils.success(
      'Manual Location',
      'Attached ✅',
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        _payload.mapsLink != null;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(
          top: 70,
        ),
        decoration: const BoxDecoration(
          color: AppColor.surface,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        AppColor.borderStrong,
                    borderRadius:
                        BorderRadius.circular(
                      99,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------
              // HEADER
              // ---------------------------------------------------

              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColor.secondary,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .science_outlined,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const TextWidget(
                          'Simulator Test Mode',
                          size: 17,
                          weight:
                              FontWeight.w900,
                          color:
                              AppColor.text,
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        TextWidget(
                          'Emergency: ${widget.emergency}',
                          size: 10.5,
                          color: AppColor
                              .textMuted,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () =>
                        Get.back(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color:
                          AppColor.text,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------
              // MESSAGE PREVIEW
              // ---------------------------------------------------

              const TextWidget(
                'SOS Preview',
                size: 13,
                weight: FontWeight.w900,
                color: AppColor.text,
              ),

              const SizedBox(height: 9),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  15,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColor.inputFill,
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                  border: Border.all(
                    color:
                        AppColor.border,
                  ),
                ),
                child: Text(
                  _payload.message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color:
                        AppColor.text,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---------------------------------------------------
              // MESSAGE ACTIONS
              // ---------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child:
                        _testButton(
                      icon:
                          Icons.copy_rounded,
                      title:
                          'Copy Message',
                      filled: true,
                      onTap:
                          () async {
                        await Clipboard
                            .setData(
                          ClipboardData(
                            text: _payload
                                .message,
                          ),
                        );

                        PopupUtils
                            .success(
                          'Copied',
                          'SOS message copied',
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        _testButton(
                      icon: Icons
                          .map_outlined,
                      title: 'Open Maps',
                      filled: false,
                      onTap:
                          hasLocation
                              ? () async {
                                  try {
                                    await SosService
                                        .openMapsLink(
                                      _payload
                                          .mapsLink!,
                                    );
                                  } catch (e) {
                                    PopupUtils
                                        .warning(
                                      'Maps',
                                      e.toString(),
                                    );
                                  }
                                }
                              : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---------------------------------------------------
              // AUTO LOCATION
              // ---------------------------------------------------

              Material(
                color:
                    Colors.transparent,
                child: InkWell(
                  onTap: _fetching
                      ? null
                      : _fetchLocation,
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                  child: Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColor.surface,
                      borderRadius:
                          BorderRadius.circular(
                        17,
                      ),
                      border:
                          Border.all(
                        color:
                            AppColor.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration:
                              BoxDecoration(
                            color: AppColor
                                .primary
                                .withOpacity(
                              0.09,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              13,
                            ),
                          ),
                          child: _fetching
                              ? const Padding(
                                  padding:
                                      EdgeInsets.all(
                                    11,
                                  ),
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        AppColor.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .my_location_rounded,
                                  color:
                                      AppColor.primary,
                                  size: 20,
                                ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              TextWidget(
                                _fetching
                                    ? 'Fetching location'
                                    : 'Use current location',
                                size: 12.5,
                                weight:
                                    FontWeight.w800,
                                color:
                                    AppColor.text,
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              const TextWidget(
                                'Attach location automatically',
                                size: 10,
                                color: AppColor
                                    .textMuted,
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons
                              .chevron_right_rounded,
                          color: AppColor
                              .textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------
              // MANUAL LOCATION
              // ---------------------------------------------------

              const TextWidget(
                'Manual Location',
                size: 13,
                weight:
                    FontWeight.w900,
                color: AppColor.text,
              ),

              const SizedBox(height: 4),

              const TextWidget(
                'Useful when simulator location is unavailable',
                size: 10.5,
                color:
                    AppColor.textMuted,
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child:
                        _coordinateField(
                      controller:
                          _latC,
                      label:
                          'Latitude',
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        _coordinateField(
                      controller:
                          _lngC,
                      label:
                          'Longitude',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _attachManualLocation,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColor.primary,
                    side:
                        const BorderSide(
                      color:
                          AppColor.borderStrong,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons
                        .add_location_alt_outlined,
                    size: 19,
                  ),
                  label:
                      const TextWidget(
                    'Attach Coordinates',
                    size: 12,
                    weight:
                        FontWeight.w800,
                    color:
                        AppColor.primary,
                  ),
                ),
              ),

              const SizedBox(height: 9),

              const TextWidget(
                'Example: 31.418000, 73.079100',
                size: 10,
                color:
                    AppColor.textMuted,
              ),

              const SizedBox(height: 16),

              // ---------------------------------------------------
              // LOCATION STATUS
              // ---------------------------------------------------

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration:
                    BoxDecoration(
                  color: hasLocation
                      ? AppColor.safeGreen
                          .withOpacity(0.07)
                      : AppColor.danger
                          .withOpacity(0.06),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasLocation
                          ? Icons
                              .check_circle_outline_rounded
                          : Icons
                              .location_off_outlined,
                      size: 18,
                      color: hasLocation
                          ? AppColor.safeGreen
                          : AppColor.danger,
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Expanded(
                      child: TextWidget(
                        _status ??
                            (hasLocation
                                ? 'Location attached'
                                : 'Location not attached yet'),
                        size: 10.5,
                        weight:
                            FontWeight.w700,
                        color: hasLocation
                            ? AppColor
                                .safeGreen
                            : AppColor
                                .danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coordinateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
        signed: true,
      ),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor:
            AppColor.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColor.border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColor.border,
          ),
        ),
      ),
    );
  }

  Widget _testButton({
    required IconData icon,
    required String title,
    required bool filled,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 48,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              style:
                  ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    AppColor.primary,
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              icon: Icon(
                icon,
                size: 18,
              ),
              label: Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    AppColor.text,
                side:
                    const BorderSide(
                  color:
                      AppColor.border,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              icon: Icon(
                icon,
                size: 18,
              ),
              label: Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
    );
  }
}