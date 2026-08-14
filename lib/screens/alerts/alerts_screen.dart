import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/colors.dart';
import '../../../widgets/text_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../services/disaster_alert_service.dart';
import '../../../models/disaster_alert_model.dart';
import '../../../widgets/app_scaffold.dart';

/// Screen that displays real-time disaster alerts and recent warnings.
class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with SingleTickerProviderStateMixin {
  final DisasterAlertService _alertService = DisasterAlertService();

  List<DisasterAlert> _alerts = [];
  String? _error;
  bool _loading = true;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  /// Fetches alerts from the alert service and filters them for Pakistan.
  Future<void> _loadAlerts() async {
    try {
      final raw = await _alertService.fetchRealTimeAlerts();

      final pakistanOnly = raw
          .where((a) =>
              "${a.title} ${a.summary}".toLowerCase().contains("pakistan"))
          .map(_sanitizeAlert)
          .toList();

      if (!mounted) return;
      setState(() {
        _alerts = pakistanOnly;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Detects alerts that mention multiple countries.
  bool _isMultiCountry(String text) {
    final countries = [
      "afghanistan",
      "india",
      "iran",
      "iraq",
      "china",
      "turkey",
      "türkiye",
      "syria",
      "kazakhstan",
      "kyrgyzstan",
      "tajikistan",
      "turkmenistan",
      "uzbekistan",
      "nepal",
      "bangladesh",
      "sri lanka",
    ];

    int count = 0;
    for (final c in countries) {
      if (text.contains(c)) count++;
      if (count >= 2) return true;
    }
    return false;
  }

  /// Adjusts alerts so they clearly reference Pakistan if the alert spans multiple countries.
  DisasterAlert _sanitizeAlert(DisasterAlert alert) {
    final text = "${alert.title} ${alert.summary}".toLowerCase();

    if (_isMultiCountry(text)) {
      return DisasterAlert(
        id: alert.id,
        title: _rewriteTitle(alert.title),
        summary: _rewriteSummary(alert.summary),
        publishedAt: alert.publishedAt,
        source: alert.source,
        url: alert.url,
        severity: alert.severity,
        magnitude: alert.magnitude,
      );
    }

    return alert;
  }

  String _rewriteTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains("drought")) return "Drought Ongoing in Pakistan";
    if (t.contains("flood")) return "Flood Alert in Pakistan";
    if (t.contains("earthquake")) return "Earthquake Detected in Pakistan";
    if (t.contains("cyclone")) return "Cyclone Alert for Pakistan";
    return "Disaster Alert for Pakistan";
  }

  String _rewriteSummary(String summary) {
    final s = summary.toLowerCase();
    if (s.contains("drought")) {
      return "Drought conditions are currently affecting parts of Pakistan. Authorities advise precautionary measures.";
    }
    if (s.contains("flood")) {
      return "Flood risk remains active in Pakistan. Stay alert and follow official guidance.";
    }
    if (s.contains("earthquake")) {
      return "Seismic activity has been detected in Pakistan. Monitor official updates.";
    }
    return "A disaster alert is currently active for Pakistan.";
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Disaster Alerts",
      subtitle: "Live warnings and recent updates",
      scroll: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColor.primary),
          onPressed: () {
            setState(() {
              _loading = true;
              _alerts.clear();
            });
            _loadAlerts();
          },
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return _errorView(_error!);

    final now = DateTime.now();

    final nearYou = _alerts
        .where((a) =>
            a.source == "USGS" &&
            a.magnitude != null &&
            now.difference(a.publishedAt).inHours <= 24)
        .toList();

    final currentPakistan = _alerts
        .where((a) =>
            now.difference(a.publishedAt).inHours <= 24 && a.source != "USGS")
        .toList();

    final recentPakistan =
        _alerts.where((a) => now.difference(a.publishedAt).inHours > 24).toList();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        _section("Current Alerts • Near You", nearYou, "You Are Safe",
            "No active alerts near your location"),
        const SizedBox(height: 22),
        _section("Current Alerts • Pakistan", currentPakistan, "All Clear",
            "No active disaster alerts in Pakistan"),
        const SizedBox(height: 22),
        _section("Recent Alerts • Pakistan", recentPakistan, "No Recent Alerts",
            "There have been no recent disaster events"),
      ],
    );
  }

  Widget _section(String title, List<DisasterAlert> alerts, String safeTitle,
      String safeSubtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        const SizedBox(height: 12),
        if (_loading)
          Column(children: List.generate(2, (_) => _shimmerCard()))
        else if (alerts.isEmpty)
          _safeSection(title: safeTitle, subtitle: safeSubtitle)
        else
          Column(children: alerts.map(_alertCard).toList()),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        TextWidget(title, weight: FontWeight.w900, size: 16),
      ],
    );
  }

  Widget _alertCard(DisasterAlert alert) {
    final color = _severityColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.cardFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(alert.title, weight: FontWeight.w900),
          const SizedBox(height: 8),
          TextWidget(alert.summary, size: 13, color: AppColor.textMuted),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(alert.source),
              const SizedBox(width: 8),
              _chip(alert.severity, color: color),
              if (alert.magnitude != null) ...[
                const SizedBox(width: 8),
                _chip("M ${alert.magnitude!.toStringAsFixed(1)}",
                    color: AppColor.primary),
              ],
            ],
          ),
          const SizedBox(height: 10),
          TextWidget(
            DateFormat("d MMM yyyy • h:mm a").format(alert.publishedAt.toLocal()),
            size: 11,
            color: AppColor.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _safeSection({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.safeGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.safeGreen.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColor.safeGreen,
            child: const Icon(Icons.verified, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(title, weight: FontWeight.w900),
                const SizedBox(height: 4),
                TextWidget(subtitle, size: 12, color: AppColor.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment(-1 + _shimmerController.value * 2, 0),
              end: Alignment(1 + _shimmerController.value * 2, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String text, {Color? color}) {
    final c = color ?? AppColor.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.18)),
      ),
      child: TextWidget(
        text,
        size: 11,
        color: c,
        weight: FontWeight.w800,
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "severe":
        return AppColor.danger;
      case "high":
        return const Color(0xFFFF7A00);
      case "moderate":
        return const Color(0xFFFFB300);
      default:
        return AppColor.safeGreen;
    }
  }

  Widget _errorView(String err) =>
      Center(child: CustomButton(title: "Retry", onTap: _loadAlerts));
}