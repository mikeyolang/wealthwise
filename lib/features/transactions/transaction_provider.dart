import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:wealthwise/features/transactions/transaction_repository.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) => TransactionRepository());

final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(transactionRepositoryProvider).transactionsStream;
});

final monthlyStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'income': 0, 'expense': 0};
  
  final now = DateTime.now();
  return ref.watch(transactionRepositoryProvider).getMonthlyStats(user.id, now.month, now.year);
});
