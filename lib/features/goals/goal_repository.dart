import 'dart:async';
import 'package:wealthwise/features/goals/goal_model.dart';
import 'package:wealthwise/features/goals/goal_contribution_model.dart';
import 'package:wealthwise/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class GoalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _goalController = StreamController<List<GoalModel>>.broadcast();

  Stream<List<GoalModel>> get goalsStream => _goalController.stream;

  Future<void> addGoal(GoalModel goal) async {
    final db = await _dbHelper.database;
    await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await refreshGoals(goal.userId);
  }

  Future<void> refreshGoals(String userId) async {
    final goals = await getGoals(userId);
    _goalController.add(goals);
  }

  Future<List<GoalModel>> getGoals(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );

    return List.generate(maps.length, (i) => GoalModel.fromMap(maps[i]));
  }

  Future<void> addContribution(GoalContributionModel contribution, String userId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('goal_contributions', contribution.toMap());
      
      // Update goal's savedAmount
      await txn.rawUpdate('''
        UPDATE goals SET savedAmount = savedAmount + ?, updatedAt = ? 
        WHERE id = ?
      ''', [contribution.amount, DateTime.now().millisecondsSinceEpoch, contribution.goalId]);
    });
    await refreshGoals(userId);
  }

  Future<List<GoalContributionModel>> getContributions(String goalId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goal_contributions',
      where: 'goalId = ? AND isDeleted = 0',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => GoalContributionModel.fromMap(maps[i]));
  }
}
