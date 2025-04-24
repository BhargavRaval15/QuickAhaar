import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quick_ahaar/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isEmailVerified = false;
  bool _isAdmin = false;
  bool _isLoading = false;

  User? get currentUser => _user;
  bool get isEmailVerified => _isEmailVerified;
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  User? get user => _user;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isEmailVerified = user?.emailVerified ?? false;
      if (user != null) {
        _checkAdminStatus();
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkAdminStatus() async {
    if (_user == null) {
      _isAdmin = false;
      notifyListeners();
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      _isAdmin = userDoc.data()?['isAdmin'] ?? false;
      print('Admin status checked for ${_user!.email}: $_isAdmin');
      notifyListeners();
    } catch (e) {
      print('Error checking admin status: $e');
      _isAdmin = false;
      notifyListeners();
    }
  }

  Future<bool> checkAndUpdateAdminStatus() async {
    await _checkAdminStatus();
    return _isAdmin;
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential == null) {
        throw 'Invalid email or password';
      }

      _user = userCredential.user;
      await _checkAdminStatus();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential == null) {
        throw 'Failed to register user';
      }

      _user = userCredential.user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> sendEmailOTP(String email) async {
    await _authService.sendEmailOTP(email);
  }

  Future<void> sendPhoneOTP(String phoneNumber) async {
    await _authService.sendPhoneOTP(phoneNumber);
  }

  Future<void> verifyPhoneOTP(String verificationId, String smsCode) async {
    await _authService.verifyPhoneOTP(verificationId, smsCode);
  }

  Future<void> resendEmailVerification() async {
    await _authService.resendEmailVerification();
  }

  Future<void> createAdminUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating admin user: $e');
      rethrow;
    }
  }
} 