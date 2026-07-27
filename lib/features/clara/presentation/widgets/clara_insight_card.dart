import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../home/presentation/widgets/income_expense_chart_section.dart';
import '../../data/models/clara_message_model.dart';

/// Renders Clara's expense-summary payload using the exact same grouped
/// income/expense bar chart as the home dashboard ([IncomeExpenseChartSection]).
///
/// When [animate] is true it waits [startDelay] (so it appears only after the
/// preceding reply text has finished typing), then fades + slides in while the
/// bars rise from the baseline.
class ClaraInsightCard extends StatefulWidget {
  final ClaraInsightModel insight;
  final bool animate;
  final Duration startDelay;

  const ClaraInsightCard({
    super.key,
    required this.insight,
    this.animate = false,
    this.startDelay = Duration.zero,
  });

  @override
  State<ClaraInsightCard> createState() => _ClaraInsightCardState();
}

class _ClaraInsightCardState extends State<ClaraInsightCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _startTimer = Timer(widget.startDelay, () {
      if (mounted) _controller?.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = _card(context, 1.0);
    if (_controller == null) return card;

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) {
        final t = _controller!.value;
        // Fade in over the first ~45% of the timeline; bars rise across the
        // whole timeline with an ease-out so they decelerate into place.
        final opacity = (t / 0.45).clamp(0.0, 1.0);
        final rise = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - opacity)),
            child: _card(context, rise),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, double chartProgress) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.86,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: IncomeExpenseChartSection(
        chartProgress: chartProgress,
        data: widget.insight.trend
            .map((p) => IncomeExpenseData(
                  month: p.month,
                  income: p.income,
                  expense: p.expense,
                ))
            .toList(),
        totalIncome: widget.insight.income,
        totalExpense: widget.insight.expense,
      ),
    );
  }
}
