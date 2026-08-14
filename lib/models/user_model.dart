/// Model representing an application user profile.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? emergencyContact;
  final String? bloodGroup;
  final String? profileImage;
  final bool isProfileComplete;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.emergencyContact,
    this.bloodGroup,
    this.profileImage,
    required this.isProfileComplete,
    required this.createdAt,
  });

  /// Converts the user model to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "phone": phone,
      "emergencyContact": emergencyContact,
      "bloodGroup": bloodGroup,
      "profileImage": profileImage,
      "isProfileComplete": isProfileComplete,
      "createdAt": createdAt,
    };
  }

  /// Creates a UserModel from Firestore data.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final raw = map["createdAt"];

    DateTime created;
    if (raw is DateTime) {
      created = raw;
    } else if (raw is String) {
      created = DateTime.parse(raw);
    } else {
      created = raw.toDate();
    }

    return UserModel(
      id: map["id"] ?? "",
      email: map["email"] ?? "",
      name: map["name"] ?? "",
      phone: map["phone"],
      emergencyContact: map["emergencyContact"],
      bloodGroup: map["bloodGroup"],
      profileImage: map["profileImage"],
      isProfileComplete: map["isProfileComplete"] == true,
      createdAt: created,
    );
  }
}