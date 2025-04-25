import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:book_tracker/services/firebase_options.dart';

/// A service class that provides Firebase authentication functionality
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '248380538875-h2rn06emgath2ce3015t2vfac7kn9p99.apps.googleusercontent.com' : null,
    scopes: ['email'],
  );

  /// Initialize Firebase app
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Set Firestore settings for better performance
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register a new user with email and password
  static Future<UserCredential?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      // Create the user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Add user data to Firestore
      if (userCredential.user != null) {
        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': name,
            'email': email,
            'created_at': Timestamp.now(),
          });
          
          // Update user profile with display name
          await userCredential.user!.updateDisplayName(name);
        } catch (firestoreError) {
          debugPrint('Firestore error during user creation: $firestoreError');
          // Continue even if Firestore fails - at least the auth account is created
        }
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google account
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web platform uses a different authentication process
        // Web implementation can use popup flow instead of redirects
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        
        UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        
        // Check if it's a new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          try {
            // Add user data to Firestore
            await _firestore.collection('users').doc(userCredential.user!.uid).set({
              'name': userCredential.user!.displayName,
              'email': userCredential.user!.email,
              'created_at': Timestamp.now(),
              'photo_url': userCredential.user!.photoURL,
            });
          } catch (firestoreError) {
            debugPrint('Firestore error during Google sign-in: $firestoreError');
            // Continue even if Firestore fails
          }
        }
        
        return userCredential;
      } else {
        // Begin interactive sign-in process for mobile/desktop
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google sign in was canceled');
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with credential
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        // Check if it's a new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          try {
            // Add user data to Firestore
            await _firestore.collection('users').doc(userCredential.user!.uid).set({
              'name': userCredential.user!.displayName,
              'email': userCredential.user!.email,
              'created_at': Timestamp.now(),
              'photo_url': userCredential.user!.photoURL,
            });
          } catch (firestoreError) {
            debugPrint('Firestore error during Google sign-in: $firestoreError');
            // Continue even if Firestore fails
          }
        }
        
        return userCredential;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
  
  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// Get the current logged in user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Handle Firebase Auth Exceptions
  static Exception _handleAuthException(FirebaseAuthException e) {
    debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'invalid-email':
        return Exception('Email address is invalid.');
      case 'account-exists-with-different-credential':
        return Exception('An account already exists with the same email address but different sign-in credentials.');
      case 'invalid-credential':
        return Exception('The credential is malformed or has expired.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'requires-recent-login':
        return Exception('Please sign in again to complete this operation.');
      default:
        return Exception(e.message ?? 'An error occurred during authentication.');
    }
  }
}
