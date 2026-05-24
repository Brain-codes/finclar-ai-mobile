import 'dart:math' as math;
import 'package:finclar_ai/core/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import 'app_stripe_painter.dart';

class AppBarChartBar {
  final double value;
  final Color color;
  final bool striped;
  final Color? stripeColor;
  final double stripeOpacity;

  const AppBarChartBar({
    required this.value,
    required this.color,
    this.striped = false,
    this.stripeColor,
    this.stripeOpacity = 0.35,
  });
}

class AppBarChartGroup {
  final String label;
  final List<AppBarChartBar> bars;

  const AppBarChartGroup({required this.label, required this.bars});
}

class AppBarChart extends StatelessWidget {
  final List<AppBarChartGroup> groups;
  final double? maxY;
  final int yDivisions;
  final double barWidth;
  final double barSpacing;
  final double height;
  final TextStyle? labelStyle;
  final TextStyle? yAxisStyle;
  final Color? gridColor;
  final String Function(double)? formatY;

  const AppBarChart({
    super.key,
    required this.groups,
    this.maxY,
    this.yDivisions = 4,
    this.barWidth = 10,
    this.barSpacing = 4,
    this.height = 160,
    this.labelStyle,
    this.yAxisStyle,
    this.gridColor,
    this.formatY,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxY =
        maxY ??
        groups.fold<double>(0, (m, g) {
          final groupMax = g.bars.fold<double>(
            0,
            (bm, b) => math.max(bm, b.value),
          );
          return math.max(m, groupMax);
        });
    final roundedMax = effectiveMaxY == 0
        ? 1.0
        : ((effectiveMaxY / 500000).ceil() * 500000).toDouble();

    const yAxisWidth = 36.0;
    const bottomLabelHeight = 20.0;

    final effectiveLabelStyle = (yAxisStyle ?? AppTypography.labelXSmall)
        .copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 9,
        );

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _AppBarChartCanvas(
                  groups: groups,
                  maxY: roundedMax,
                  yDivisions: yDivisions,
                  barWidth: barWidth,
                  barSpacing: barSpacing,
                  bottomLabelHeight: bottomLabelHeight,
                  labelStyle: labelStyle,
                  gridColor: gridColor ?? context.borderColor,
                  canvasWidth: constraints.maxWidth,
                  canvasHeight: constraints.maxHeight,
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: yAxisWidth,
            child: Padding(
              padding: const EdgeInsets.only(bottom: bottomLabelHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(yDivisions + 1, (i) {
                  final v = roundedMax * (yDivisions - i) / yDivisions;
                  return Text(
                    formatY != null ? formatY!(v) : _defaultFormatY(v),
                    style: effectiveLabelStyle,
                    textAlign: TextAlign.left,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _defaultFormatY(double v) {
    if (v >= 1000000) return '₦${(v / 1000000).toStringAsFixed(1)}m';
    if (v >= 1000) return '₦${(v / 1000).toStringAsFixed(0)}k';
    return '₦${v.toStringAsFixed(0)}';
  }
}

class _AppBarChartCanvas extends StatelessWidget {
  final List<AppBarChartGroup> groups;
  final double maxY;
  final int yDivisions;
  final double barWidth;
  final double barSpacing;
  final double bottomLabelHeight;
  final TextStyle? labelStyle;
  final Color gridColor;
  final double canvasWidth;
  final double canvasHeight;

  const _AppBarChartCanvas({
    required this.groups,
    required this.maxY,
    required this.yDivisions,
    required this.barWidth,
    required this.barSpacing,
    required this.bottomLabelHeight,
    required this.labelStyle,
    required this.gridColor,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    final chartHeight = canvasHeight - bottomLabelHeight;
    final barsPerGroup = groups.isEmpty ? 1 : groups.first.bars.length;
    final groupWidth =
        barsPerGroup * barWidth + (barsPerGroup - 1) * barSpacing;
    final groupSpacing = groups.length > 1
        ? (canvasWidth - groupWidth * groups.length) / (groups.length - 1)
        : 0.0;

    final barWidgets = <Widget>[];

    for (int gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      final groupLeft = gi * (groupWidth + groupSpacing);

      for (int bi = 0; bi < group.bars.length; bi++) {
        final bar = group.bars[bi];
        final barLeft = groupLeft + bi * (barWidth + barSpacing);
        final barHeightRatio = maxY > 0
            ? (bar.value / maxY).clamp(0.0, 1.0)
            : 0.0;
        final barH = chartHeight * barHeightRatio;
        final barTop = chartHeight - barH;

        barWidgets.add(
          Positioned(
            left: barLeft,
            top: barTop,
            width: barWidth,
            height: barH == 0 ? 0 : barH,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xs),
              ),
              child: bar.striped
                  ? CustomPaint(
                      painter: AppStripePainter(
                        backgroundColor: bar.color,
                        stripeColor: (bar.stripeColor ?? Colors.white)
                            .withValues(alpha: bar.stripeOpacity),
                      ),
                    )
                  : ColoredBox(color: bar.color),
            ),
          ),
        );
      }

      // Bottom label centered under the group
      final labelCenter = groupLeft + groupWidth / 2;
      barWidgets.add(
        Positioned(
          bottom: 0,
          left: labelCenter - 16,
          width: 32,
          child: Text(
            group.label,
            textAlign: TextAlign.center,
            style: (labelStyle ?? AppTypography.labelXSmall).copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomLabelHeight),
            child: CustomPaint(
              painter: _GridPainter(yDivisions: yDivisions, color: gridColor),
            ),
          ),
        ),
        ...barWidgets,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final int yDivisions;
  final Color color;

  const _GridPainter({required this.yDivisions, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (int i = 0; i <= yDivisions; i++) {
      final y = size.height * i / yDivisions;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.yDivisions != yDivisions || old.color != color;
}
