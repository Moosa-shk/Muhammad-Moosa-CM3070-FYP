import 'package:hive/hive.dart';

part 'quiz_model.g.dart';

/// Quiz question model stored locally with Hive and synced from Firestore.
@HiveType(typeId: 55)
class QuizModel {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final List<String> options;

  @HiveField(3)
  final int correctIndex;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String difficulty;

  @HiveField(6)
  final int xp;

  @HiveField(7)
  final String kitItemId;

  const QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.difficulty,
    required this.xp,
    this.kitItemId = '',
  });

  /// Safely creates a QuizModel from Firestore data.
  /// Handles different formats for `correctIndex` and fallback values.
  factory QuizModel.fromDoc(String docId, Map<String, dynamic> map) {
    final options =
        (map['options'] as List?)?.map((e) => e.toString()).toList() ?? [];

    int parsedCorrectIndex = 0;
    final raw = map['correctIndex'];

    if (raw is int) {
      parsedCorrectIndex = raw;
    } else if (raw is String) {
      parsedCorrectIndex = int.tryParse(raw) ?? 0;
    } else if (map.containsKey('answer')) {
      final answer = map['answer']?.toString() ?? '';
      final idx = options.indexOf(answer);
      parsedCorrectIndex = idx >= 0 ? idx : 0;
    }

    return QuizModel(
      id: docId,
      question: map['question']?.toString() ?? '',
      options: options,
      correctIndex: parsedCorrectIndex,
      category: map['category']?.toString() ?? 'General',
      difficulty: map['difficulty']?.toString() ?? 'Basic',
      xp: map['xp'] is int
          ? map['xp']
          : int.tryParse('${map['xp']}') ?? 10,
      kitItemId: map['kitItemId']?.toString() ?? '',
    );
  }
}