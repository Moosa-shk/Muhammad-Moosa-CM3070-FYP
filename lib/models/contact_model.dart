import 'package:hive/hive.dart';

part 'contact_model.g.dart';

/// Model representing an emergency contact stored locally using Hive.
@HiveType(typeId: 2)
class ContactModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String organization;

  ContactModel({
    required this.name,
    required this.phone,
    required this.organization,
  });

  /// Creates a ContactModel from a map (e.g., Firestore or JSON data).
  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      name: (map['name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      organization: (map['organization'] ?? '').toString(),
    );
  }

  /// Converts the contact model to a map for storage or transfer.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'organization': organization,
    };
  }
}