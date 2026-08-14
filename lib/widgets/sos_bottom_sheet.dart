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
  final TextEditingController _noteC = TextEditingController();
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

  Future<SosPayload> _payload({required bool tryLocation}) {
    return SosService.buildPayload(
      userName: widget.userName,
      type: _type,
      tryLocation: tryLocation,
      customNote: _noteC.text,
    );
  }

  Future<void> _openSimulatorTestMode() async {
    final payload = await _payload(tryLocation: false);

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
    setState(() => _busy = true);

    try {
      final physical = await SosService.isPhysicalDevice();
      if (!physical) {
        await _openSimulatorTestMode();
        return;
      }

      final payload = await _payload(tryLocation: true);

      final controller = TextEditingController(text: payload.message);
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColor.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Send SOS SMS'),
          content: TextField(
            controller: controller,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: 'Message (edit if needed)',
              filled: true,
              fillColor: AppColor.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColor.borderStrong),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Get.back(result: true),
              child: const Text('Open SMS'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

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
      await LocalNotificationService.sosOpened(channel: 'SMS Composer');
    } catch (e) {
      await LocalNotificationService.sosFailed(e.toString());
      PopupUtils.warning('SOS', e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendWhatsApp() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final payload = await _payload(
        tryLocation: await SosService.isPhysicalDevice(),
      );

      await SosService.openWhatsApp(
        phone: widget.emergencyContact,
        message: payload.message,
      );

      await LocalNotificationService.sosPrepared(
        channel: 'WhatsApp',
        emergency: widget.emergencyContact,
      );
      await LocalNotificationService.sosOpened(channel: 'WhatsApp');
    } catch (e) {
      await LocalNotificationService.sosFailed(e.toString());
      PopupUtils.warning('WhatsApp', e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendDirectSmsAndroid() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final physical = await SosService.isPhysicalDevice();
      if (!physical) {
        await _openSimulatorTestMode();
        return;
      }

      if (!Platform.isAndroid) {
        PopupUtils.warning(
            'Direct SMS', 'Android-only. Use SMS Composer on iOS.');
        return;
      }

      final payload = await _payload(tryLocation: true);

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColor.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Send Direct SMS (Android)'),
          content: const Text(
            'This will send SMS directly without opening Messages.\n\nProceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Get.back(result: true),
              child: const Text('Send'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        await SosService.sendDirectSmsAndroid(
          phone: widget.emergencyContact,
          message: payload.message,
        );

        await LocalNotificationService.sosSentAndroidDirect();
      } catch (e) {
        await LocalNotificationService.sosFailed(
          'Direct SMS failed/denied. Opening composer...',
        );
        await SosService.openSmsComposer(
          phone: widget.emergencyContact,
          message: payload.message,
        );
        await LocalNotificationService.sosOpened(channel: 'SMS Composer');
      }
    } catch (e) {
      await LocalNotificationService.sosFailed(e.toString());
      PopupUtils.warning('Direct SMS', e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _call() async {
    try {
      await SosService.callEmergency(widget.emergencyContact);

      await LocalNotificationService.sosPrepared(
        channel: 'Call',
        emergency: widget.emergencyContact,
      );
      await LocalNotificationService.sosOpened(channel: 'Dialer');
    } catch (e) {
      await LocalNotificationService.sosFailed(e.toString());
      PopupUtils.warning('Call', e.toString());
    }
  }

  // ================= UI HELPERS =================

  Widget _chip(EmergencyType t) {
    final selected = _type == t;

    return GestureDetector(
      onTap: () => setState(() => _type = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : AppColor.cardFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : AppColor.borderStrong,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 10),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColor.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  )
                ],
        ),
        child: TextWidget(
          t.label,
          size: 13,
          weight: FontWeight.w800,
          color: selected ? Colors.white : AppColor.secondary,
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return GestureDetector(
      onTap: _busy ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _busy ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primary ? AppColor.primary : AppColor.cardFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primary ? Colors.transparent : AppColor.border,
            ),
            boxShadow: [
              BoxShadow(
                color: primary
                    ? AppColor.primary.withOpacity(0.22)
                    : AppColor.shadow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withOpacity(0.18)
                      : AppColor.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary
                        ? Colors.white.withOpacity(0.18)
                        : AppColor.primary.withOpacity(0.15),
                  ),
                ),
                child: Icon(
                  icon,
                  color: primary ? Colors.white : AppColor.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      title,
                      weight: FontWeight.w900,
                      size: 15,
                      color: primary ? Colors.white : AppColor.secondary,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      subtitle,
                      size: 12,
                      color: primary ? Colors.white70 : AppColor.textMuted,
                    ),
                  ],
                ),
              ),
              if (_busy && primary)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: primary
                      ? Colors.white.withOpacity(0.9)
                      : AppColor.textMuted.withOpacity(0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final v = 1.0 + (_pulseCtrl.value * 0.10);
            return Transform.scale(
              scale: v,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.primary.withOpacity(0.18),
                  ),
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: AppColor.primary,
                  size: 30,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget('SOS Emergency', weight: FontWeight.w900, size: 18),
              TextWidget(
                'Contact: ${widget.emergencyContact}',
                size: 12,
                color: AppColor.textMuted,
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.cardFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.border),
            ),
            child: const Icon(Icons.close, color: AppColor.secondary),
          ),
        ),
      ],
    );
  }

  Widget _noteField() {
    return TextField(
      controller: _noteC,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Optional note (e.g., “I am injured”, “Need rescue”)',
        hintStyle: TextStyle(color: AppColor.textMuted.withOpacity(0.85)),
        filled: true,
        fillColor: AppColor.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColor.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColor.primary.withOpacity(0.5), width: 1.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColor.borderStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              _header(),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: TextWidget(
                  'Emergency Type',
                  weight: FontWeight.w900,
                  size: 14,
                  color: AppColor.secondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _chip(EmergencyType.medical),
                  _chip(EmergencyType.fire),
                  _chip(EmergencyType.flood),
                   _chip(EmergencyType.other),
                ],
              ),
              const SizedBox(height: 12),
              _noteField(),
              const SizedBox(height: 14),
              _actionCard(
                icon: Icons.sms_rounded,
                title: 'SIM SMS (Composer)',
                subtitle: 'Opens SMS app with full SOS message',
                onTap: _sendSmsComposer,
                primary: true,
              ),
              const SizedBox(height: 12),
              _actionCard(
                icon: FontAwesomeIcons.whatsapp,
                title: 'WhatsApp Message',
                subtitle: 'Opens WhatsApp chat with prefilled SOS message',
                onTap: _sendWhatsApp,
              ),
              const SizedBox(height: 12),
              _actionCard(
                icon: Icons.send_rounded,
                title: 'Direct SMS (Android)',
                subtitle: 'Sends instantly (permission). Falls back to composer.',
                onTap: _sendDirectSmsAndroid,
              ),
              const SizedBox(height: 12),
              _actionCard(
                icon: Icons.call_rounded,
                title: 'Call Emergency Contact',
                subtitle: 'Opens dialer for immediate call',
                onTap: _call,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= TEST PANEL (same logic, tokenized UI) =================

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
  State<_SosTestPanel> createState() => _SosTestPanelState();
}

class _SosTestPanelState extends State<_SosTestPanel> {
  late SosPayload _payload;
  bool _fetching = false;
  String? _status;

  final _latC = TextEditingController();
  final _lngC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _payload = widget.initialPayload;
  }

  @override
  void dispose() {
    _latC.dispose();
    _lngC.dispose();
    super.dispose();
  }

  String _messageWithLink(String link) {
    final msg = _payload.message;
    final lines = msg.split('\n');
    final idx = lines.indexWhere((l) => l.trim().startsWith('My location:'));
    if (idx >= 0) {
      lines[idx] = 'My location: $link';
      return lines.join('\n').trim();
    }
    return '$msg\n\nMy location: $link'.trim();
  }

  bool _validLatLng(double lat, double lng) =>
      lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;

  Future<void> _fetchLocation() async {
    if (_fetching) return;
    setState(() {
      _fetching = true;
      _status = null;
    });

    try {
      final link = await SosService.fetchMapsLink();
      if (link == null) {
        setState(() {
          _status = 'Timed out. Use Manual Lat/Lng below (demo-safe).';
        });
        PopupUtils.warning('Location', _status!);
        return;
      }

      setState(() {
        _payload = _payload.copyWith(
          mapsLink: link,
          message: _messageWithLink(link),
        );
        _status = 'Location attached ✅';
      });

      PopupUtils.success('Location', 'Location attached ✅');
    } catch (e) {
      setState(() => _status = 'Error: $e');
      PopupUtils.warning('Location', e.toString());
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  void _attachManualLocation() {
    final lat = double.tryParse(_latC.text.trim());
    final lng = double.tryParse(_lngC.text.trim());

    if (lat == null || lng == null) {
      PopupUtils.warning('Manual Location', 'Enter valid numbers for lat/lng.');
      return;
    }
    if (!_validLatLng(lat, lng)) {
      PopupUtils.warning('Manual Location', 'Lat/Lng out of range.');
      return;
    }

    final link = SosService.mapsLink(lat, lng);

    setState(() {
      _payload = _payload.copyWith(
        mapsLink: link,
        message: _messageWithLink(link),
      );
      _status = 'Manual location attached ✅';
    });

    PopupUtils.success('Manual Location', 'Attached ✅');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: TextWidget(
                      'Simulator Test Mode',
                      weight: FontWeight.w900,
                      size: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: AppColor.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextWidget('To: ${widget.emergency}',
                  size: 12, color: AppColor.textMuted),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.border),
                ),
                child: Text(
                  _payload.message,
                  style: const TextStyle(fontSize: 13, height: 1.25),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _payload.message),
                        );
                        PopupUtils.success('Copied', 'SOS message copied');
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Message'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _payload.mapsLink == null
                          ? null
                          : () async {
                              try {
                                await SosService.openMapsLink(_payload.mapsLink!);
                              } catch (e) {
                                PopupUtils.warning('Maps', e.toString());
                              }
                            },
                      icon: const Icon(Icons.map),
                      label: const Text('Open Maps'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _fetching ? null : _fetchLocation,
                  icon: _fetching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_fetching ? 'Fetching...' : 'Fetch Location (Auto)'),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.cardFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      'Manual Location (Demo-safe)',
                      weight: FontWeight.w900,
                      size: 14,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latC,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              filled: true,
                              fillColor: AppColor.inputFill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _lngC,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              filled: true,
                              fillColor: AppColor.inputFill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _attachManualLocation,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Attach Manual Location'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextWidget(
                      'Example (Faisalabad): 31.418000 , 73.079100',
                      size: 12,
                      color: AppColor.textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextWidget(
                _status ??
                    (_payload.mapsLink == null
                        ? 'Location not attached yet.'
                        : 'Location attached ✅'),
                size: 12,
                color: (_payload.mapsLink == null)
                    ? AppColor.danger
                    : AppColor.safeGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}