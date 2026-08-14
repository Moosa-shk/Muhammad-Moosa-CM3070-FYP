// ===============================================================
// learning_screen.dart
// ---------------------------------------------------------------
// This screen provides educational resources to help users
// understand disaster preparedness and emergency safety.
//
// Users can select different disaster topics such as:
//
// • Earthquake safety
// • Flood awareness
// • Fire emergency response
// • General disaster preparedness
//
// Each topic contains:
// - A summary of the safety guidelines
// - Key highlight reminders
// - An offline PDF guide that opens inside the app
//
// The PDF viewer allows users to read disaster safety guides
// without requiring an internet connection.
// ===============================================================

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:disaster_app_ui/config/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// ===============================================================
// LEARNING SCREEN
// ---------------------------------------------------------------
// Displays a list of disaster preparedness topics that open
// detailed PDF safety guides when selected.
// ===============================================================

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  /// Static list of disaster learning topics
  static const List<Map<String, dynamic>> _topics = [
    {
      "title": "Earthquake Safety",
      "subtitle": "Offline PDF • opens inside the app",
      "asset": "assets/pdfs/earthquake.pdf",
      "highlights": [
        "Drop, cover, and hold on",
        "Stay away from windows",
        "Do not use elevators",
        "Be ready for aftershocks",
      ],
      "summary":
          "When shaking starts, drop to the ground, cover your head and neck, and hold on. Stay away from glass and heavy objects, and only move once it is safe.",
      "icon": Icons.crisis_alert_rounded,
    },
    {
      "title": "Flood Awareness",
      "subtitle": "Offline PDF • opens inside the app",
      "asset": "assets/pdfs/flood.pdf",
      "highlights": [
        "Never walk or drive through flood water",
        "Move to higher ground early",
        "Avoid fast-moving water and bridges",
        "Follow official warnings",
      ],
      "summary":
          "Flood water can be deeper and faster than it looks. Avoid crossings, move to higher ground early, and follow verified alerts from authorities.",
      "icon": Icons.water_damage_rounded,
    },
    {
      "title": "Fire Emergency",
      "subtitle": "Offline PDF • opens inside the app",
      "asset": "assets/pdfs/fire.pdf",
      "highlights": [
        "Stop, drop, and roll",
        "Stay low under smoke",
        "Use stairs, not elevators",
        "Meet at a safe location",
      ],
      "summary":
          "If clothing catches fire, stop, drop, and roll. In smoke, get low and exit quickly using stairs. Always have a family meeting point.",
      "icon": Icons.local_fire_department_rounded,
    },
    {
      "title": "General Preparedness",
      "subtitle": "Offline PDF • opens inside the app",
      "asset": "assets/pdfs/preparedness.pdf",
      "highlights": [
        "Build a simple emergency plan",
        "Keep a go-bag ready",
        "Know evacuation routes",
        "Keep trusted contacts updated",
      ],
      "summary":
          "Preparedness is about planning ahead: keep essentials ready, know where to go, and make sure your family can reach each other in an emergency.",
      "icon": Icons.backpack_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Learning & Knowledge",
      subtitle: "Tap a topic to open the PDF guide (offline).",
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        children: [
          const SizedBox(height: 10),

          /// Generate a topic card for each disaster topic
          for (final t in _topics) _TopicCard(topic: t),

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

// ===============================================================
// TOPIC CARD
// ---------------------------------------------------------------
// Displays a disaster learning topic including:
//
// • Title
// • Summary
// • Safety highlights
// • Navigation arrow
//
// When tapped, the PDF safety guide is opened.
// ===============================================================

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final Map<String, dynamic> topic;

  @override
  Widget build(BuildContext context) {
    final title = (topic["title"] ?? "").toString();
    final subtitle = (topic["subtitle"] ?? "").toString();
    final summary = (topic["summary"] ?? "").toString();
    final icon = (topic["icon"] as IconData?) ?? Icons.picture_as_pdf_rounded;
    final highlights = (topic["highlights"] as List).cast<String>();
    final assetPath = (topic["asset"] ?? "").toString();

    return InkWell(
      borderRadius: BorderRadius.circular(22),

      /// Navigate to PDF reader
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PdfReaderScreen(
              title: title,
              subtitle: subtitle,
              assetPath: assetPath,
              highlights: highlights,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Topic icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.primary.withOpacity(0.18)),
              ),
              child: Icon(icon, color: AppColor.primary, size: 26),
            ),

            const SizedBox(width: 14),

            /// Topic details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Topic title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColor.text,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Short description
                  Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMuted,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Display quick highlight reminders
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: highlights.take(3).map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColor.primary.withOpacity(0.18),
                          ),
                        ),
                        child: Text(
                          h,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColor.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  /// Subtitle text
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// Navigation arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColor.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// PDF READER SCREEN
// ---------------------------------------------------------------
// Opens and displays the disaster safety guide PDF.
//
// Features:
//
// • Offline PDF viewing
// • Page number indicator
// • Zoom reset button
// • Error handling if PDF fails to load
// • Highlight reminders displayed above the PDF
// ===============================================================

class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.highlights,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final List<String> highlights;

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {

  /// Controller for Syncfusion PDF viewer
  final PdfViewerController _controller = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 1;

  String? _loadError;

  /// Reset zoom level
  void _resetZoom() {
    _controller.zoomLevel = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      /// AppBar actions
      appBarActions: [

        /// Page indicator
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColor.border),
            ),
            child: Text(
              "$_currentPage/$_totalPages",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColor.secondary,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        /// Reset zoom button
        IconButton(
          tooltip: "Reset zoom",
          onPressed: _resetZoom,
          icon: const Icon(
            Icons.zoom_out_map_rounded,
            color: AppColor.primary,
          ),
        ),
      ],

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10),

          // ==========================================================
          // QUICK REMINDERS SECTION
          // ==========================================================

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColor.border),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Quick reminders",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColor.text,
                  ),
                ),

                const SizedBox(height: 10),

                /// Display highlight reminders
                for (final h in widget.highlights)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppColor.primary,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            h,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: AppColor.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ==========================================================
          // PDF VIEWER
          // ==========================================================

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.cardFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColor.border),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),

                child: SfPdfViewer.asset(
                  widget.assetPath,

                  controller: _controller,

                  /// When PDF loads successfully
                  onDocumentLoaded: (details) {
                    setState(() {
                      _totalPages = details.document.pages.count;
                      _currentPage = 1;
                      _loadError = null;
                    });
                  },

                  /// When user changes page
                  onPageChanged: (details) {
                    setState(() => _currentPage = details.newPageNumber);
                  },

                  /// Handle load error
                  onDocumentLoadFailed: (details) {
                    setState(() {
                      _loadError = details.description;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}