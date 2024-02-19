import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/authorize/data/firebase_auth_instance_provider.dart';

class FirebaseAuthRepository {
  FirebaseAuthRepository(this._firebaseAuth) {
    uid = _firebaseAuth.currentUser?.uid;
    displayName = _firebaseAuth.currentUser?.displayName;
  }

  final FirebaseAuth _firebaseAuth;
  late final String? uid;
  late final String? displayName;

  /// get user stream
  Stream<User?> getUserStream() {
    return _firebaseAuth.authStateChanges();
  }
}

final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthInstanceProvider));
});
