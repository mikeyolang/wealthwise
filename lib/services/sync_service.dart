import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealthwise/services/database_helper.dart';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:wealthwise/features/goals/goal_model.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> syncAll(String userId) async {
    await syncTransactions(userId);
    await syncGoals(userId);
  }

  Future<void> syncTransactions(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> pending = await db.query(
      'transactions',
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, 'pending'],
    );

    for (var map in pending) {
      final tx = TransactionModel.fromMap(map);
      await _firestore.collection('users').doc(userId).collection('transactions').doc(tx.id).set(tx.toMap());
      await db.update('transactions', {'syncStatus': 'synced'}, where: 'id = ?', whereArgs: [tx.id]);
    }
  }

  Future<void> syncGoals(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> pending = await db.query(
      'goals',
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, 'pending'],
    );

    for (var map in pending) {
      final goal = GoalModel.fromMap(map);
      await _firestore.collection('users').doc(userId).collection('goals').doc(goal.id).set(goal.toMap());
      await db.update('goals', {'syncStatus': 'synced'}, where: 'id = ?', whereArgs: [goal.id]);
    }
  }
}
