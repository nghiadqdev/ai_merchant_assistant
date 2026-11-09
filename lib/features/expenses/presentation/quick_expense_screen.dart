import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/expense_visuals.dart';
import '../../../data/models/daily_expense.dart';
import '../../../providers/app_providers.dart';

class QuickExpenseScreen extends ConsumerStatefulWidget {
  const QuickExpenseScreen({super.key});

  @override
  ConsumerState<QuickExpenseScreen> createState() => _QuickExpenseScreenState();
}

class _QuickExpenseScreenState extends ConsumerState<QuickExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  ExpenseType _type = ExpenseType.ads;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: 'Chọn ngày phát sinh chi phí',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final amount = CurrencyFormatter.parseVnd(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy nhập số tiền lớn hơn 0.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final expense = DailyExpense(
        id: const Uuid().v4(),
        date: DateTime(_date.year, _date.month, _date.day),
        type: _type,
        amount: amount,
        note: _noteController.text.trim(),
      );

      await ref.read(expensesProvider.notifier).add(expense);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu chi phí: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = ExpenseVisuals.color(_type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập chi phí nhanh'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Ghi nhận chi phí hàng ngày',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chi phí này sẽ được tổng hợp vào biểu đồ 7 ngày trên Dashboard.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Ngày phát sinh'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_date),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Loại chi phí',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: ExpenseType.values.map((type) {
                final itemColor = ExpenseVisuals.color(type);
                return DropdownMenuItem<ExpenseType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        ExpenseVisuals.icon(type),
                        size: 18,
                        color: itemColor,
                      ),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                labelText: 'Số tiền',
                hintText: 'Ví dụ: 500.000',
                suffixText: '₫',
                prefixIcon: Icon(
                  ExpenseVisuals.icon(_type),
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Ví dụ: Chạy Ads ngày 9/11 cho sản phẩm A',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSaving ? 'Đang lưu…' : 'Lưu chi phí'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Dữ liệu được lưu offline trước, tự đồng bộ khi có mạng.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
