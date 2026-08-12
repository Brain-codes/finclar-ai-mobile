import 'dart:math' as math;
import 'package:finclar_ai/core/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import 'app_stripe_painter.dart';

class AppBarChartReferenceLine {
  final double value;
  final Color color;
  final String? label;

  /// When both are set, the line spans only from the start group's bar to the
  /// end group's bar (e.g. previous month → current month) instead of the full
  /// chart width. Indices refer to positions in [AppBarChart.groups].
  final int? startGroupIndex;
  final int? endGroupIndex;

  const AppBarChartReferenceLine({
    required this.value,
    required this.color,
    this.label,
    this.startGroupIndex,
    this.endGroupIndex,
  });
}

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
  final AppBarChartReferenceLine? referenceLine;
  final bool showGrid;
  final bool showYAxis;
  final BorderRadius? barBorderRadius;

  /// Floors the gap between groups. When the resulting cluster is wider than
  /// the available width the plot area scrolls horizontally instead of
  /// squashing bars into each other — required for charts with many groups.
  final double? minGroupSpacing;

  /// Caps the gap between groups. Without it groups justify across the full
  /// width, which strands two or three groups at opposite edges. When the
  /// capped cluster is narrower than the canvas it is centered.
  final double? maxGroupSpacing;

  /// Reveal factor 0..1 for a "bars rise from the baseline" entrance. 1.0
  /// (default) draws the chart at full height — leave it for static charts.
  final double progress;

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
    this.referenceLine,
    this.showGrid = true,
    this.showYAxis = true,
    this.barBorderRadius,
    this.maxGroupSpacing,
    this.minGroupSpacing,
    this.progress = 1.0,
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
    final roundedMax = _niceMaxY(effectiveMaxY, yDivisions);

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
                final canvas = _AppBarChartCanvas(
                  groups: groups,
                  maxY: roundedMax,
                  yDivisions: yDivisions,
                  barWidth: barWidth,
                  barSpacing: barSpacing,
                  bottomLabelHeight: bottomLabelHeight,
                  labelStyle: labelStyle,
                  gridColor: gridColor ?? context.borderColor,
                  canvasWidth: math.max(
                    constraints.maxWidth,
                    _naturalWidth(constraints.maxWidth),
                  ),
                  canvasHeight: constraints.maxHeight,
                  referenceLine: referenceLine,
                  showGrid: showGrid,
                  barBorderRadius: barBorderRadius,
                  maxGroupSpacing: maxGroupSpacing,
                  minGroupSpacing: minGroupSpacing,
                  progress: progress,
                );

                final natural = _naturalWidth(constraints.maxWidth);
                if (natural <= constraints.maxWidth) return canvas;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(width: natural, child: canvas),
                );
              },
            ),
          ),
          if (showYAxis) ...[
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
        ],
      ),
    );
  }

  /// Width the groups need at [minGroupSpacing]. Equal to [available] when no
  /// floor is set, so the default justified layout is untouched.
  double _naturalWidth(double available) {
    if (minGroupSpacing == null || groups.length < 2) return available;
    final barsPerGroup = groups.first.bars.length;
    final groupWidth =
        barsPerGroup * barWidth + (barsPerGroup - 1) * barSpacing;
    return groupWidth * groups.length +
        minGroupSpacing! * (groups.length - 1);
  }

  /// Computes a "nice" axis ceiling that closely fits [rawMax] and divides
  /// evenly into [divisions], so bars use the full height regardless of scale.
  double _niceMaxY(double rawMax, int divisions) {
    if (rawMax <= 0) return 1.0;
    final roughStep = rawMax / divisions;
    final magnitude =
        math.pow(10, (math.log(roughStep) / math.ln10).floor()).toDouble();
    final normalized = roughStep / magnitude;
    final double niceNormalized;
    if (normalized <= 1) {
      niceNormalized = 1;
    } else if (normalized <= 2) {
      niceNormalized = 2;
    } else if (normalized <= 2.5) {
      niceNormalized = 2.5;
    } else if (normalized <= 5) {
      niceNormalized = 5;
    } else {
      niceNormalized = 10;
    }
    return niceNormalized * magnitude * divisions;
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
  final AppBarChartReferenceLine? referenceLine;
  final bool showGrid;
  final BorderRadius? barBorderRadius;
  final double? maxGroupSpacing;
  final double? minGroupSpacing;
  final double progress;

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
    this.referenceLine,
    this.showGrid = true,
    this.barBorderRadius,
    this.maxGroupSpacing,
    this.minGroupSpacing,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final chartHeight = canvasHeight - bottomLabelHeight;
    final barsPerGroup = groups.isEmpty ? 1 : groups.first.bars.length;
    final groupWidth =
        barsPerGroup * barWidth + (barsPerGroup - 1) * barSpacing;
    final justifiedSpacing = groups.length > 1
        ? (canvasWidth - groupWidth * groups.length) / (groups.length - 1)
        : 0.0;
    var groupSpacing = maxGroupSpacing != null
        ? math.min(justifiedSpacing, maxGroupSpacing!)
        : justifiedSpacing;
    if (minGroupSpacing != null) {
      groupSpacing = math.max(groupSpacing, minGroupSpacing!);
    }
    final clusterWidth = groupWidth * groups.length +
        groupSpacing * math.max(0, groups.length - 1);
    final clusterLeft = math.max(0.0, (canvasWidth - clusterWidth) / 2);

    final barWidgets = <Widget>[];

    for (int gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      final groupLeft = clusterLeft + gi * (groupWidth + groupSpacing);

      for (int bi = 0; bi < group.bars.length; bi++) {
        final bar = group.bars[bi];
        final barLeft = groupLeft + bi * (barWidth + barSpacing);
        final barHeightRatio = maxY > 0
            ? (bar.value / maxY).clamp(0.0, 1.0)
            : 0.0;
        final barH = chartHeight * barHeightRatio * progress;
        final barTop = chartHeight - barH;

        barWidgets.add(
          Positioned(
            left: barLeft,
            top: barTop,
            width: barWidth,
            height: barH == 0 ? 0 : barH,
            child: ClipRRect(
              borderRadius: barBorderRadius ??
                  const BorderRadius.vertical(
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
      final labelWidth =
          math.min(64.0, math.max(32.0, groupWidth + groupSpacing - 4));
      barWidgets.add(
        Positioned(
          bottom: 0,
          left: labelCenter - labelWidth / 2,
          width: labelWidth,
          child: Text(
            group.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

    final refLineWidgets = <Widget>[];
    if (referenceLine != null) {
      final chartHeight = canvasHeight - bottomLabelHeight;
      final ratio = maxY > 0
          ? (referenceLine!.value / maxY).clamp(0.0, 1.0)
          : 0.0;
      // Line rises with the bars during a reveal (progress 0→1).
      final lineY = chartHeight * (1 - ratio * progress);

      // Optional span between two groups (e.g. previous → current month).
      final start = referenceLine!.startGroupIndex;
      final end = referenceLine!.endGroupIndex;
      final hasSpan = start != null &&
          end != null &&
          start >= 0 &&
          end < groups.length &&
          start <= end;

      double? lineLeft;
      double? lineWidth;
      if (hasSpan) {
        final startLeft = clusterLeft + start * (groupWidth + groupSpacing);
        final endRight =
            clusterLeft + end * (groupWidth + groupSpacing) + groupWidth;
        lineLeft = startLeft;
        lineWidth = endRight - startLeft;
      }

      refLineWidgets.add(
        Positioned(
          top: lineY,
          left: hasSpan ? lineLeft : 0,
          right: hasSpan ? null : 0,
          width: hasSpan ? lineWidth : null,
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(color: referenceLine!.color),
          ),
        ),
      );
      if (referenceLine!.label != null) {
        refLineWidgets.add(
          Positioned(
            top: lineY - 16,
            left: hasSpan ? (lineLeft! + lineWidth! - 48) : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: referenceLine!.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                referenceLine!.label!,
                style: AppTypography.labelXSmall.copyWith(
                  color: referenceLine!.color,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        if (showGrid)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomLabelHeight),
              child: CustomPaint(
                painter: _GridPainter(yDivisions: yDivisions, color: gridColor),
              ),
            ),
          ),
        ...barWidgets,
        ...refLineWidgets,
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

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashGap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
