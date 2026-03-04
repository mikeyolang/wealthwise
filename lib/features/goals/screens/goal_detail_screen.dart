import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/goals/goal_model.dart';
import 'package:wealthwise/features/goals/goal_provider.dart';
import 'package:wealthwise/features/goals/goal_contribution_model.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GoalDetailScreen extends ConsumerWidget {
  final GoalModel goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(goalContributionsProvider(goal.id));
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(goal.name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalSummary(context, goal),
            const SizedBox(height: 32),
            _buildSectionTitle('Contribution History'),
            const SizedBox(height: 16),
            contributionsAsync.when(
              data: (contributions) => _buildContributionList(context, contributions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Text('Error: $e', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContributionSheet(context, ref),
        backgroundColor: AppTheme.accentEmerald,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Savings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddContributionSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.secondaryNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Contribution', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textSecondary)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textSecondary)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final amountText = amountController.text.trim();
                  if (amountText.isEmpty) return;
                  
                  final amount = (double.parse(amountText) * 100).toInt();
                  final contribution = GoalContributionModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    goalId: goal.id,
                    amount: amount,
                    date: DateTime.now(),
                    notes: notesController.text.trim(),
                    updatedAt: DateTime.now(),
                  );

                  await ref.read(goalRepositoryProvider).addContribution(contribution, goal.userId);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentEmerald),
                child: const Text('Confirm Contribution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSummary(BuildContext context, GoalModel goal) {
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);
    final progress = goal.progress;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text(goal.emoji ?? '🎯', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            formatter.format(goal.savedAmount / 100),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            'Saved of ${formatter.format(goal.targetAmount / 100)}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            percent: progress,
            center: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(color: AppTheme.accentEmerald, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppTheme.primaryNavy,
            progressColor: AppTheme.accentEmerald,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ).animate().scale(delay: 200.ms),
          const SizedBox(height: 24),
          _buildDetailRow('Deadline', DateFormat('MMM d, yyyy').format(goal.deadline)),
          _buildDetailRow('Remaining', formatter.format(goal.remainingAmount / 100)),
          _buildDetailRow('Status', goal.isCompleted ? 'Completed' : 'In Progress', 
              color: goal.isCompleted ? AppTheme.accentEmerald : AppTheme.accentGold),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildContributionList(BuildContext context, List<GoalContributionModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text('No contributions yet', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Column(
      children: items.map((item) => _buildContributionItem(context, item)).toList(),
    );
  }

  Widget _buildContributionItem(BuildContext context, GoalContributionModel item) {
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.accentEmerald.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.add_chart_rounded, color: AppTheme.accentEmerald, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.notes ?? 'Monthly Saving', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM d, yyyy').format(item.date), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '+ ${formatter.format(item.amount / 100)}',
            style: const TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
