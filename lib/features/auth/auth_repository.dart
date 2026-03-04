import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:wealthwise/features/auth/user_model.dart';
import 'package:wealthwise/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) return null;

      final newUser = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        currency: 'KES',
        createdAt: DateTime.now(),
      );

      // Save to local DB
      await _saveUserLocally(newUser);
      
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) return null;

      // Try to get user from local DB first
      UserModel? user = await _getUserLocally(credential.user!.uid);
      
      if (user == null) {
        // If not in local DB (e.g., new device), we'll later fetch from Firestore
        // For now, return a placeholder or handle in SyncService
        user = UserModel(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: email,
          currency: 'KES',
          createdAt: DateTime.now(),
        );
        await _saveUserLocally(user);
      }
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> _saveUserLocally(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> _getUserLocally(String uid) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
}
