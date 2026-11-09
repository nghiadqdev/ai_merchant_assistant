import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/daily_sale.dart';
import '../../../providers/app_providers.dart';

/// Small companion to Quick Expense. The PRD's dashboard compares revenue
/// with expenses, but its schema only defines expenses; this sheet fills that
/// gap without adding a whole new tab.
class QuickSaleSheet extends ConsumerStatefulWidget {
  const QuickSaleSheet({super.key});

  @override
  ConsumerState<QuickSaleSheet> createState() => _QuickSaleSheetState();
}

class _QuickSaleSheetState extends ConsumerState<QuickSaleSheet> {
  final TextEditingController _revenueController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController(text: '1');

  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _revenueController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: 'Chọn ngày ghi nhận doanh thu',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final revenue = CurrencyFormatter.parseVnd(_revenueController.text);
    final units = int.tryParse(_unitsController.text.trim()) ?? 0;

    if (revenue <= 0 || units <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhập doanh thu và số đơn lớn hơn 0.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final sale = DailySale(
        id: const Uuid().v4(),
        date: DateTime(_date.year, _date.month, _date.day),
        revenue: revenue,
        units: units,
      );

      await ref.read(salesProvider.notifier).add(sale);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu doanh thu: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ghi nhận doanh thu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Doanh thu này sẽ xuất hiện trong biểu đồ 7 ngày trên Dashboard.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.revenue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.revenue,
                  ),
                ),
                title: const Text('Ngày ghi nhận'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_date),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _revenueController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                labelText: 'Doanh thu',
                hintText: 'Ví dụ: 2.500.000',
                suffixText: '₫',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số đơn',
                prefixIcon: Icon(Icons.shopping_bag_rounded),
                helperText: 'Số đơn đã bán trong ngày.',
              ),
            ),
            const SizedBox(height: 22),
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
              label: Text(_isSaving ? 'Đang lưu…' : 'Lưu doanh thu'),
            ),
          ],
        ),
      ),
    );
  }
}
