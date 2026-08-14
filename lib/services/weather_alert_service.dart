// lib/services/weather_alert_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// This service fetches basic weather information
/// from the Open-Meteo API based on the user's location.
/// The weather data is used to generate a short alert message
/// that can warn the user about possible risky conditions.
class WeatherAlertService {

  /// Fetches current weather data using latitude and longitude
  /// and returns a short summary message.
  Future<String> getWeatherSummary({
    required double lat,
    required double lon,
  }) async {

    /// Open-Meteo is a free weather API that does not require an API key.
    final uri = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=$lat&longitude=$lon"
      "&current=temperature_2m,wind_speed_10m,precipitation"
      "&hourly=precipitation_probability"
      "&timezone=auto",
    );

    /// Send request to the weather API
    final res = await http.get(uri);

    /// If the request fails, return a simple error message
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return "Weather fetch failed (${res.statusCode}).";
    }

    /// Decode the JSON response
    final data = jsonDecode(res.body);

    final current = data["current"] ?? {};

    final temp = current["temperature_2m"];
    final wind = current["wind_speed_10m"];
    final precip = current["precipitation"];

    /// Basic rule-based logic to detect possible weather risks
    String risk = "No major warning detected.";

    /// If rain or wind values exceed a certain threshold,
    /// a caution message is shown.
    if ((precip is num && precip >= 5) || (wind is num && wind >= 40)) {
      risk = "Caution: heavy rain or strong winds possible. Updates follow karein.";
    }

    /// Final weather summary returned to the UI
    return "Current: ${temp ?? '--'}°C, Wind: ${wind ?? '--'} km/h, Rain: ${precip ?? '--'} mm. $risk";
  }
}