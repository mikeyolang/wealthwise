import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';
import 'package:wealthwise/features/transactions/transaction_provider.dart';
import 'package:wealthwise/features/analytics/providers/analytics_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(monthlyStatsProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final dailyTipAsync = ref.watch(dailyTipProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user?.name ?? 'User'),
              const SizedBox(height: 24),
              _buildDailyTip(context, dailyTipAsync),
              const SizedBox(height: 24),
              statsAsync.when(
                data: (stats) => _buildNetBalanceCard(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, __) => Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              statsAsync.when(
                data: (stats) => _buildQuickStatsRow(context, stats),
                loading: () => const SizedBox(),
                error: (e, __) => const SizedBox(),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Spending Breakdown'),
              const SizedBox(height: 16),
              _buildSpendingPieChart(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Recent Transactions'),
              const SizedBox(height: 16),
              transactionsAsync.when(
                data: (transactions) => _buildRecentTransactions(
                  context,
                  transactions.take(5).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, __) => Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction?type=expense'),
        backgroundColor: AppTheme.accentEmerald,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDailyTip(BuildContext context, AsyncValue<String> tipAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: tipAsync.when(
              data: (tip) => Text(
                tip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              loading: () => const Text(
                'Generating daily tip...',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              error: (_, __) => const Text(
                'Save 10% of every income to build wealth.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildHeader(BuildContext context, String name) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, $name 👋',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatter.format(now),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppTheme.secondaryNavy,
          child: const Icon(Icons.person, color: AppTheme.accentEmerald),
        ),
      ],
    );
  }

  Widget _buildNetBalanceCard(BuildContext context, Map<String, int> stats) {
    final balance = stats['income']! - stats['expense']!;
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentEmerald.withOpacity(0.8),
            AppTheme.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentEmerald.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Net Balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(balance / 100),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Calculated from local history',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale();
  }

  Widget _buildQuickStatsRow(BuildContext context, Map<String, int> stats) {
    final income = stats['income']! / 100;
    final expense = stats['expense']! / 100;
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

    return Row(
      children: [
        _buildMiniCard(
          context,
          'Total Income',
          formatter.format(income),
          AppTheme.accentEmerald,
          Icons.arrow_downward_rounded,
        ),
        const SizedBox(width: 16),
        _buildMiniCard(
          context,
          'Total Expense',
          formatter.format(expense),
          AppTheme.accentCoral,
          Icons.arrow_upward_rounded,
        ),
      ],
    );
  }

  Widget _buildMiniCard(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryNavy,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/transactions'),
          child: const Text(
            'See All',
            style: TextStyle(color: AppTheme.accentEmerald, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingPieChart(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: 40,
              title: 'Rent',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: 30,
              title: 'Food',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: 15,
              title: 'Travel',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.purple,
              value: 15,
              title: 'Other',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<dynamic> transactions,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          children: const [
            Icon(
              Icons.receipt_long_outlined,
              color: AppTheme.textSecondary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: transactions.asMap().entries.map((entry) {
        final index = entry.key;
        final tx = entry.value;
        return _buildTransactionItem(context, tx)
            .animate()
            .fadeIn(delay: (400 + (index * 100)).ms)
            .slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic tx) {
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);
    final isExpense = tx.type.toString().contains('expense');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? AppTheme.accentCoral : AppTheme.accentEmerald)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense
                  ? Icons.shopping_bag_outlined
                  : Icons.account_balance_wallet_outlined,
              color: isExpense ? AppTheme.accentCoral : AppTheme.accentEmerald,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.merchantName ?? tx.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tx.category,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            (isExpense ? '- ' : '+ ') + formatter.format(tx.amount / 100),
            style: TextStyle(
              color: isExpense ? AppTheme.accentCoral : AppTheme.accentEmerald,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
