import 'dart:async';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:wealthwise/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _controller = StreamController<List<TransactionModel>>.broadcast();

  Stream<List<TransactionModel>> get transactionsStream => _controller.stream;

  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await refreshTransactions(transaction.userId);
  }

  Future<void> refreshTransactions(String userId) async {
    final transactions = await getTransactions(userId);
    _controller.add(transactions);
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<Map<String, int>> getMonthlyStats(String userId, int month, int year) async {
    final db = await _dbHelper.database;
    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE userId = ? AND type = 'income' AND date >= ? AND date <= ? AND isDeleted = 0
    ''', [userId, startOfMonth, endOfMonth]);

    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE userId = ? AND type = 'expense' AND date >= ? AND date <= ? AND isDeleted = 0
    ''', [userId, startOfMonth, endOfMonth]);

    return {
      'income': (incomeResult.first['total'] as int?) ?? 0,
      'expense': (expenseResult.first['total'] as int?) ?? 0,
    };
  }

  Future<void> deleteTransaction(String id, String userId) async {
    final db = await _dbHelper.database;
    await db.update(
      'transactions',
      {'isDeleted': 1, 'syncStatus': 'pending', 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
    await refreshTransactions(userId);
  }
}
