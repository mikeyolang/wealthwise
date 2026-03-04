import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/goals/goal_model.dart';
import 'package:wealthwise/features/goals/goal_provider.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _monthlyContributionController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365));
  String _selectedCategory = 'Savings';
  String _selectedPriority = 'Medium';
  String _selectedEmoji = '🎯';

  final List<String> _categories = ['Savings', 'Investment', 'Debt Payoff', 'Purchase', 'Education', 'Retirement', 'Other'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _emojis = ['🎯', '🚗', '🏠', '✈️', '🎓', '🏥', '💰', '🎁'];

  void _saveGoal() async {
    final name = _nameController.text.trim();
    final targetText = _targetAmountController.text.trim();
    if (name.isEmpty || targetText.isEmpty) return;

    final targetAmount = (double.parse(targetText) * 100).toInt();
    final monthlyContribution = (double.parse(_monthlyContributionController.text.isEmpty ? '0' : _monthlyContributionController.text.trim()) * 100).toInt();
    
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final goal = GoalModel(
      id: const Uuid().v4(),
      userId: user.id,
      name: name,
      category: _selectedCategory,
      targetAmount: targetAmount,
      deadline: _selectedDate,
      monthlyContribution: monthlyContribution,
      priority: _selectedPriority,
      notes: _notesController.text.trim(),
      emoji: _selectedEmoji,
      updatedAt: DateTime.now(),
    );

    await ref.read(goalRepositoryProvider).addGoal(goal);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Financial Goal', style: TextStyle(color: Colors.white)),
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
            _buildEmojiPicker(),
            const SizedBox(height: 32),
            _buildLabel('Goal Name'),
            _buildTextField(_nameController, 'e.g. Dream Car', Icons.edit_outlined),
            const SizedBox(height: 24),
            _buildLabel('Target Amount'),
            _buildTextField(_targetAmountController, '0.00', Icons.account_balance_wallet_outlined, isNumeric: true),
            const SizedBox(height: 24),
            _buildLabel('Category'),
            _buildDropdown(_categories, _selectedCategory, (val) => setState(() => _selectedCategory = val!)),
            const SizedBox(height: 24),
            _buildLabel('Deadline'),
            _buildDatePicker(),
            const SizedBox(height: 24),
            _buildLabel('Monthly Plan (Optional)'),
            _buildTextField(_monthlyContributionController, 'How much can you save periodically?', Icons.calendar_today_outlined, isNumeric: true),
            const SizedBox(height: 24),
            _buildLabel('Priority'),
            _buildPriorityPicker(),
            const SizedBox(height: 48),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Center(
      child: Wrap(
        spacing: 12,
        children: _emojis.map((e) => GestureDetector(
          onTap: () => setState(() => _selectedEmoji = e),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedEmoji == e ? AppTheme.accentEmerald.withOpacity(0.2) : AppTheme.secondaryNavy,
              border: Border.all(color: _selectedEmoji == e ? AppTheme.accentEmerald : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Text(e, style: const TextStyle(fontSize: 24)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.textSecondary),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2050),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppTheme.textSecondary),
            const SizedBox(width: 16),
            Text(DateFormat('MMMM d, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          dropdownColor: AppTheme.secondaryNavy,
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Row(
      children: _priorities.map((p) {
        final isSelected = _selectedPriority == p;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedPriority = p),
              selectedColor: _getPriorityColor(p),
              backgroundColor: AppTheme.secondaryNavy,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return AppTheme.accentCoral;
      case 'Medium': return AppTheme.accentGold;
      default: return AppTheme.accentEmerald;
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentEmerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Create Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
