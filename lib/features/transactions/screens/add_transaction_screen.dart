import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:wealthwise/features/transactions/transaction_provider.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType type;
  const AddTransactionScreen({super.key, required this.type});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food & Dining';
  String _selectedPaymentMethod = 'Cash';
  bool _isRecurring = false;

  final List<String> _categories = [
    'Food & Dining', 'Transport', 'Housing/Rent', 'Utilities', 
    'Healthcare', 'Entertainment', 'Shopping', 'Education', 'Savings', 'Other'
  ];

  final List<String> _paymentMethods = ['Cash', 'M-Pesa', 'Bank Transfer', 'Card', 'Other'];

  void _saveTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = (double.parse(amountText) * 100).toInt();
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      userId: user.id,
      type: widget.type,
      amount: amount,
      category: _selectedCategory,
      merchantName: _merchantController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text.trim(),
      date: _selectedDate,
      isRecurring: _isRecurring,
      updatedAt: DateTime.now(),
    );

    await ref.read(transactionRepositoryProvider).addTransaction(transaction);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.type == TransactionType.income ? 'Add Income' : 'Add Expense',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountField(),
            const SizedBox(height: 32),
            _buildLabel('Category'),
            _buildCategoryPicker(),
            const SizedBox(height: 24),
            _buildLabel(widget.type == TransactionType.income ? 'Source' : 'Merchant/Payee'),
            _buildTextField(_merchantController, 'Enter name', Icons.store_outlined),
            const SizedBox(height: 24),
            _buildLabel('Date'),
            _buildDatePicker(),
            const SizedBox(height: 24),
            _buildLabel('Payment Method'),
            _buildPaymentMethodPicker(),
            const SizedBox(height: 24),
            _buildLabel('Notes (Optional)'),
            _buildTextField(_notesController, 'Add notes', Icons.notes_outlined),
            const SizedBox(height: 32),
            _buildRecurringToggle(),
            const SizedBox(height: 48),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      children: [
        const Text('Amount', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            prefixText: 'KES ',
            prefixStyle: TextStyle(color: AppTheme.accentEmerald, fontSize: 24),
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.textSecondary),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = _categories[index]),
              selectedColor: AppTheme.accentEmerald,
              backgroundColor: AppTheme.secondaryNavy,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary),
            const SizedBox(width: 16),
            Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodPicker() {
    return Wrap(
      spacing: 8,
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method;
        return FilterChip(
          label: Text(method),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedPaymentMethod = method),
          selectedColor: AppTheme.accentEmerald,
          backgroundColor: AppTheme.secondaryNavy,
          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary),
        );
      }).toList(),
    );
  }

  Widget _buildRecurringToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recurring Transaction', style: TextStyle(color: Colors.white)),
        Switch(
          value: _isRecurring,
          onChanged: (val) => setState(() => _isRecurring = val),
          activeColor: AppTheme.accentEmerald,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentEmerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
