// ===============================================================
// AuthController
// ---------------------------------------------------------------
// This controller manages authentication logic for the application.
// It handles user registration, login, profile updates, and logout.
// Firebase Authentication is used for user authentication,
// while Firestore stores additional user profile information.
// GetX is used for state management to keep the user data reactive.
// ===============================================================

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../models/user_model.dart';
import '../../services/cloudinary_service.dart';
import '../../services/notification_service.dart';

class AuthController extends GetxController {
  /// Provides quick global access to this controller using GetX
  static AuthController get to => Get.find();

  /// Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore database instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reactive variable that stores the currently logged-in user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // ===============================================================
  // onReady()
  // ---------------------------------------------------------------
  // This lifecycle method runs when the controller becomes ready.
  // It listens to authentication state changes and synchronizes
  // the user information with Firestore.
  // ===============================================================

  @override
  void onReady() {
    super.onReady();

    // Listen to Firebase authentication state changes
    _auth.userChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        // If the user logs out, clear the current user
        currentUser.value = null;
        return;
      }

      try {
        // Refresh Firebase user session
        await firebaseUser.reload();
        final refreshed = _auth.currentUser;

        if (refreshed == null) {
          currentUser.value = null;
          return;
        }

        // Fetch user profile data from Firestore
        final doc = await _db.collection("users").doc(refreshed.uid).get();

        if (!doc.exists) return;

        // Convert Firestore data into UserModel
        currentUser.value = UserModel.fromMap(doc.data()!);
      } catch (e) {
        // Log error for debugging purposes
        // ignore: avoid_print
        print("AuthController user load error: $e");
      }
    });
  }

  // ===============================================================
  // registerFull()
  // ---------------------------------------------------------------
  // Handles full user registration including:
  // 1. Firebase authentication account creation
  // 2. Uploading profile image (optional)
  // 3. Storing additional profile data in Firestore
  // 4. Triggering a welcome notification
  // ===============================================================

  Future<String?> registerFull({
    required String email,
    required String password,
    required String name,
    required String? phone,
    required String? emergency,
    required String? bloodGroup,
    File? profileFile,
  }) async {
    try {
      // Create user using Firebase Authentication
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload profile image if provided
      String? finalImage;
      if (profileFile != null) {
        finalImage = await CloudinaryService.uploadImageUnsigned(profileFile);
      }

      // Create user model
      final user = UserModel(
        id: cred.user!.uid,
        email: email,
        name: name,
        phone: phone,
        emergencyContact: emergency,
        bloodGroup: bloodGroup,
        profileImage: finalImage,
        isProfileComplete: true,
        createdAt: DateTime.now(),
      );

      // Store user profile in Firestore
      await _db.collection("users").doc(user.id).set(user.toMap());

      // Update reactive user state
      currentUser.value = user;

      // Show welcome notification after signup
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        await LocalNotificationService.showSignupWelcome(user.name);
      });

      return null;
    } on FirebaseAuthException catch (e) {
      // Return authentication error message
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ===============================================================
  // login()
  // ---------------------------------------------------------------
  // Authenticates a user using email and password.
  // After successful login, the system retrieves the user's
  // name from Firestore and displays a welcome notification.
  // ===============================================================

  Future<String?> login(String email, String password) async {
    try {
      // Authenticate user
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      String displayName = email;

      // Retrieve user name from Firestore if available
      if (uid != null) {
        final doc = await _db.collection("users").doc(uid).get();
        final data = doc.data();

        if (data != null &&
            (data["name"] is String) &&
            (data["name"] as String).trim().isNotEmpty) {
          displayName = data["name"] as String;
        }
      }

      // Show login notification
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 400));
        await LocalNotificationService.showLoginWelcome(displayName);
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ===============================================================
  // updateProfileSafe()
  // ---------------------------------------------------------------
  // Updates user profile information stored in Firestore.
  // Only provided fields are updated to prevent overwriting
  // existing values with null.
  // ===============================================================

  Future<String?> updateProfileSafe({
    required String name,
    String? phone,
    String? emergencyContact,
    String? bloodGroup,
    String? profileImage,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) return "User not logged in";

      // Prepare update data
      final data = <String, dynamic>{
        "name": name,
        "phone": phone,
        "emergencyContact": emergencyContact,
        "bloodGroup": bloodGroup,
        "profileImage": profileImage,
      }..removeWhere((_, v) => v == null);

      // Update Firestore document
      await _db.collection("users").doc(uid).update(data);

      // Update local reactive user state
      final existing = currentUser.value;

      if (existing != null) {
        currentUser.value = UserModel.fromMap({
          ...existing.toMap(),
          ...data,
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ===============================================================
  // logout()
  // ---------------------------------------------------------------
  // Signs the user out from Firebase Authentication
  // and clears the locally stored user data.
  // ===============================================================

  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
  }
}