import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/features/goals/goal_model.dart';
import 'package:wealthwise/features/goals/goal_contribution_model.dart';
import 'package:wealthwise/features/goals/goal_repository.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) => GoalRepository());

final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(goalRepositoryProvider).goalsStream;
});

final goalContributionsProvider = FutureProvider.family<List<GoalContributionModel>, String>((ref, goalId) async {
  return ref.watch(goalRepositoryProvider).getContributions(goalId);
});
