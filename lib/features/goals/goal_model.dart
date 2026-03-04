class GoalModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final int targetAmount;
  final int savedAmount;
  final DateTime deadline;
  final int monthlyContribution;
  final String priority;
  final String? notes;
  final String? emoji;
  final bool isCompleted;
  final String syncStatus;
  final DateTime updatedAt;
  final bool isDeleted;

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.deadline,
    this.monthlyContribution = 0,
    this.priority = 'medium',
    this.notes,
    this.emoji,
    this.isCompleted = false,
    this.syncStatus = 'pending',
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': deadline.millisecondsSinceEpoch,
      'monthlyContribution': monthlyContribution,
      'priority': priority,
      'notes': notes,
      'emoji': emoji,
      'isCompleted': isCompleted ? 1 : 0,
      'syncStatus': syncStatus,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      category: map['category'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
      monthlyContribution: map['monthlyContribution'],
      priority: map['priority'],
      notes: map['notes'],
      emoji: map['emoji'],
      isCompleted: map['isCompleted'] == 1,
      syncStatus: map['syncStatus'],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isDeleted: map['isDeleted'] == 1,
    );
  }

  double get progress => targetAmount > 0 ? savedAmount / targetAmount : 0;
  int get remainingAmount => targetAmount - savedAmount;
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;
}
