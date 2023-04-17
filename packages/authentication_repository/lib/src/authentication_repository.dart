import 'dart:convert';
import 'dart:developer';

import 'package:authentication_repository/src/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthenticationRepository {
  AuthenticationRepository({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;

  User _currentUser = User.empty;

  Stream<User> get userStream {
    return _firebaseAuth.authStateChanges().map(
          (firebaseUser) => _currentUser =
              firebaseUser == null ? User.empty : firebaseUser.toUser(),
        );
  }

  User get currentUser => _currentUser;

  Future<void> anonymousAuth() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'operation-not-allowed':
          log(
            "Anonymous auth hasn't been enabled for this project.",
            error: jsonEncode(e),
          );
          break;
        default:
          log(
            'Unknown auth error.',
            error: jsonEncode(e),
          );
      }
    }
  }
}

extension on firebase_auth.User {
  User toUser() => User(id: uid);
}
