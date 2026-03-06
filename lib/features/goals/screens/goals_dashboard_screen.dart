import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/goals/goal_model.dart';
import 'package:wealthwise/core/widgets/guest_prompt.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';
import 'package:wealthwise/features/goals/goal_provider.dart';

class GoalsDashboardScreen extends ConsumerWidget {
  const GoalsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryNavy,
        body: GuestPrompt(
          title: 'Unlock Goals',
          message:
              'Sign in to create personal financial goals and track your progress across all your devices.',
          icon: Icons.track_changes_rounded,
        ),
      );
    }

    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Financial Goals',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppTheme.accentEmerald),
            onPressed: () => context.push('/add-goal'),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) return _buildEmptyState(context);
          return _buildGoalsList(context, goals);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(
            child:
                Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.track_changes_rounded,
              size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 24),
          const Text('No goals set yet',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 12),
          const Text('Start by creating your first savings goal',
              style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/add-goal'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentEmerald),
            child: const Text('Add My First Goal',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, List<GoalModel> goals) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(context, goal);
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final formatter = NumberFormat.compactCurrency(symbol: 'KES ');
    final progress = goal.progress;

    return GestureDetector(
      onTap: () => context.push('/goals/detail', extra: goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppTheme.secondaryNavy,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(goal.emoji ?? '🎯',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(goal.category,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: _getPriorityColor(goal.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(goal.priority.toUpperCase(),
                      style: TextStyle(
                          color: _getPriorityColor(goal.priority),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearPercentIndicator(
              lineHeight: 12,
              percent: progress,
              backgroundColor: AppTheme.primaryNavy,
              progressColor: AppTheme.accentEmerald,
              barRadius: const Radius.circular(6),
              animation: true,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toInt()}% Done',
                    style: const TextStyle(
                        color: AppTheme.accentEmerald,
                        fontWeight: FontWeight.bold)),
                Text('Target: ${formatter.format(goal.targetAmount / 100)}',
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalStats(goal),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStats(GoalModel goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMiniStat('Days Left', goal.daysRemaining.toString()),
        _buildMiniStat(
            'Remaining',
            NumberFormat.compactCurrency(symbol: 'KES ')
                .format(goal.remainingAmount / 100)),
        _buildMiniStat(
            'Saved',
            NumberFormat.compactCurrency(symbol: 'KES ')
                .format(goal.savedAmount / 100)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.accentCoral;
      case 'medium':
        return AppTheme.accentGold;
      default:
        return AppTheme.accentEmerald;
    }
  }
}
