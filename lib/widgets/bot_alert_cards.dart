// lib/widgets/bot_alert_cards.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/colors.dart';
import '../models/disaster_alert_model.dart';
import 'text_widget.dart';

/// BotAlertsPanel is a UI widget used to display disaster alerts
/// fetched from external alert sources. The panel shows a short
/// list of the most recent alerts along with important information
/// such as severity level, source, and time.
class BotAlertsPanel extends StatelessWidget {
  const BotAlertsPanel({
    super.key,
    required this.title,
    required this.alerts,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final String title;
  final List<DisasterAlert> alerts;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {

    /// If no alerts are available, display a safe status message
    if (alerts.isEmpty) {
      return _safeSection(title: emptyTitle, subtitle: emptySubtitle);
    }

    /// Otherwise display the latest alerts
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(title, weight: FontWeight.w900, size: 15),
        const SizedBox(height: 10),

        /// Only show the first few alerts to keep UI compact
        ...alerts.take(3).map(_alertCard),
      ],
    );
  }

  /// Builds the UI card for a single disaster alert
  Widget _alertCard(DisasterAlert alert) {
    final color = _severityColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      /// Card styling
      decoration: BoxDecoration(
        color: AppColor.cardFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Alert title
          TextWidget(alert.title, weight: FontWeight.w900),

          const SizedBox(height: 6),

          /// Short description of the alert
          TextWidget(alert.summary, size: 13, color: AppColor.textMuted),

          const SizedBox(height: 12),

          /// Tags showing alert metadata
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(alert.source),

              /// Severity chip (color depends on level)
              _chip(alert.severity, color: color),

              /// Magnitude chip (used mainly for earthquakes)
              if (alert.magnitude != null)
                _chip(
                  "M ${alert.magnitude!.toStringAsFixed(1)}",
                  color: AppColor.primary,
                ),
            ],
          ),

          const SizedBox(height: 10),

          /// Publication time of the alert
          TextWidget(
            DateFormat("d MMM • h:mm a").format(alert.publishedAt.toLocal()),
            size: 11,
            color: AppColor.textMuted,
          ),

          const SizedBox(height: 10),

          /// Link to original source of the alert
          if (alert.url.trim().isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(alert.url);

                if (uri != null) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: AppColor.primary,
                  ),
                  SizedBox(width: 6),
                  TextWidget(
                    "Open Source",
                    size: 13,
                    weight: FontWeight.w900,
                    color: AppColor.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Displayed when no alerts are currently active
  Widget _safeSection({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColor.safeGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.safeGreen.withOpacity(0.18)),
      ),

      child: Row(
        children: [

          /// Safety icon
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColor.safeGreen,
            child: const Icon(Icons.verified, color: Colors.white),
          ),

          const SizedBox(width: 12),

          /// Safety message
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

  /// Small chip widget used to display tags like
  /// source, severity level, or magnitude.
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

  /// Determines the color used for the severity level
  /// based on the alert type.
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
}