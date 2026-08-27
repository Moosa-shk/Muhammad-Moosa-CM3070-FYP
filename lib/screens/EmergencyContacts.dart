// lib/screens/emergency/emergency_directory_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/text_widget.dart';

class EmergencyDirectoryScreen extends StatefulWidget {
  const EmergencyDirectoryScreen({super.key});

  @override
  State<EmergencyDirectoryScreen> createState() =>
      _EmergencyDirectoryScreenState();
}

class _EmergencyDirectoryScreenState
    extends State<EmergencyDirectoryScreen> {
  final _searchC = TextEditingController();

  // ===============================================================
  // EXISTING EMERGENCY DATA
  // ===============================================================

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

  String get _q => _searchC.text.trim().toLowerCase();

  List<Map<String, dynamic>> get _filtered {
    if (_q.isEmpty) return _items;

    return _items.where((m) {
      final text =
          "${m["title"]} ${m["subtitle"]} ${m["cat"]} ${m["phone"]}"
              .toLowerCase();

      return text.contains(_q);
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory(
    List<Map<String, dynamic>> list,
  ) {
    final Map<String, List<Map<String, dynamic>>> output = {};

    for (final item in list) {
      final category = (item["cat"] ?? "Other").toString();

      output.putIfAbsent(category, () => []);
      output[category]!.add(item);
    }

    return output;
  }

  // ===============================================================
  // CALL
  // ===============================================================

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

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final grouped = _groupByCategory(filtered);

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

          // =====================================================
          // CUSTOM HEADER
          // =====================================================

          _pageHeader(),

          const SizedBox(height: 22),

          // =====================================================
          // EMERGENCY HERO
          // =====================================================

          _emergencyHero(),

          const SizedBox(height: 22),

          // =====================================================
          // SEARCH
          // =====================================================

          _searchBar(),

          const SizedBox(height: 25),

          // =====================================================
          // DIRECTORY HEADER
          // =====================================================

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "Emergency Services",
                      size: 18,
                      weight: FontWeight.w900,
                      color: AppColor.text,
                    ),
                    SizedBox(height: 3),
                    TextWidget(
                      "Tap any service to open the phone dialer",
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
                  "${filtered.length}",
                  size: 11,
                  weight: FontWeight.w900,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =====================================================
          // EMPTY STATE
          // =====================================================

          if (filtered.isEmpty)
            _emptyState()
          else
            ...grouped.entries.map(
              (entry) => _categorySection(
                entry.key,
                entry.value,
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===============================================================
  // PAGE HEADER
  // ===============================================================

  Widget _pageHeader() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          TextWidget(
            "Emergency Directory",
            size: 27,
            weight: FontWeight.w900,
            color: AppColor.text,
            align: TextAlign.center,
          ),

          SizedBox(height: 5),

          TextWidget(
            "Essential help, one tap away",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // EMERGENCY HERO
  // ===============================================================

  Widget _emergencyHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondary.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "Need urgent help?",
                      size: 16,
                      weight: FontWeight.w900,
                      color: Colors.white,
                    ),

                    SizedBox(height: 4),

                    TextWidget(
                      "Call Rescue 1122 for emergency assistance",
                      size: 11.5,
                      color: Color(0xCFFFFFFF),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _call("1122"),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    ContainerCallIcon(),

                    SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            "CALL RESCUE 1122",
                            size: 12.5,
                            weight: FontWeight.w900,
                            color: AppColor.text,
                          ),
                          SizedBox(height: 1),
                          TextWidget(
                            "Ambulance & rescue",
                            size: 9.5,
                            color: AppColor.textMuted,
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppColor.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SEARCH BAR
  // ===============================================================

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchC,
        onChanged: (_) => setState(() {}),
        cursorColor: AppColor.primary,
        style: const TextStyle(
          color: AppColor.text,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: "Search service or number",
          hintStyle: TextStyle(
            color: AppColor.textMuted.withOpacity(0.75),
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),

          prefixIcon: Container(
            margin: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColor.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColor.primary,
              size: 20,
            ),
          ),

          suffixIcon: _q.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchC.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColor.textMuted,
                    size: 19,
                  ),
                )
              : null,

          filled: true,
          fillColor: AppColor.surface,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: AppColor.border,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: AppColor.border,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: AppColor.primary.withOpacity(0.45),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CATEGORY SECTION
  // ===============================================================

  Widget _categorySection(
    String category,
    List<Map<String, dynamic>> items,
  ) {
    final firstColor =
        (items.first["color"] as Color?) ?? AppColor.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: firstColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: TextWidget(
                  category,
                  size: 14,
                  weight: FontWeight.w900,
                  color: AppColor.text,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.inputFill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TextWidget(
                  "${items.length}",
                  size: 9.5,
                  weight: FontWeight.w800,
                  color: AppColor.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          ...items.map(_card),
        ],
      ),
    );
  }

  // ===============================================================
  // CONTACT CARD
  // ===============================================================

  Widget _card(Map<String, dynamic> item) {
    final Color color =
        (item["color"] as Color?) ?? AppColor.primary;

    final IconData icon =
        (item["icon"] as IconData?) ?? Icons.phone_rounded;

    final phone = item["phone"].toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _call(phone),
          borderRadius: BorderRadius.circular(19),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: AppColor.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // SERVICE ICON
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 13),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        item["title"].toString(),
                        size: 14,
                        weight: FontWeight.w900,
                        color: AppColor.text,
                      ),

                      const SizedBox(height: 3),

                      TextWidget(
                        item["subtitle"].toString(),
                        size: 10.5,
                        color: AppColor.textMuted,
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_in_talk_outlined,
                            color: color,
                            size: 14,
                          ),

                          const SizedBox(width: 5),

                          TextWidget(
                            phone,
                            size: 11.5,
                            weight: FontWeight.w900,
                            color: color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // CALL BUTTON
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.20),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                    size: 20,
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
  // EMPTY SEARCH STATE
  // ===============================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColor.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColor.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColor.primary,
              size: 27,
            ),
          ),

          const SizedBox(height: 14),

          const TextWidget(
            "No services found",
            size: 15,
            weight: FontWeight.w900,
            color: AppColor.text,
          ),

          const SizedBox(height: 5),

          const TextWidget(
            "Try searching by service name or emergency number.",
            size: 11,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SMALL HERO CALL ICON
// =================================================================

class ContainerCallIcon extends StatelessWidget {
  const ContainerCallIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppColor.primarySoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.call_rounded,
        color: AppColor.primary,
        size: 18,
      ),
    );
  }
}