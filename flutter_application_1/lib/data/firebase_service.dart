import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class FirebaseService {
  final firebase_auth.FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '210015995030-atj2q5gduj3ge8vlm9sp0j5e56k977kc.apps.googleusercontent.com'
        : null,
    serverClientId:
        '210015995030-atj2q5gduj3ge8vlm9sp0j5e56k977kc.apps.googleusercontent.com',
    scopes: ['email'],
  );

  FirebaseService()
    : _auth = Firebase.apps.isNotEmpty
          ? firebase_auth.FirebaseAuth.instance
          : null,
      _firestore = Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
      _storage = Firebase.apps.isNotEmpty ? FirebaseStorage.instance : null;

  // --- Authentication ---

  // Listen to auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  // Get current user ID
  String? get currentUserId => _auth?.currentUser?.uid;

  // Sign In Anonymously (for demo purposes)
  Future<User?> signInAnonymously() async {
    if (_auth == null) return null;
    try {
      final userCredential = await _auth.signInAnonymously();
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final user = User(
          id: firebaseUser.uid,
          name: 'زائر',
          phone: '',
          email: '',
          password: '',
          gender: 'غير محدد',
          role: 'doctor',
        );
        await saveUserData(user);
        return user;
      }
    } catch (e) {
      print('Failed to sign in anonymously: \$e');
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    if (_auth == null) return;
    await _auth.signOut();
  }

  // Sign Up with Email
  Future<User?> signUpWithEmail(
    String email,
    String password,
    User userData,
  ) async {
    if (_auth == null) return null;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        userData.id = firebaseUser.uid;
        await saveUserData(userData);
        return userData;
      }
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
    return null;
  }

  // Sign Up as Doctor
  Future<User?> signUpAsDoctor(
    String email,
    String password,
    User userData,
  ) async {
    final doctorUser = User(
      id: userData.id,
      name: userData.name,
      phone: userData.phone,
      email: userData.email,
      password: userData.password,
      gender: userData.gender,
      role: 'doctor',
      hospitalId: userData.hospitalId,
    );
    return signUpWithEmail(email, password, doctorUser);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      print(
        'Firebase Auth is not initialized. Could not send password reset email.',
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Failed to send password reset email to $email: $e');
    }
  }

  Future<void> saveDoctorProfile(Doctor doctor) async {
    if (_firestore == null) return;
    await _firestore
        .collection('doctors')
        .doc(doctor.id)
        .set(doctor.toMap(), SetOptions(merge: true));
  }

  // Login with Email
  Future<User?> loginWithEmail(String email, String password) async {
    if (_auth == null) return null;
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // try to load the user document from Firestore
        User? user = await getUserData(firebaseUser.uid);
        if (user != null) {
          return user;
        }

        // if there is no document yet (e.g. user created directly in console),
        // create a minimal record so the rest of the app can work normally.
        final newUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          email: firebaseUser.email ?? email,
          password: '', // we never store plaintext passwords
          gender: 'غير محدد',
        );
        await saveUserData(newUser);
        return newUser;
      }
    } catch (e) {
      // keep the print for debugging but also rethrow so callers can inspect
      print('Login Error: $e');
      rethrow;
    }
    return null;
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    if (_auth == null) {
      // Simulate Google Sign-In for UI demonstration when Firebase is not connected
      await Future.delayed(
        const Duration(seconds: 1),
      ); // simulate network delay
      final simulatedUser = User(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        name: 'د. حساب جوجل',
        phone: '',
        email: 'doctor@gmail.com',
        password: '',
        gender: 'غير محدد',
        role: 'doctor', // default to doctor to test banner features
      );
      await saveUserData(simulatedUser);
      return simulatedUser;
    }

    try {
      firebase_auth.UserCredential userCredential;
      String? fallbackEmail;
      String? fallbackName;

      if (kIsWeb) {
        // Native Firebase Auth Web Popup - Completely avoids People API!
        final googleProvider = firebase_auth.GoogleAuthProvider();
        googleProvider.addScope('email');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Trigger mobile GoogleSignIn
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null; // The user canceled the sign-in
        }

        fallbackEmail = googleUser.email;
        fallbackName = googleUser.displayName;

        // Obtain auth details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create credential
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final realEmail = (firebaseUser.email != null && firebaseUser.email!.isNotEmpty)
            ? firebaseUser.email!
            : (fallbackEmail ?? '');
        final realName = (firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty)
            ? firebaseUser.displayName!
            : (fallbackName != null && fallbackName.isNotEmpty
                ? fallbackName
                : (realEmail.contains('@') ? realEmail.split('@').first : 'مستخدم جوجل'));
        final realPhone = firebaseUser.phoneNumber ?? '';

        User user = User(
          id: firebaseUser.uid,
          name: realName,
          phone: realPhone,
          email: realEmail,
          password: '',
          gender: 'غير محدد',
          role: 'patient',
        );

        // Check if user exists in Firestore
        try {
          User? existingUser = await getUserData(firebaseUser.uid);
          if (existingUser != null) {
            user = User(
              id: existingUser.id,
              name: existingUser.name.isNotEmpty ? existingUser.name : realName,
              phone: existingUser.phone.isNotEmpty ? existingUser.phone : realPhone,
              email: realEmail,
              password: existingUser.password,
              gender: existingUser.gender,
              role: existingUser.role,
              hospitalId: existingUser.hospitalId,
              isProfileComplete: existingUser.isProfileComplete,
            );
          }
          await saveUserData(user);
        } catch (e) {
          print('Warning syncing user with Firestore: $e');
        }

        return user;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
    return null;
  }

  // --- Firestore Data Operations ---

  // Save User Data to Firestore
  Future<void> saveUserData(User user) async {
    if (_firestore == null) return;
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  // Get User Data from Firestore
  Future<User?> getUserData(String uid) async {
    if (_firestore == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  // Save/Book an Appointment
  Future<void> bookAppointment(Appointment appointment) async {
    if (_firestore == null) return;
    // Generate an ID if needed
    final docRef = _firestore.collection('appointments').doc(appointment.id);
    await docRef.set(appointment.toMap());
  }

  // Check if doctor slot is already booked by another appointment
  Future<bool> isDoctorSlotAvailable({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    if (_firestore == null) return true;
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorName', isEqualTo: doctorName)
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('status', whereIn: ['قادم', 'بانتظار تأكيد الطبيب'])
        .limit(1)
        .get();

    return snapshot.docs.isEmpty;
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    if (_firestore == null) return;
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  // Listen to Appointments (Real-time Stream)
  Stream<List<Appointment>> getUserAppointments(String userId) {
    if (_firestore == null) return const Stream.empty();
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Appointment.fromMap(doc.data()))
              .toList();
        });
  }

  // Cancel an Appointment
  Future<void> cancelAppointment(String appointmentId) async {
    if (_firestore == null) return;
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }

  // Upload Image to Firebase Storage
  Future<String?> uploadImage(File file, String folder) async {
    if (_storage == null) return null;
    try {
      final ref = _storage.ref().child(
        '$folder/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  static User buildUserFromAuthProfile({
    required String uid,
    required String? displayName,
    required String? phoneNumber,
    required String? email,
    required String fallbackEmail,
  }) {
    return User(
      id: uid,
      name: displayName ?? '',
      phone: phoneNumber ?? '',
      email: (email == null || email.isEmpty) ? fallbackEmail : email,
      password: '',
      gender: 'غير محدد',
    );
  }
}
