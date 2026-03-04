class GoalContributionModel {
  final String id;
  final String goalId;
  final int amount;
  final DateTime date;
  final String? notes;
  final String syncStatus;
  final DateTime updatedAt;
  final bool isDeleted;

  GoalContributionModel({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.notes,
    this.syncStatus = 'pending',
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'syncStatus': syncStatus,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory GoalContributionModel.fromMap(Map<String, dynamic> map) {
    return GoalContributionModel(
      id: map['id'],
      goalId: map['goalId'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      notes: map['notes'],
      syncStatus: map['syncStatus'],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
