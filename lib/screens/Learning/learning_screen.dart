// ===============================================================
// learning_screen.dart
// ===============================================================

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/widgets/text_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

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
      title: null,
      subtitle: null,
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          _pageHeader(),
          const SizedBox(height: 22),
          _libraryBanner(),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "Safety Guides",
                      size: 18,
                      weight: FontWeight.w900,
                      color: AppColor.text,
                    ),
                    SizedBox(height: 3),
                    TextWidget(
                      "Choose a topic to start reading",
                      size: 11.5,
                      color: AppColor.textMuted,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TextWidget(
                  "${_topics.length}",
                  size: 11,
                  weight: FontWeight.w900,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < _topics.length; i++) ...[
            _TopicCard(
              topic: _topics[i],
              accent: _topicColor(i),
            ),
            if (i != _topics.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _pageHeader() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          TextWidget(
            "Learning & Knowledge",
            size: 27,
            weight: FontWeight.w900,
            color: AppColor.text,
            align: TextAlign.center,
          ),
          SizedBox(height: 5),
          TextWidget(
            "Offline emergency preparedness guides",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _libraryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondary.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  "Preparedness Library",
                  size: 15.5,
                  weight: FontWeight.w900,
                  color: Colors.white,
                ),
                SizedBox(height: 4),
                TextWidget(
                  "Guides remain available without internet",
                  size: 11.5,
                  color: Color(0xCFFFFFFF),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.offline_pin_outlined,
              color: AppColor.safeGreen,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  static Color _topicColor(int index) {
    switch (index) {
      case 0:
        return AppColor.warning;
      case 1:
        return AppColor.info;
      case 2:
        return AppColor.danger;
      case 3:
        return AppColor.safeGreen;
      default:
        return AppColor.primary;
    }
  }
}

// =================================================================
// TOPIC CARD
// =================================================================

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.accent,
  });

  final Map<String, dynamic> topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final title = (topic["title"] ?? "").toString();
    final subtitle = (topic["subtitle"] ?? "").toString();
    final summary = (topic["summary"] ?? "").toString();

    final icon = (topic["icon"] as IconData?) ?? Icons.picture_as_pdf_rounded;

    final highlights = (topic["highlights"] as List).cast<String>();

    final assetPath = (topic["asset"] ?? "").toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
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
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColor.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadow,
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: accent,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          title,
                          size: 16,
                          weight: FontWeight.w900,
                          color: AppColor.text,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            TextWidget(
                              "${highlights.length} key reminders",
                              size: 10.5,
                              weight: FontWeight.w700,
                              color: AppColor.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColor.inputFill,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: AppColor.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextWidget(
                summary,
                size: 12.5,
                color: AppColor.textMuted,
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final reminder in highlights.take(2))
                    _ReminderChip(
                      text: reminder,
                      accent: accent,
                    ),
                  if (highlights.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.inputFill,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextWidget(
                        "+${highlights.length - 2} more",
                        size: 10,
                        weight: FontWeight.w800,
                        color: AppColor.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 17,
                      color: accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextWidget(
                        subtitle,
                        size: 10.5,
                        weight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: accent,
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
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.text,
    required this.accent,
  });

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withOpacity(0.12),
        ),
      ),
      child: TextWidget(
        text,
        size: 10,
        weight: FontWeight.w700,
        color: accent,
      ),
    );
  }
}

// =================================================================
// PDF READER
// =================================================================

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
  final PdfViewerController _controller = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 1;

  String? _loadError;

  void _resetZoom() {
    _controller.zoomLevel = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: null,
      subtitle: null,
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          _readerHeader(),
          const SizedBox(height: 14),
          _quickReminders(),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColor.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadow,
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    SfPdfViewer.asset(
                      widget.assetPath,
                      controller: _controller,
                      onDocumentLoaded: (details) {
                        setState(() {
                          _totalPages = details.document.pages.count;
                          _currentPage = 1;
                          _loadError = null;
                        });
                      },
                      onPageChanged: (details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed: (details) {
                        setState(() {
                          _loadError = details.description;
                        });
                      },
                    ),
                    if (_loadError != null)
                      Positioned.fill(
                        child: Container(
                          color: AppColor.surface,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    color: AppColor.dangerSoft,
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: AppColor.danger,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const TextWidget(
                                  "Unable to open guide",
                                  size: 16,
                                  weight: FontWeight.w900,
                                  color: AppColor.text,
                                  align: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                TextWidget(
                                  _loadError!,
                                  size: 11.5,
                                  color: AppColor.textMuted,
                                  align: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _readerHeader() {
    return Column(
      children: [
        TextWidget(
          widget.title,
          size: 24,
          weight: FontWeight.w900,
          color: AppColor.text,
          align: TextAlign.center,
        ),
        const SizedBox(height: 5),
        TextWidget(
          widget.subtitle,
          size: 11.5,
          color: AppColor.textMuted,
          align: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColor.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColor.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.layers_outlined,
                      size: 18,
                      color: AppColor.primary,
                    ),
                    const SizedBox(width: 8),
                    TextWidget(
                      "Page $_currentPage of $_totalPages",
                      size: 11.5,
                      weight: FontWeight.w800,
                      color: AppColor.text,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _resetZoom,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColor.secondary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.secondary.withOpacity(0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.center_focus_strong_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickReminders() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.highlights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final reminder = widget.highlights[index];

          return Container(
            width: 220,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColor.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColor.safeSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColor.safeGreen,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: TextWidget(
                    reminder,
                    size: 10.5,
                    weight: FontWeight.w700,
                    color: AppColor.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
