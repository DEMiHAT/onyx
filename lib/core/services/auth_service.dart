/// ONYX Auth Service — Firebase Authentication wrapper.
///
/// Manages sign-in, sign-up, auth state, and user profile sync.
/// Singleton pattern for global access across the app.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import 'notification_service.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? _user;
  UserRole _role = UserRole.guest;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  // ── Getters ──────────────────────────────────────────────────

  User? get user => _user;
  UserRole get role => _role;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get displayName => _profile?['name'] ?? _user?.displayName ?? 'User';
  String get email => _user?.email ?? '';
  String get uid => _user?.uid ?? '';

  // ── Initialize (call once at startup) ────────────────────────

  Future<void> initialize() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _loadProfile();
    }
    // Listen for auth state changes
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _loadProfile();
      } else {
        _profile = null;
        _role = UserRole.guest;
      }
      notifyListeners();
    });
  }

  // ── Sign In ──────────────────────────────────────────────────

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      await _loadProfile();

      // Subscribe to FCM topics for this role
      await NotificationService.instance.subscribeToRoleTopics(_role.name);

      _isLoading = false;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _mapAuthError(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    UserRole role = UserRole.guest,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;

      // Update display name
      await _user!.updateDisplayName(name);

      // Create Firestore profile
      await _db.collection('users').doc(_user!.uid).set({
        'name': name,
        'email': email.trim(),
        'phone': phone ?? '',
        'role': role.name,
        'level': 'beginner',
        'membershipType': null,
        'membershipStatus': null,
        'membershipExpiry': null,
        'totalSessions': 0,
        'totalHours': 0,
        'currentStreak': 0,
        'favoriteFacility': '',
        'mostActiveDay': '',
        'whatsappOptIn': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadProfile();
      await NotificationService.instance.subscribeToRoleTopics(_role.name);

      _isLoading = false;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _mapAuthError(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────

  Future<void> signOut() async {
    await NotificationService.instance.removeToken();
    await _auth.signOut();
    _user = null;
    _profile = null;
    _role = UserRole.guest;
    notifyListeners();
  }

  // ── Password Reset ───────────────────────────────────────────

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    }
  }

  // ── Profile Loading ──────────────────────────────────────────

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      final doc = await _db.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _profile = doc.data();
        _role = _parseRole(_profile?['role']);
      } else {
        // Profile doesn't exist yet — create a minimal one
        _profile = {'name': _user!.displayName ?? 'User', 'role': 'guest'};
        _role = UserRole.guest;
      }
    } catch (e) {
      debugPrint('[Auth] Profile load error: $e');
      _role = UserRole.guest;
    }
  }

  UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.guest;
    return UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.guest,
    );
  }

  // ── Error Mapping ────────────────────────────────────────────

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed ($code)';
    }
  }
}
