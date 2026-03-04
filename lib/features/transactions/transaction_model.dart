enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount; // stored in cents
  final String category;
  final String? merchantName;
  final String paymentMethod;
  final String? notes;
  final String? receiptImagePath;
  final String? receiptFirebaseUrl;
  final DateTime date;
  final bool isRecurring;
  final String? recurringFrequency;
  final String syncStatus;
  final DateTime updatedAt;
  final bool isDeleted;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    this.merchantName,
    required this.paymentMethod,
    this.notes,
    this.receiptImagePath,
    this.receiptFirebaseUrl,
    required this.date,
    required this.isRecurring,
    this.recurringFrequency,
    this.syncStatus = 'pending',
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'category': category,
      'merchantName': merchantName,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'receiptImagePath': receiptImagePath,
      'receiptFirebaseUrl': receiptFirebaseUrl,
      'date': date.millisecondsSinceEpoch,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringFrequency': recurringFrequency,
      'syncStatus': syncStatus,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      type: TransactionType.values.byName(map['type']),
      amount: map['amount'],
      category: map['category'],
      merchantName: map['merchantName'],
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
      receiptImagePath: map['receiptImagePath'],
      receiptFirebaseUrl: map['receiptFirebaseUrl'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isRecurring: map['isRecurring'] == 1,
      recurringFrequency: map['recurringFrequency'],
      syncStatus: map['syncStatus'],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
