import 'package:hive/hive.dart';

part 'safety_tip_model.g.dart';

/// Model representing a safety tip stored locally using Hive.
@HiveType(typeId: 3)
class SafetyTipModel extends HiveObject {

  @HiveField(0)
  String category;

  @HiveField(1)
  String content;

  SafetyTipModel({
    required this.category,
    required this.content,
  });

  factory SafetyTipModel.fromMap(Map<String, dynamic> map) {
    return SafetyTipModel(
      category: (map['category'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category,
        'content': content,
      };
}