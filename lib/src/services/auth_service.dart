import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'storage_service.dart';
import '../utils/utils.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  static const String _sessionActiveKey = 'firebase_session_active';
  static const String _sessionUserIdKey = 'firebase_session_user_id';
  static const String _sessionEmailKey = 'firebase_session_email';
  static const String _sessionNameKey = 'firebase_session_name';
  static const String _sessionPhotoUrlKey = 'firebase_session_photo_url';

  DatabaseReference get _usersRef => _database.ref('users');

  /// Stream of auth state changes. Emits the current user map or null.
  Stream<Map<String, dynamic>?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      final firebaseUser = _firebaseUserToMap(user);
      if (firebaseUser != null) {
        await _saveCachedSession(firebaseUser);
        return firebaseUser;
      }
      return _cachedSessionUser();
    });
  }

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _userToMapWithProfile(credential.user);
      await _saveCachedSession(user);
      return user;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      await user.updateDisplayName(name);
      await _usersRef.child(user.uid).child('profile').set({
        'id': user.uid,
        'name': name,
        'email': user.email ?? email,
        'photoUrl': user.photoURL,
        'createdAt': ServerValue.timestamp,
      });
      await user.reload();

      final sessionUser = await _userToMapWithProfile(_auth.currentUser);
      await _saveCachedSession(sessionUser);
      return sessionUser;
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _auth.sendPasswordResetEmail(email: email);
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _clearCachedSession();
      await _auth.signOut();
    });
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final firebaseUser = await _userToMapWithProfile(_auth.currentUser);
      if (firebaseUser != null) {
        await _saveCachedSession(firebaseUser);
        return firebaseUser;
      }
      return _cachedSessionUser();
    });
  }

  Future<Map<String, dynamic>?> _userToMapWithProfile(User? user) async {
    final firebaseUser = _firebaseUserToMap(user);
    if (user == null || firebaseUser == null) return null;

    try {
      final profileSnapshot = await _usersRef
          .child(user.uid)
          .child('profile')
          .get()
          .timeout(const Duration(seconds: 3));
      final profile = profileSnapshot.value is Map
          ? Map<String, dynamic>.from(profileSnapshot.value as Map)
          : <String, dynamic>{};

      return {
        ...firebaseUser,
        'name': firebaseUser['name'] ?? profile['name'],
        'photoUrl': firebaseUser['photoUrl'] ?? profile['photoUrl'],
      };
    } catch (_) {
      return firebaseUser;
    }
  }

  Map<String, dynamic>? _firebaseUserToMap(User? user) {
    if (user == null) return null;

    return {
      'id': user.uid,
      'email': user.email ?? '',
      'name': user.displayName,
      'photoUrl': user.photoURL,
    };
  }

  Map<String, dynamic>? _cachedSessionUser() {
    final isActive =
        StorageService.instance.getBool(_sessionActiveKey) ?? false;
    final id = StorageService.instance.getString(_sessionUserIdKey);
    if (!isActive || id == null || id.isEmpty) return null;

    return {
      'id': id,
      'email': StorageService.instance.getString(_sessionEmailKey) ?? '',
      'name': StorageService.instance.getString(_sessionNameKey),
      'photoUrl': StorageService.instance.getString(_sessionPhotoUrlKey),
    };
  }

  Future<void> _saveCachedSession(Map<String, dynamic>? user) async {
    if (user == null) return;

    await StorageService.instance.setBool(_sessionActiveKey, true);
    await StorageService.instance.setString(
      _sessionUserIdKey,
      user['id']?.toString() ?? '',
    );
    await StorageService.instance.setString(
      _sessionEmailKey,
      user['email']?.toString() ?? '',
    );

    final name = user['name']?.toString();
    if (name == null || name.isEmpty) {
      await StorageService.instance.remove(_sessionNameKey);
    } else {
      await StorageService.instance.setString(_sessionNameKey, name);
    }

    final photoUrl = user['photoUrl']?.toString();
    if (photoUrl == null || photoUrl.isEmpty) {
      await StorageService.instance.remove(_sessionPhotoUrlKey);
    } else {
      await StorageService.instance.setString(_sessionPhotoUrlKey, photoUrl);
    }
  }

  Future<void> _clearCachedSession() async {
    await StorageService.instance.remove(_sessionActiveKey);
    await StorageService.instance.remove(_sessionUserIdKey);
    await StorageService.instance.remove(_sessionEmailKey);
    await StorageService.instance.remove(_sessionNameKey);
    await StorageService.instance.remove(_sessionPhotoUrlKey);
  }
}
