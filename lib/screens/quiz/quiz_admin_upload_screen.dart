import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';

class QuizAdminUploadScreen extends StatefulWidget {
  const QuizAdminUploadScreen({super.key});

  @override
  State<QuizAdminUploadScreen> createState() => _QuizAdminUploadScreenState();
}

class _QuizAdminUploadScreenState extends State<QuizAdminUploadScreen> {
  final _questionCtrl = TextEditingController();
  final _opt1 = TextEditingController();
  final _opt2 = TextEditingController();
  final _opt3 = TextEditingController();
  final _opt4 = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _xpCtrl = TextEditingController(text: "10");
  final _kitCtrl = TextEditingController();

  String category = 'emergency_basics';
  String difficulty = 'Basic';
  bool loading = false;

  final categories = {
    'emergency_basics': 'Emergency Basics',
    'food_water_safety': 'Food & Water Safety',
    'first_aid_health': 'First Aid & Health',
    'disaster_response': 'Disaster Response',
  };

  Future<void> submitQuiz() async {
    if (_questionCtrl.text.isEmpty ||
        _answerCtrl.text.isEmpty ||
        _opt1.text.isEmpty ||
        _opt2.text.isEmpty ||
        _opt3.text.isEmpty ||
        _opt4.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: AppColor.primary,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(category)
          .collection('questions')
          .add({
        "question": _questionCtrl.text.trim(),
        "options": [
          _opt1.text.trim(),
          _opt2.text.trim(),
          _opt3.text.trim(),
          _opt4.text.trim(),
        ],
        "answer": _answerCtrl.text.trim(),
        "category": categories[category],
        "difficulty": difficulty,
        "xp": int.tryParse(_xpCtrl.text) ?? 10,
        "kitItemId": _kitCtrl.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Success",
        "Quiz added successfully",
        backgroundColor: AppColor.safeGreen,
        colorText: Colors.white,
      );

      _questionCtrl.clear();
      _opt1.clear();
      _opt2.clear();
      _opt3.clear();
      _opt4.clear();
      _answerCtrl.clear();
      _kitCtrl.clear();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: AppColor.primary,
        colorText: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        title: const Text(
          "Quiz Admin Uploader",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field("Question", _questionCtrl, maxLines: 3),
            const SizedBox(height: 12),

            _field("Option 1", _opt1),
            _field("Option 2", _opt2),
            _field("Option 3", _opt3),
            _field("Option 4", _opt4),
            const SizedBox(height: 12),

            _field("Correct Answer", _answerCtrl),
            _field("XP", _xpCtrl, keyboard: TextInputType.number),
            _field("Kit Item ID (e.g fire_extinguisher)", _kitCtrl),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: "Category"),
              items: categories.keys
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(categories[c]!),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: difficulty,
              decoration: const InputDecoration(labelText: "Difficulty"),
              items: ['Basic', 'Intermediate', 'Advanced']
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => difficulty = v!),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : submitQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Add Quiz",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}