import 'package:hive/hive.dart';

part 'first_aid_model.g.dart';

/// Model representing a first aid guide stored locally using Hive.
@HiveType(typeId: 1)
class FirstAidModel extends HiveObject {

  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<String> steps;

  FirstAidModel({
    required this.title,
    required this.description,
    required this.steps,
  });

  /// Creates a FirstAidModel from a map (e.g., API or JSON data).
  factory FirstAidModel.fromMap(Map<String, dynamic> map) {
    return FirstAidModel(
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      steps: (map['steps'] is List)
          ? (map['steps'] as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }

  /// Converts the model to a map for storage or transfer.
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'steps': steps,
      };
}