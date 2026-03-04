class UserModel {
  final String id;
  final String name;
  final String email;
  final String currency;
  final String? financialPersonality;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    this.financialPersonality,
    required this.createdAt,
    this.lastSyncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
      'financialPersonality': financialPersonality,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSyncedAt': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      currency: map['currency'],
      financialPersonality: map['financialPersonality'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastSyncedAt: map['lastSyncedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncedAt']) 
          : null,
    );
  }
}
