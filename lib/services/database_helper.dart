import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wealthwise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';
    const integerType = 'INTEGER NOT NULL';
    const idType = 'TEXT PRIMARY KEY';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        currency $textType DEFAULT 'KES',
        financialPersonality TEXT,
        createdAt $integerType,
        lastSyncedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        userId $textType,
        type $textType,
        amount $integerType,
        category $textType,
        merchantName TEXT,
        paymentMethod $textType,
        notes TEXT,
        receiptImagePath TEXT,
        receiptFirebaseUrl TEXT,
        date $integerType,
        isRecurring $boolType,
        recurringFrequency TEXT,
        syncStatus $textType DEFAULT 'pending',
        updatedAt $integerType,
        isDeleted $boolType,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id $idType,
        userId $textType,
        name $textType,
        category $textType,
        targetAmount $integerType,
        savedAmount $integerType DEFAULT 0,
        deadline $integerType,
        monthlyContribution $integerType DEFAULT 0,
        priority $textType DEFAULT 'medium',
        notes TEXT,
        emoji TEXT,
        isCompleted $boolType,
        syncStatus $textType DEFAULT 'pending',
        updatedAt $integerType,
        isDeleted $boolType,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_contributions (
        id $idType,
        goalId $textType,
        amount $integerType,
        date $integerType,
        notes TEXT,
        syncStatus $textType DEFAULT 'pending',
        updatedAt $integerType,
        isDeleted $boolType,
        FOREIGN KEY (goalId) REFERENCES goals(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id $idType,
        entityType $textType,
        entityId $textType,
        operation $textType,
        payload $textType,
        attempts $integerType DEFAULT 0,
        createdAt $integerType,
        lastAttemptAt INTEGER,
        errorMessage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ai_insights_cache (
        id $idType,
        userId $textType,
        month $textType,
        reportJson $textType,
        generatedAt $integerType,
        syncStatus $textType DEFAULT 'pending'
      )
    ''');

    // Create Indexes
    await db.execute('CREATE INDEX idx_transactions_userId_date ON transactions(userId, date)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_transactions_category ON transactions(category)');
    await db.execute('CREATE INDEX idx_transactions_syncStatus ON transactions(syncStatus)');
    await db.execute('CREATE INDEX idx_goals_userId ON goals(userId)');
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(attempts, createdAt)');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
