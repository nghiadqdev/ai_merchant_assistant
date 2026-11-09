import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../simulator/domain/financial_calculator.dart';

class AiAlertCard extends StatelessWidget {
  const AiAlertCard({
    super.key,
    required this.result,
    this.riskLabel,
  });

  final FinancialResult result;
  final String? riskLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (color, icon, title, message) = _content();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'AI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String, String) _content() {
    if (!result.hasValidPrice) {
      return (
        AppColors.info,
        Icons.tips_and_updates_rounded,
        'Chưa có giá bán',
        'Nhập giá vốn và kéo thanh giá bán để AI tính lợi nhuận, biên lợi nhuận và điểm hòa vốn.',
      );
    }

    final margin = result.marginPercent.toStringAsFixed(1);
    final risk = riskLabel ?? 'rủi ro vận hành';

    if (result.isLoss) {
      return (
        AppColors.loss,
        Icons.warning_amber_rounded,
        'Bạn đang lỗ mỗi đơn',
        'Mỗi đơn lỗ ${CurrencyFormatter.vnd(result.grossProfit.abs())}. '
            'Hãy tăng giá bán, giảm COGS hoặc cắt chi phí $risk ngay.',
      );
    }

    if (result.marginPercent < 15) {
      return (
        AppColors.loss,
        Icons.warning_amber_rounded,
        'Biên lợi nhuận quá mỏng',
        '⚠️ Cảnh báo: Lợi nhuận biên chỉ $margin%, quá mỏng. '
            'Chỉ cần Ads nhích thêm 2% hoặc 3 đơn hoàn là bạn sẽ lỗ.',
      );
    }

    if (result.marginPercent < 25) {
      return (
        AppColors.warning,
        Icons.trending_up_rounded,
        'Biên lợi nhuận trung bình',
        'Biên lợi nhuận $margin% ở mức trung bình. '
            'Nên tối ưu phí sàn hoặc chi phí Ads để tăng buffer an toàn.',
      );
    }

    return (
      AppColors.profit,
      Icons.verified_rounded,
      'Biên lợi nhuận khỏe',
      'Biên lợi nhuận $margin% đang khỏe. Bạn còn khoảng $margin điểm % '
          'trước khi rơi vào vùng lỗ.',
    );
  }
}
