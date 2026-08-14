// lib/widgets/bot_places_cards.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/colors.dart';
import 'text_widget.dart';

/// BotPlacesPanel is responsible for displaying nearby safe locations
/// (such as hospitals, shelters, or emergency facilities) that are
/// retrieved from location-based services like OpenStreetMap.
class BotPlacesPanel extends StatelessWidget {
  const BotPlacesPanel({
    super.key,
    required this.title,
    required this.places,
  });

  final String title;
  final List<BotPlace> places;

  @override
  Widget build(BuildContext context) {

    /// If no nearby places are returned from the API
    /// show a friendly message to the user
    if (places.isEmpty) {
      return TextWidget(
        "Nearby results nahi milay (ya Overpass busy/rate limit). Thori dair baad try karo.",
        size: 13,
        color: AppColor.textMuted,
      );
    }

    /// Otherwise display the nearby places list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(title, weight: FontWeight.w900, size: 15),
        const SizedBox(height: 10),

        /// Only show the first few nearby results to keep the UI clean
        ...places.take(5).map(_tile),
      ],
    );
  }

  /// Builds the UI tile for a single nearby place
  Widget _tile(BotPlace p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),

      /// Card styling
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [

          /// Location icon indicator
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColor.primary.withOpacity(0.12),
            child: const Icon(
              Icons.place_rounded,
              color: AppColor.primary,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          /// Place name and hint text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(p.name, weight: FontWeight.w900, size: 13),
                const SizedBox(height: 4),

                /// Instruction to open the location in maps
                TextWidget(
                  "Tap to open in Maps",
                  size: 11,
                  color: AppColor.textMuted,
                ),
              ],
            ),
          ),

          /// Button that opens the location in Google Maps
          IconButton(
            onPressed: () async {

              /// Construct Google Maps URL using latitude and longitude
              final url = "https://maps.google.com/?q=${p.lat},${p.lon}";
              final uri = Uri.parse(url);

              /// Launch the external maps application
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: AppColor.secondary,
              size: 18,
            ),
          )
        ],
      ),
    );
  }
}

/// BotPlace model represents a nearby location
/// retrieved from the location-based search service.
/// It stores the place name along with coordinates.
class BotPlace {
  final String name;
  final double lat;
  final double lon;

  BotPlace({
    required this.name,
    required this.lat,
    required this.lon,
  });
}