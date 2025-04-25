import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_tracker/services/firebase_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class UserAuthProvider with ChangeNotifier {
  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _error;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  UserAuthProvider() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = firebaseUser;
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // Sign in with email and password
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      await FirebaseService.signInWithEmailPassword(email, password);
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      _setLoading(true);
      _error = null;
      await FirebaseService.signUpWithEmailPassword(email, password, name);
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _error = null;
      await FirebaseService.signInWithGoogle();
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await FirebaseService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      _error = null;
      await FirebaseService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
