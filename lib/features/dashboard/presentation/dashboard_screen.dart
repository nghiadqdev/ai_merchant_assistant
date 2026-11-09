import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/expense_visuals.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../data/models/daily_expense.dart';
import '../../../providers/app_providers.dart';
import '../../sales/presentation/quick_sale_sheet.dart';
import '../../simulator/presentation/providers/simulator_provider.dart';
import 'widgets/ai_alert_card.dart';
import 'widgets/weekly_chart_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.onOpenSimulator});

  final VoidCallback onOpenSimulator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final benchmark = ref.watch(selectedBenchmarkProvider);
    final result = ref.watch(simulatorResultProvider);
    final dashboard = ref.watch(dashboardDataProvider);
    final expenses = ref.watch(expensesProvider);
    final simulator = ref.watch(simulatorProvider);

    final profitColor = result.isLoss ? AppColors.loss : AppColors.profit;
    final marginColor = result.marginPercent < 15
        ? AppColors.loss
        : result.marginPercent < 25
            ? AppColors.warning
            : AppColors.profit;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chủ shop',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
              if (benchmark != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        benchmark.categoryName,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                tooltip: 'Ghi doanh thu',
                onPressed: () => _recordSale(context),
                icon: const Icon(Icons.add_chart_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AiAlertCard(
            result: result,
            riskLabel: benchmark?.dynamicRiskType,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MetricCard(
                  compact: true,
                  label: 'Lợi nhuận/đơn',
                  value: CurrencyFormatter.vnd(result.grossProfit),
                  icon: result.isLoss
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: profitColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCard(
                  compact: true,
                  label: 'Biên lợi nhuận',
                  value: '${result.marginPercent.toStringAsFixed(1)}%',
                  icon: Icons.percent_rounded,
                  color: marginColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCard(
                  compact: true,
                  label: 'Hòa vốn',
                  value: result.breakEvenUnits == null
                      ? 'Lỗ vốn'
                      : '${result.breakEvenUnits} đơn',
                  icon: Icons.flag_rounded,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeeklyChartCard(data: dashboard),
          const SizedBox(height: 16),
          _ScenarioCard(
            productName: simulator.productName,
            sellingPrice: simulator.sellingPrice,
            margin: result.marginPercent,
            riskLabel: benchmark?.dynamicRiskType ?? 'Rủi ro',
            riskRate: simulator.riskRate,
            onEdit: onOpenSimulator,
          ),
          const SizedBox(height: 16),
          _RecentExpensesCard(
            expenses: expenses,
            initialCapital: profile?.initialCapital ?? 0,
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng 👋';
    if (hour < 18) return 'Chào buổi chiều 👋';
    return 'Chào buổi tối 👋';
  }

  Future<void> _recordSale(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const QuickSaleSheet(),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã ghi nhận doanh thu.')),
      );
    }
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.productName,
    required this.sellingPrice,
    required this.margin,
    required this.riskLabel,
    required this.riskRate,
    required this.onEdit,
  });

  final String productName;
  final double sellingPrice;
  final double margin;
  final String riskLabel;
  final double riskRate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Kịch bản đang mô phỏng',
              subtitle: 'Kết quả cập nhật ngay khi bạn kéo slider.',
              trailing: TextButton(
                onPressed: onEdit,
                child: const Text('Chỉnh sửa'),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              productName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  icon: Icons.sell_rounded,
                  label: CurrencyFormatter.vnd(sellingPrice),
                  color: AppColors.info,
                ),
                _Chip(
                  icon: Icons.percent_rounded,
                  label: '${margin.toStringAsFixed(1)}% margin',
                  color: margin < 15 ? AppColors.loss : AppColors.profit,
                ),
                _Chip(
                  icon: Icons.shield_rounded,
                  label:
                      '$riskLabel ${CurrencyFormatter.percent(riskRate)}',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentExpensesCard extends StatelessWidget {
  const _RecentExpensesCard({
    required this.expenses,
    required this.initialCapital,
  });

  final List<DailyExpense> expenses;
  final double initialCapital;

  @override
  Widget build(BuildContext context) {
    final recent = expenses.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Chi phí gần đây',
              subtitle: initialCapital > 0
                  ? 'Vốn ban đầu: ${CurrencyFormatter.vnd(initialCapital)}'
                  : 'Nhấn nút + để ghi nhận chi phí.',
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Text(
                'Chưa có chi phí nào. Nhấn nút + để thêm.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              )
            else
              ...recent.map((expense) {
                final color = ExpenseVisuals.color(expense.type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          ExpenseVisuals.icon(expense.type),
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.type.label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              expense.note.isEmpty
                                  ? DateFormat('dd/MM/yyyy').format(expense.date)
                                  : '${expense.note} • ${DateFormat('dd/MM').format(expense.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-${CurrencyFormatter.vnd(expense.amount)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.loss,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
