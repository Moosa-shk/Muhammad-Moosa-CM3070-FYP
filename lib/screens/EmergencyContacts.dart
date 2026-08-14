import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/text_widget.dart';

/// Emergency directory screen.
/// This feature provides quick access to important emergency
/// services such as police, fire brigade, ambulance, and
/// disaster helplines. Users can search and directly call
/// these numbers from within the application.
class EmergencyDirectoryScreen extends StatefulWidget {
  const EmergencyDirectoryScreen({super.key});

  @override
  State<EmergencyDirectoryScreen> createState() =>
      _EmergencyDirectoryScreenState();
}

class _EmergencyDirectoryScreenState extends State<EmergencyDirectoryScreen> {

  /// Controller used for searching contacts in the directory
  final _searchC = TextEditingController();

  /// Static list of emergency contacts used in the directory
  final List<Map<String, dynamic>> _items = const [

    {
      "cat": "Police",
      "title": "Police Emergency",
      "subtitle": "Report crime / emergency",
      "phone": "15",
      "icon": Icons.local_police_rounded,
      "color": Color(0xFF2E5BFF),
    },

    {
      "cat": "Fire Brigade",
      "title": "Fire Brigade",
      "subtitle": "Fire emergency response",
      "phone": "16",
      "icon": Icons.local_fire_department_rounded,
      "color": Color(0xFFFF6B3D),
    },

    {
      "cat": "Ambulance / Rescue",
      "title": "Rescue 1122",
      "subtitle": "Ambulance + Rescue services",
      "phone": "1122",
      "icon": Icons.emergency_rounded,
      "color": Color(0xFFE53935),
    },

    {
      "cat": "Ambulance / Rescue",
      "title": "Edhi Ambulance",
      "subtitle": "Ambulance service (availability varies)",
      "phone": "115",
      "icon": Icons.local_hospital_rounded,
      "color": Color(0xFF4CAF50),
    },

    {
      "cat": "Ambulance / Rescue",
      "title": "Chhipa Ambulance",
      "subtitle": "Ambulance service (availability varies)",
      "phone": "1020",
      "icon": Icons.medical_services_rounded,
      "color": Color(0xFF00A86B),
    },

    {
      "cat": "Disaster Helplines",
      "title": "PDMA Helpline",
      "subtitle": "Provincial disaster help",
      "phone": "1700",
      "icon": Icons.warning_amber_rounded,
      "color": Color(0xFFFFB300),
    },

    {
      "cat": "Women & Child Safety",
      "title": "Women Helpline",
      "subtitle": "Support & protection services",
      "phone": "1043",
      "icon": Icons.support_agent_rounded,
      "color": Color(0xFF9C27B0),
    },
  ];

  /// Returns the current search query
  String get _q => _searchC.text.trim().toLowerCase();

  /// Filters directory items based on search query
  List<Map<String, dynamic>> get _filtered {
    if (_q.isEmpty) return _items;

    return _items.where((m) {
      final t = "${m["title"]} ${m["subtitle"]} ${m["cat"]} ${m["phone"]}"
          .toString()
          .toLowerCase();
      return t.contains(_q);
    }).toList();
  }

  /// Groups contacts by their category (Police, Fire, etc.)
  Map<String, List<Map<String, dynamic>>> _groupByCategory(
    List<Map<String, dynamic>> list,
  ) {
    final Map<String, List<Map<String, dynamic>>> out = {};

    for (final e in list) {
      final c = (e["cat"] ?? "Other").toString();
      out.putIfAbsent(c, () => []);
      out[c]!.add(e);
    }

    return out;
  }

  /// Opens the phone dialer to call the selected emergency number
  Future<void> _call(String phone) async {
    final uri = Uri.parse("tel:$phone");
    final ok = await canLaunchUrl(uri);

    if (!ok) {
      Get.snackbar(
        "Call failed",
        "Phone dialer open nahi ho raha.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColor.secondary,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByCategory(_filtered);

    return AppScaffold(
      title: "Emergency Directory",
      subtitle: "Police, Fire, Rescue & Helplines",
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 6),

          /// Search bar used to filter emergency contacts
          _searchBar(),

          const SizedBox(height: 18),

          /// Display message if no search results are found
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: TextWidget(
                  "No results found",
                  color: AppColor.textMuted,
                  weight: FontWeight.w800,
                ),
              ),
            )
          else

            /// Display grouped emergency contacts
            ...grouped.entries.map((entry) {

              final cat = entry.key;
              final list = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _sectionHeader(cat),

                    const SizedBox(height: 12),

                    ...list.map(_card),
                  ],
                ),
              );
            }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Search input field for filtering contacts
  Widget _searchBar() {
    final radius = BorderRadius.circular(18);

    return TextField(
      controller: _searchC,
      onChanged: (_) => setState(() {}),
      cursorColor: AppColor.primary,
      style: const TextStyle(
        color: AppColor.text,
        fontWeight: FontWeight.w700,
      ),

      decoration: InputDecoration(
        hintText: "Search contacts (e.g., 1122, police, fire...)",
        hintStyle: TextStyle(
          color: AppColor.textMuted.withOpacity(0.75),
          fontWeight: FontWeight.w700,
        ),

        prefixIcon: const Icon(Icons.search_rounded, color: AppColor.textMuted),
        prefixIconConstraints: const BoxConstraints(minWidth: 52),

        filled: true,
        fillColor: AppColor.inputFill,

        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),

        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColor.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColor.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColor.border),
        ),
      ),
    );
  }

  /// Section header used to display each category
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

  /// Card widget representing a single emergency contact
  Widget _card(Map<String, dynamic> e) {

    final Color c = (e["color"] as Color?) ?? AppColor.primary;
    final IconData icon = (e["icon"] as IconData?) ?? Icons.phone_rounded;

    return GestureDetector(
      onTap: () => _call(e["phone"].toString()),

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColor.cardFill,
          borderRadius: BorderRadius.circular(18),
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

            /// Icon representing the emergency service
            Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.withOpacity(0.18)),
              ),

              child: Icon(icon, color: c, size: 26),
            ),

            const SizedBox(width: 14),

            /// Contact information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  TextWidget(
                    e["title"].toString(),
                    size: 15,
                    weight: FontWeight.w900,
                    color: AppColor.text,
                  ),

                  const SizedBox(height: 6),

                  TextWidget(
                    e["subtitle"].toString(),
                    size: 13,
                    color: AppColor.textMuted,
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: c.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: c.withOpacity(0.18)),
                    ),

                    child: TextWidget(
                      "Call: ${e["phone"]}",
                      size: 12,
                      weight: FontWeight.w900,
                      color: c,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Icon(Icons.call_rounded, color: c),
          ],
        ),
      ),
    );
  }
}