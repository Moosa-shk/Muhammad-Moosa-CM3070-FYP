import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseQuizSeedScreen extends StatefulWidget {
  const FirebaseQuizSeedScreen({super.key});

  @override
  State<FirebaseQuizSeedScreen> createState() =>
      _FirebaseQuizSeedScreenState();
}

class _FirebaseQuizSeedScreenState extends State<FirebaseQuizSeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String _status = 'Ready to seed quiz data';

  // ============================================================
  // QUIZ DATA
  // IMPORTANT:
  // Keep exactly 5 questions per category because the existing
  // quiz progress / safety-kit logic unlocks 5 kit items.
  // ============================================================

  final Map<String, List<Map<String, dynamic>>> _quizData = {
    // ==========================================================
    // 1. EMERGENCY BASICS
    // ==========================================================
    'emergency_basics': [
      {
        'id': 'emergency_basics_01',
        'question':
            'What should you do first when an emergency warning is issued?',
        'options': [
          'Ignore it until others react',
          'Stay calm and follow official instructions',
          'Immediately leave without checking anything',
          'Call everyone you know',
        ],
        'answer': 'Stay calm and follow official instructions',
        'category': 'Emergency Basics',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'emergency_plan',
      },
      {
        'id': 'emergency_basics_02',
        'question':
            'Which information should every family emergency plan include?',
        'options': [
          'Only social media passwords',
          'Emergency contacts and a meeting location',
          'Favourite restaurants',
          'Shopping lists',
        ],
        'answer': 'Emergency contacts and a meeting location',
        'category': 'Emergency Basics',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'emergency_contacts',
      },
      {
        'id': 'emergency_basics_03',
        'question':
            'Why is it important to keep a battery-powered flashlight in an emergency kit?',
        'options': [
          'For decoration',
          'To provide light during a power outage',
          'To charge a phone',
          'To signal only during daytime',
        ],
        'answer': 'To provide light during a power outage',
        'category': 'Emergency Basics',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'flashlight',
      },
      {
        'id': 'emergency_basics_04',
        'question':
            'What is the safest source of information during a developing disaster?',
        'options': [
          'Unverified social media posts',
          'Rumours from neighbours',
          'Official emergency authorities and trusted alerts',
          'Random forwarded messages',
        ],
        'answer': 'Official emergency authorities and trusted alerts',
        'category': 'Emergency Basics',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'emergency_radio',
      },
      {
        'id': 'emergency_basics_05',
        'question':
            'What should you do if authorities order an evacuation?',
        'options': [
          'Wait until the danger reaches your home',
          'Follow the recommended evacuation route promptly',
          'Use any blocked shortcut',
          'Stay behind to record videos',
        ],
        'answer': 'Follow the recommended evacuation route promptly',
        'category': 'Emergency Basics',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'evacuation_plan',
      },
    ],

    // ==========================================================
    // 2. FOOD & WATER SAFETY
    // ==========================================================
    'food_water_safety': [
      {
        'id': 'food_water_safety_01',
        'question':
            'How much emergency drinking water should you try to store?',
        'options': [
          'Only one glass per person',
          'Enough for basic needs for several days',
          'Water is not necessary in emergencies',
          'Only bottled soft drinks',
        ],
        'answer': 'Enough for basic needs for several days',
        'category': 'Food & Water Safety',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'water_supply',
      },
      {
        'id': 'food_water_safety_02',
        'question':
            'Which type of food is most suitable for an emergency supply kit?',
        'options': [
          'Highly perishable food',
          'Non-perishable food with a long shelf life',
          'Only frozen food',
          'Food requiring complicated cooking',
        ],
        'answer': 'Non-perishable food with a long shelf life',
        'category': 'Food & Water Safety',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'emergency_food',
      },
      {
        'id': 'food_water_safety_03',
        'question':
            'What should you do with food that has come into contact with floodwater?',
        'options': [
          'Wash it and eat it',
          'Dry it in sunlight',
          'Discard it',
          'Freeze it for later',
        ],
        'answer': 'Discard it',
        'category': 'Food & Water Safety',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'food_safety',
      },
      {
        'id': 'food_water_safety_04',
        'question':
            'If authorities say tap water may be unsafe, what should you do?',
        'options': [
          'Drink it normally',
          'Follow official boiling or treatment instructions',
          'Add sugar to it',
          'Leave it uncovered overnight',
        ],
        'answer': 'Follow official boiling or treatment instructions',
        'category': 'Food & Water Safety',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'water_purification',
      },
      {
        'id': 'food_water_safety_05',
        'question':
            'Why should emergency food and water supplies be checked regularly?',
        'options': [
          'To change their colour',
          'To replace expired or damaged items',
          'Because stored supplies cannot be used',
          'Only to make the kit heavier',
        ],
        'answer': 'To replace expired or damaged items',
        'category': 'Food & Water Safety',
        'difficulty': 'Advanced',
        'xp': 20,
        'kitItemId': 'supply_check',
      },
    ],

    // ==========================================================
    // 3. FIRST AID & HEALTH
    // ==========================================================
    'first_aid_health': [
      {
        'id': 'first_aid_health_01',
        'question':
            'What should you do before helping an injured person at a disaster scene?',
        'options': [
          'Immediately move them',
          'Make sure the scene is safe',
          'Give them food',
          'Ask them to walk',
        ],
        'answer': 'Make sure the scene is safe',
        'category': 'First Aid & Health',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'first_aid_kit',
      },
      {
        'id': 'first_aid_health_02',
        'question':
            'What is generally the first step when someone has severe external bleeding?',
        'options': [
          'Apply firm pressure to the wound',
          'Give them water',
          'Ask them to exercise',
          'Leave the wound uncovered without pressure',
        ],
        'answer': 'Apply firm pressure to the wound',
        'category': 'First Aid & Health',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'bandages',
      },
      {
        'id': 'first_aid_health_03',
        'question':
            'Why should essential medicines be included in an emergency kit?',
        'options': [
          'For decoration',
          'To maintain necessary treatment when normal access is disrupted',
          'To share randomly with everyone',
          'Because medicine never expires',
        ],
        'answer':
            'To maintain necessary treatment when normal access is disrupted',
        'category': 'First Aid & Health',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'essential_medicines',
      },
      {
        'id': 'first_aid_health_04',
        'question':
            'Why is mental health important during disasters?',
        'options': [
          'To avoid talking',
          'To pass time',
          'To stay calm and make decisions',
          'It is not important',
        ],
        'answer': 'To stay calm and make decisions',
        'category': 'First Aid & Health',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'stress_relief_items',
      },
      {
        'id': 'first_aid_health_05',
        'question':
            'If an injured person is unconscious and not responding, what is the best action?',
        'options': [
          'Ignore them',
          'Seek emergency medical help immediately',
          'Give them solid food',
          'Make them stand up',
        ],
        'answer': 'Seek emergency medical help immediately',
        'category': 'First Aid & Health',
        'difficulty': 'Advanced',
        'xp': 20,
        'kitItemId': 'medical_emergency',
      },
    ],

    // ==========================================================
    // 4. DISASTER RESPONSE
    // ==========================================================
    'disaster_response': [
      {
        'id': 'disaster_response_01',
        'question':
            'During an earthquake indoors, what is the recommended immediate action?',
        'options': [
          'Run toward windows',
          'Drop, cover and hold on',
          'Use the elevator',
          'Stand under a ceiling fan',
        ],
        'answer': 'Drop, cover and hold on',
        'category': 'Disaster Response',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'earthquake_safety',
      },
      {
        'id': 'disaster_response_02',
        'question':
            'What should you generally avoid doing during a flood?',
        'options': [
          'Listening to official warnings',
          'Moving to higher ground',
          'Walking or driving through moving floodwater',
          'Preparing emergency supplies',
        ],
        'answer': 'Walking or driving through moving floodwater',
        'category': 'Disaster Response',
        'difficulty': 'Basic',
        'xp': 10,
        'kitItemId': 'flood_safety',
      },
      {
        'id': 'disaster_response_03',
        'question':
            'If you smell gas after an earthquake, what should you avoid?',
        'options': [
          'Leaving the area',
          'Reporting the suspected leak',
          'Using flames or electrical switches nearby',
          'Following safety instructions',
        ],
        'answer': 'Using flames or electrical switches nearby',
        'category': 'Disaster Response',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'gas_safety',
      },
      {
        'id': 'disaster_response_04',
        'question':
            'When a severe weather warning is issued, what should you do?',
        'options': [
          'Monitor trusted alerts and follow official guidance',
          'Ignore all warnings',
          'Travel toward the affected area',
          'Depend only on rumours',
        ],
        'answer': 'Monitor trusted alerts and follow official guidance',
        'category': 'Disaster Response',
        'difficulty': 'Intermediate',
        'xp': 15,
        'kitItemId': 'weather_radio',
      },
      {
        'id': 'disaster_response_05',
        'question':
            'After a disaster, when should you return to an evacuated area?',
        'options': [
          'As soon as you want',
          'When authorities say it is safe to return',
          'Immediately after the warning starts',
          'Before emergency teams arrive',
        ],
        'answer': 'When authorities say it is safe to return',
        'category': 'Disaster Response',
        'difficulty': 'Advanced',
        'xp': 20,
        'kitItemId': 'return_safety',
      },
    ],
  };

  // ============================================================
  // SEED ALL
  // ============================================================

  Future<void> _seedAllQuizData() async {
    if (_loading) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _status = 'ERROR: Please login before seeding data.';
      });

      _showMessage(
        'Login Required',
        'You must be logged in before using the seeder.',
        error: true,
      );

      return;
    }

    setState(() {
      _loading = true;
      _status = 'Preparing quiz data...';
    });

    try {
      int totalWritten = 0;

      for (final categoryEntry in _quizData.entries) {
        final categoryId = categoryEntry.key;
        final questions = categoryEntry.value;

        setState(() {
          _status = 'Seeding $categoryId...';
        });

        // Firestore batch limit is much larger than our five questions,
        // so one batch per category is more than enough.
        final batch = _firestore.batch();

        for (final question in questions) {
          final questionId = question['id'] as String;

          final ref = _firestore
              .collection('quizzes')
              .doc(categoryId)
              .collection('questions')
              .doc(questionId);

          final data = <String, dynamic>{
            'question': question['question'],
            'options': List<String>.from(question['options'] as List),
            'answer': question['answer'],
            'category': question['category'],
            'difficulty': question['difficulty'],
            'xp': question['xp'],
            'kitItemId': question['kitItemId'],
            'createdAt': FieldValue.serverTimestamp(),
          };

          batch.set(ref, data);

          totalWritten++;
        }

        await batch.commit();
      }

      setState(() {
        _status =
            'SUCCESS: $totalWritten quiz questions seeded successfully.';
      });

      _showMessage(
        'Seed Complete',
        '$totalWritten quiz questions were added successfully.',
      );
    } on FirebaseException catch (e) {
      setState(() {
        _status = 'Firebase error: ${e.code}\n${e.message ?? ''}';
      });

      _showMessage(
        'Firebase Error',
        '${e.code}\n${e.message ?? ''}',
        error: true,
      );
    } catch (e) {
      setState(() {
        _status = 'ERROR: $e';
      });

      _showMessage(
        'Seed Error',
        e.toString(),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // VERIFY SEEDED DATA
  // ============================================================

  Future<void> _verifyQuizData() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _status = 'Verifying Firestore quiz data...';
    });

    try {
      final snap = await _firestore.collectionGroup('questions').get();

      final docs = snap.docs;

      final categories = <String, int>{};

      int totalXP = 0;

      for (final doc in docs) {
        final data = doc.data();

        final category = data['category']?.toString() ?? 'Unknown';

        categories[category] = (categories[category] ?? 0) + 1;

        final xp = data['xp'];

        if (xp is int) {
          totalXP += xp;
        }
      }

      final buffer = StringBuffer();

      buffer.writeln('Total questions: ${docs.length}');
      buffer.writeln('Total available XP: $totalXP');
      buffer.writeln('');

      final sorted = categories.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final entry in sorted) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }

      setState(() {
        _status = buffer.toString();
      });
    } on FirebaseException catch (e) {
      setState(() {
        _status = 'Firebase error: ${e.code}\n${e.message ?? ''}';
      });
    } catch (e) {
      setState(() {
        _status = 'Verification error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE ONLY DATA CREATED BY THIS SEEDER
  // ============================================================

  Future<void> _deleteSeededQuizData() async {
    if (_loading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete seeded quiz data?'),
          content: const Text(
            'This deletes only the 20 deterministic quiz documents created '
            'by this seed screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _status = 'Deleting seeded quiz data...';
    });

    try {
      int deleted = 0;

      for (final categoryEntry in _quizData.entries) {
        final categoryId = categoryEntry.key;
        final questions = categoryEntry.value;

        final batch = _firestore.batch();

        for (final question in questions) {
          final questionId = question['id'] as String;

          final ref = _firestore
              .collection('quizzes')
              .doc(categoryId)
              .collection('questions')
              .doc(questionId);

          batch.delete(ref);

          deleted++;
        }

        await batch.commit();
      }

      setState(() {
        _status = 'Deleted $deleted seeded questions.';
      });

      _showMessage(
        'Deleted',
        '$deleted seeded quiz documents removed.',
      );
    } catch (e) {
      setState(() {
        _status = 'Delete error: $e';
      });

      _showMessage(
        'Delete Error',
        e.toString(),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  void _showMessage(
    String title,
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = _quizData.values.fold<int>(
      0,
      (total, questions) => total + questions.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Quiz Seeder'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DisasterAid Quiz Data Seeder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_quizData.length} categories • '
                      '$totalQuestions questions',
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This screen is temporary. Remove it after Firestore '
                      'data has been seeded and verified.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ..._quizData.entries.map(
              (entry) => Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz_outlined),
                  title: Text(entry.value.first['category'].toString()),
                  subtitle: Text(
                    '${entry.value.length} questions • ${entry.key}',
                  ),
                  trailing: const Icon(Icons.check_circle_outline),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _seedAllQuizData,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: const Text(
                  'SEED ALL QUIZ DATA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _verifyQuizData,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('VERIFY FIRESTORE DATA'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _deleteSeededQuizData,
                icon: const Icon(Icons.delete_outline),
                label: const Text('DELETE SEEDED DATA'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(_status),
            ),

            const SizedBox(height: 30),

            const Text(
              'Expected after seeding:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const SelectableText(
              'quizzes/emergency_basics/questions/*\n'
              'quizzes/food_water_safety/questions/*\n'
              'quizzes/first_aid_health/questions/*\n'
              'quizzes/disaster_response/questions/*',
            ),
          ],
        ),
      ),
    );
  }
}