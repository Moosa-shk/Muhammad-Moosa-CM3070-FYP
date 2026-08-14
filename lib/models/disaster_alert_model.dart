/// Model representing a disaster alert fetched from external alert feeds
/// such as USGS, GDACS, or other disaster monitoring services.
class DisasterAlert {
  final String id;
  final String title;
  final String summary;
  final DateTime publishedAt;
  final String source;
  final String url;
  final String severity;
  final double? magnitude;

  DisasterAlert({
    required this.id,
    required this.title,
    required this.summary,
    required this.publishedAt,
    required this.source,
    required this.url,
    required this.severity,
    this.magnitude,
  });
}