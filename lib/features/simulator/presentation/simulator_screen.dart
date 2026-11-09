import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/metric_card.dart';
import '../../simulator/domain/financial_calculator.dart';
import '../../simulator/domain/simulation_state.dart';
import 'providers/simulator_provider.dart';

class SimulatorScreen extends ConsumerWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulatorProvider);
    final result = ref.watch(simulatorResultProvider);
    final notifier = ref.read(simulatorProvider.notifier);

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
                      'Business Simulator',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kéo slider để thấy lợi nhuận thay đổi ngay lập tức.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Lưu kịch bản',
                onPressed: () => _save(context, ref),
                icon: const Icon(Icons.bookmark_add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProductInputCard(
            state: state,
            onNameChanged: notifier.setName,
            onCogsChanged: notifier.setCogs,
          ),
          const SizedBox(height: 12),
          _SellingPriceCard(
            state: state,
            onChanged: notifier.setSellingPrice,
          ),
          const SizedBox(height: 12),
          _RateSliderCard(
            title: 'Chi phí Quảng cáo',
            subtitle: 'Ngân sách Ads tính theo % giá bán',
            value: state.adsRate,
            icon: Icons.campaign_rounded,
            color: AppColors.info,
            onChanged: notifier.setAdsRate,
          ),
          const SizedBox(height: 12),
          _RateSliderCard(
            title: 'Phí sàn TMĐT',
            subtitle: 'Hoa hồng sàn + phí thanh toán',
            value: state.platformFeeRate,
            icon: Icons.storefront_rounded,
            color: AppColors.primary,
            onChanged: notifier.setPlatformFee,
          ),
          const SizedBox(height: 12),
          _RateSliderCard(
            title: 'Rủi ro: ${state.riskLabel}',
            subtitle: 'Tỷ lệ hoàn hàng / bảo hành / hao hụt',
            value: state.riskRate,
            icon: Icons.shield_rounded,
            color: AppColors.warning,
            onChanged: notifier.setRiskRate,
          ),
          const SizedBox(height: 12),
          _AdvancedCard(
            packagingFee: state.packagingFee,
            onPackagingFeeChanged: notifier.setPackagingFee,
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Kết quả tức thì',
            subtitle: 'Tính trên 1 đơn vị sản phẩm.',
          ),
          const SizedBox(height: 12),
          MetricCard(
            label: 'Lợi nhuận/đơn',
            value: CurrencyFormatter.vnd(result.grossProfit),
            icon: result.isLoss
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
            color: result.isLoss ? AppColors.loss : AppColors.profit,
            caption: 'Giá bán - tổng chi phí/đơn',
          ),
          const SizedBox(height: 10),
          MetricCard(
            label: 'Tỷ suất lợi nhuận (Margin)',
            value: '${result.marginPercent.toStringAsFixed(1)}%',
            icon: Icons.percent_rounded,
            color: _marginColor(result.marginPercent),
            caption: result.isLoss
                ? 'Đang âm — cần tăng giá hoặc giảm chi phí.'
                : 'Biên lợi nhuận trên mỗi đơn.',
          ),
          const SizedBox(height: 10),
          MetricCard(
            label: 'Điểm hòa vốn',
            value: result.breakEvenUnits == null
                ? 'Lỗ vốn'
                : '${result.breakEvenUnits} đơn',
            icon: Icons.flag_rounded,
            color: result.breakEvenUnits == null
                ? AppColors.loss
                : AppColors.info,
            caption: result.breakEvenUnits == null
                ? 'Lợi nhuận/đơn ≤ 0 nên không thể hòa vốn.'
                : 'Bạn cần bán ${result.breakEvenUnits} đơn để thu hồi '
                    'mức vốn ban đầu ${CurrencyFormatter.vnd(result.initialCapital)}.',
          ),
          const SizedBox(height: 12),
          _CostBreakdownCard(result: result),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _save(context, ref),
            icon: const Icon(Icons.save_rounded),
            label: const Text('Lưu kịch bản'),
          ),
        ],
      ),
    );
  }

  Color _marginColor(double margin) {
    if (margin < 15) return AppColors.loss;
    if (margin < 25) return AppColors.warning;
    return AppColors.profit;
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final saved = await ref.read(simulatorProvider.notifier).save();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Đã lưu kịch bản sản phẩm vào thiết bị.'
              : 'Hãy nhập tên sản phẩm trước khi lưu.',
        ),
      ),
    );
  }
}

class _ProductInputCard extends StatelessWidget {
  const _ProductInputCard({
    required this.state,
    required this.onNameChanged,
    required this.onCogsChanged,
  });

  final SimulationState state;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onCogsChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin sản phẩm',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: state.productName,
              onChanged: onNameChanged,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                prefixIcon: Icon(Icons.inventory_2_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: CurrencyFormatter.number(state.cogs),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              onChanged: (value) {
                onCogsChanged(CurrencyFormatter.parseVnd(value));
              },
              decoration: const InputDecoration(
                labelText: 'Giá vốn (COGS)',
                prefixIcon: Icon(Icons.inventory_rounded),
                suffixText: '₫',
                helperText: 'Giá nhập hàng + phí vận chuyển về kho.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellingPriceCard extends StatelessWidget {
  const _SellingPriceCard({required this.state, required this.onChanged});

  final SimulationState state;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sell_rounded,
                    size: 20,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá bán dự kiến',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Từ giá vốn đến 5× giá vốn',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.vnd(state.sellingPrice),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!state.canPrice)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nhập giá vốn lớn hơn 0 để mở khóa thanh giá bán.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              )
            else ...[
              Slider(
                value: state.sellingPrice,
                min: state.minSellingPrice,
                max: state.maxSellingPrice,
                divisions: 40,
                onChanged: onChanged,
              ),
              Row(
                children: [
                  Text(
                    CurrencyFormatter.vnd(state.minSellingPrice),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.vnd(state.maxSellingPrice),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateSliderCard extends StatelessWidget {
  const _RateSliderCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final IconData icon;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    CurrencyFormatter.percent(value),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: 0,
              max: AppConstants.maxRate,
              divisions: 30,
              activeColor: color,
              thumbColor: color,
              onChanged: onChanged,
            ),
            Row(
              children: [
                Text(
                  '0%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.percent(AppConstants.maxRate),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
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

class _AdvancedCard extends StatelessWidget {
  const _AdvancedCard({
    required this.packagingFee,
    required this.onPackagingFeeChanged,
  });

  final double packagingFee;
  final ValueChanged<double> onPackagingFeeChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
        title: Text(
          'Tùy chỉnh nâng cao',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(
          'Phí đóng gói cố định trên mỗi đơn',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          TextFormField(
            initialValue: CurrencyFormatter.number(packagingFee),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            onChanged: (value) {
              onPackagingFeeChanged(CurrencyFormatter.parseVnd(value));
            },
            decoration: const InputDecoration(
              labelText: 'Phí đóng gói / đơn',
              prefixIcon: Icon(Icons.inventory_2_outlined),
              suffixText: '₫',
            ),
          ),
        ],
      ),
    );
  }
}

class _CostBreakdownCard extends StatelessWidget {
  const _CostBreakdownCard({required this.result});

  final FinancialResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cơ cấu chi phí / đơn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            _CostRow(label: 'Giá vốn (COGS)', value: result.cogs),
            _CostRow(label: 'Phí sàn', value: result.platformCost),
            _CostRow(label: 'Quảng cáo', value: result.adsCost),
            _CostRow(label: 'Rủi ro', value: result.riskCost),
            _CostRow(label: 'Đóng gói', value: result.packagingFee),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),
            _CostRow(
              label: 'Tổng chi phí / đơn',
              value: result.totalUnitCost,
              bold: true,
              color: AppColors.loss,
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  final String label;
  final double value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color ?? AppColors.textSecondary,
                    fontWeight: bold ? FontWeight.w700 : null,
                  ),
            ),
          ),
          Text(
            CurrencyFormatter.vnd(value),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? AppColors.textPrimary,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
