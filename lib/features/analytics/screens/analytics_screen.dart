import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/transactions/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealthwise/core/widgets/guest_prompt.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryNavy,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Financial Analytics', style: TextStyle(color: Colors.white)),
        ),
        body: const GuestPrompt(
          title: 'Advanced Insights',
          message: 'Sign in to access AI-powered financial reports and trend analysis for your spending.',
          icon: Icons.analytics_rounded,
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Financial Analytics', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Monthly Spending Trend'),
            const SizedBox(height: 16),
            _buildLineChart(),
            const SizedBox(height: 32),
            _buildSectionTitle('Income vs Expenses'),
            const SizedBox(height: 16),
            _buildBarChart(),
            const SizedBox(height: 32),
            _buildSectionTitle('AI Financial Report'),
            const SizedBox(height: 16),
            _buildAIReportCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 1),
                const FlSpot(2, 4),
                const FlSpot(3, 2),
                const FlSpot(4, 5),
                const FlSpot(5, 3),
              ],
              isCurved: true,
              color: AppTheme.accentEmerald,
              barWidth: 4,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accentEmerald.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(20)),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppTheme.accentEmerald)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppTheme.accentCoral)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppTheme.accentEmerald)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: AppTheme.accentCoral)]),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAIReportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.cardBackground, AppTheme.secondaryNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.accentGold),
              const SizedBox(width: 12),
              Text(
                'AI Analysis',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your financial health score is 78/100. This month you saved 15% more than last month. Consider reducing your entertainment budget to reach your "Gift" goal faster.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Regenerate AI Insight
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold.withOpacity(0.1),
              foregroundColor: AppTheme.accentGold,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View Detailed Report'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
