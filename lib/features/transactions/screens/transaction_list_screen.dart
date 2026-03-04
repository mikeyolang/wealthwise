import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:wealthwise/features/transactions/transaction_provider.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedCategory = 'All';

  final List<String> _types = ['All', 'Income', 'Expense'];
  final List<String> _categories = [
    'All',
    'Food & Dining',
    'Transport',
    'Housing/Rent',
    'Utilities',
    'Healthcare',
    'Entertainment',
    'Shopping',
    'Education',
    'Savings',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = _filterTransactions(transactions);
                if (filtered.isEmpty) return _buildEmptyState();
                return _buildTransactionList(filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.secondaryNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search merchant or notes',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  _types,
                  _selectedType,
                  (val) => setState(() => _selectedType = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  _categories,
                  _selectedCategory,
                  (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          dropdownColor: AppTheme.secondaryNavy,
          style: const TextStyle(color: Colors.white),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> txs) {
    return txs.where((tx) {
      final matchesSearch =
          tx.merchantName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false ||
              tx.notes!.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesType =
          _selectedType == 'All' ||
          tx.type.name.toLowerCase() == _selectedType.toLowerCase();
      final matchesCategory =
          _selectedCategory == 'All' || tx.category == _selectedCategory;

      return (_searchQuery.isEmpty || matchesSearch) &&
          matchesType &&
          matchesCategory;
    }).toList();
  }

  Widget _buildTransactionList(List<TransactionModel> txs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final tx = txs[index];
        return _buildTransactionItem(context, tx);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx) {
    final formatter = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);
    final isExpense = tx.type == TransactionType.expense;

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
                  '${tx.category} • ${DateFormat('MMM d').format(tx.date)}',
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
