import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'models.dart';

// ---------------------------------------------------------------------------
// Chart metrics – computed layout that both the Painter and the Widget use
// ---------------------------------------------------------------------------

class ChartMetrics {
  final Rect plotArea;
  final List<Offset> pointPositions;
  final List<double> yTicks;
  final double yMin;
  final double yMax;
  final List<String> xLabels;
  final List<String> fullTimestamps;
  final List<int> visibleXLabelIndices;

  const ChartMetrics({
    required this.plotArea,
    required this.pointPositions,
    required this.yTicks,
    required this.yMin,
    required this.yMax,
    required this.xLabels,
    required this.fullTimestamps,
    required this.visibleXLabelIndices,
  });
}

// ---------------------------------------------------------------------------
// Compute chart metrics from raw data + constraints
// ---------------------------------------------------------------------------

ChartMetrics computeChartMetrics({
  required Size canvasSize,
  required List<DataPoint> data,
  required XAxisUnit xAxisUnit,
  required String yAxisUnit,
  (double, double)? yAxisRange,
  int desiredYTicks = 8,
}) {
  if (data.isEmpty) {
    return ChartMetrics(
      plotArea: Rect.zero,
      pointPositions: [],
      yTicks: [],
      yMin: 0,
      yMax: 1,
      xLabels: [],
      fullTimestamps: [],
      visibleXLabelIndices: [],
    );
  }

  // --- Y range & ticks ---
  double rawMin, rawMax;
  if (yAxisRange != null) {
    rawMin = yAxisRange.$1;
    rawMax = yAxisRange.$2;
  } else {
    rawMin = data.map((d) => d.y).reduce(min);
    rawMax = data.map((d) => d.y).reduce(max);
    if (rawMin == rawMax) {
      rawMin -= 1;
      rawMax += 1;
    } else {
      final pad = (rawMax - rawMin) * 0.08;
      rawMin -= pad;
      rawMax += pad;
    }
  }

  final yTicks = _niceLinearTicks(rawMin, rawMax, desiredYTicks);
  final yMin = yTicks.first;
  final yMax = yTicks.last;

  // --- X labels & timestamps ---
  final xLabels = <String>[];
  final fullTimestamps = <String>[];
  for (final d in data) {
    final dt = _tryParseDateTime(d.x);
    if (dt != null && (xAxisUnit == XAxisUnit.time || xAxisUnit == XAxisUnit.date)) {
      xLabels.add(xAxisUnit == XAxisUnit.time
          ? DateFormat('HH:mm').format(dt)
          : DateFormat('MM-dd').format(dt));
      fullTimestamps.add(DateFormat('yyyy-MM-dd HH:mm').format(dt));
    } else {
      xLabels.add(d.x.toString());
      fullTimestamps.add(d.x.toString());
    }
  }

  // --- Padding ---
  final maxYLabel = yTicks
      .map((t) => '${_fmtNum(t)}$yAxisUnit')
      .reduce((a, b) => a.length >= b.length ? a : b);
  final leftPad = maxYLabel.length * 7.5 + 12;
  const rightPad = 24.0;
  const topPad = 16.0;
  const bottomPad = 36.0;

  final plotArea = Rect.fromLTRB(
    leftPad,
    topPad,
    canvasSize.width - rightPad,
    canvasSize.height - bottomPad,
  );

  // --- Point positions ---
  final positions = <Offset>[];
  for (int i = 0; i < data.length; i++) {
    final xFrac = data.length == 1 ? 0.5 : i / (data.length - 1);
    final x = plotArea.left + xFrac * plotArea.width;
    final yFrac = (data[i].y - yMin) / (yMax - yMin);
    final y = plotArea.bottom - yFrac * plotArea.height;
    positions.add(Offset(x, y));
  }

  // --- Visible X labels (skip overlapping) ---
  final visibleIndices = _pickVisibleXLabels(xLabels, positions, plotArea.width);

  return ChartMetrics(
    plotArea: plotArea,
    pointPositions: positions,
    yTicks: yTicks,
    yMin: yMin,
    yMax: yMax,
    xLabels: xLabels,
    fullTimestamps: fullTimestamps,
    visibleXLabelIndices: visibleIndices,
  );
}

// ---------------------------------------------------------------------------
// The Custom Painter
// ---------------------------------------------------------------------------

class ChartPainter extends CustomPainter {
  final List<DataPoint> data;
  final ChartMetrics metrics;
  final List<ChartZone> zones;
  final String yAxisUnit;
  final int? selectedIndex;
  final Color lineColor;
  final double lineWidth;
  final double dotRadius;
  final double selectedDotRadius;

  ChartPainter({
    required this.data,
    required this.metrics,
    this.zones = const [],
    this.yAxisUnit = '',
    this.selectedIndex,
    this.lineColor = const Color(0xFF2563EB),
    this.lineWidth = 3.0,
    this.dotRadius = 4.0,
    this.selectedDotRadius = 7.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final area = metrics.plotArea;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    _paintZones(canvas, area);
    _paintGrid(canvas, area);
    _paintYLabels(canvas, area);
    _paintXLabels(canvas, area);
    _paintSelectedCrosshair(canvas, area);
    _paintLine(canvas);
    _paintDots(canvas);

    canvas.restore();
  }

  // --- Zones (colored horizontal bands) ---
  void _paintZones(Canvas canvas, Rect area) {
    for (final zone in zones) {
      final top = _yToScreen(zone.maxY).clamp(area.top, area.bottom);
      final bottom = _yToScreen(zone.minY).clamp(area.top, area.bottom);
      if (top >= bottom) continue;
      canvas.drawRect(
        Rect.fromLTRB(area.left, top, area.right, bottom),
        Paint()..color = zone.color.withValues(alpha: 0.12),
      );
    }
  }

  // --- Horizontal grid (dashed) ---
  void _paintGrid(Canvas canvas, Rect area) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (final tick in metrics.yTicks) {
      final y = _yToScreen(tick);
      _drawDashedLine(canvas, Offset(area.left, y), Offset(area.right, y), paint);
    }
  }

  // --- Y axis labels ---
  void _paintYLabels(Canvas canvas, Rect area) {
    for (final tick in metrics.yTicks) {
      final y = _yToScreen(tick);
      final tp = _makeText('${_fmtNum(tick)}$yAxisUnit', 11, const Color(0xFF94A3B8));
      tp.paint(canvas, Offset(area.left - tp.width - 8, y - tp.height / 2));
    }
  }

  // --- X axis labels ---
  void _paintXLabels(Canvas canvas, Rect area) {
    for (final i in metrics.visibleXLabelIndices) {
      if (i >= metrics.pointPositions.length) continue;
      final pos = metrics.pointPositions[i];
      final tp = _makeText(metrics.xLabels[i], 11, const Color(0xFF94A3B8));
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, area.bottom + 10));
    }
  }

  // --- Vertical crosshair at selected point ---
  void _paintSelectedCrosshair(Canvas canvas, Rect area) {
    if (selectedIndex == null) return;
    final pos = metrics.pointPositions[selectedIndex!];
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    _drawDashedLine(canvas, Offset(pos.dx, area.top), Offset(pos.dx, area.bottom), paint);
  }

  // --- Smooth line ---
  void _paintLine(Canvas canvas) {
    final pts = metrics.pointPositions;
    if (pts.length < 2) return;

    final path = _catmullRomPath(pts);
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // --- Data point dots ---
  void _paintDots(Canvas canvas) {
    for (int i = 0; i < metrics.pointPositions.length; i++) {
      final pos = metrics.pointPositions[i];
      final selected = i == selectedIndex;

      if (selected) {
        canvas.drawCircle(
          pos,
          selectedDotRadius + 6,
          Paint()
            ..color = lineColor.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(pos, selectedDotRadius + 2, Paint()..color = Colors.white);
      }

      canvas.drawCircle(
        pos,
        selected ? selectedDotRadius : dotRadius,
        Paint()..color = lineColor,
      );

      if (!selected) {
        canvas.drawCircle(
          pos,
          dotRadius - 1.2,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  // ---- helpers ----

  double _yToScreen(double value) {
    final area = metrics.plotArea;
    return area.bottom -
        ((value - metrics.yMin) / (metrics.yMax - metrics.yMin)) * area.height;
  }

  @override
  bool shouldRepaint(covariant ChartPainter old) =>
      old.selectedIndex != selectedIndex ||
      old.data != data ||
      old.zones != zones;
}

// ===========================================================================
// Pure helper functions
// ===========================================================================

/// Catmull-Rom → cubic-Bézier smooth path.
Path _catmullRomPath(List<Offset> pts) {
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (int i = 0; i < pts.length - 1; i++) {
    final p0 = i > 0 ? pts[i - 1] : pts[i];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = i < pts.length - 2 ? pts[i + 2] : pts[i + 1];
    path.cubicTo(
      p1.dx + (p2.dx - p0.dx) / 6,
      p1.dy + (p2.dy - p0.dy) / 6,
      p2.dx - (p3.dx - p1.dx) / 6,
      p2.dy - (p3.dy - p1.dy) / 6,
      p2.dx,
      p2.dy,
    );
  }
  return path;
}

/// "Nice numbers" tick generation (Heckbert algorithm).
List<double> _niceLinearTicks(double lo, double hi, int desired) {
  if (lo >= hi) return [lo];
  final range = hi - lo;
  final raw = range / desired;
  final mag = pow(10, (log(raw) / ln10).floor()).toDouble();
  final res = raw / mag;
  final step = mag * (res <= 1.0 ? 1 : res <= 2.0 ? 2 : res <= 5.0 ? 5 : 10);
  final start = (lo / step).floor() * step;
  final end = (hi / step).ceil() * step;

  final ticks = <double>[];
  for (var v = start; v <= end + step * 0.001; v += step) {
    ticks.add(double.parse(v.toStringAsFixed(10)));
  }
  return ticks;
}

DateTime? _tryParseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

String _fmtNum(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  final s = v.toStringAsFixed(1);
  return s.endsWith('0') ? v.toInt().toString() : s;
}

TextPainter _makeText(String text, double size, Color color) {
  return TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
}

void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint,
    {double dash = 4, double gap = 3}) {
  final dist = (b - a).distance;
  if (dist == 0) return;
  final dx = (b.dx - a.dx) / dist;
  final dy = (b.dy - a.dy) / dist;
  var d = 0.0;
  while (d < dist) {
    final segEnd = min(d + dash, dist);
    canvas.drawLine(
      Offset(a.dx + dx * d, a.dy + dy * d),
      Offset(a.dx + dx * segEnd, a.dy + dy * segEnd),
      paint,
    );
    d += dash + gap;
  }
}

List<int> _pickVisibleXLabels(
    List<String> labels, List<Offset> positions, double plotWidth) {
  if (labels.isEmpty) return [];
  if (labels.length <= 2) return List.generate(labels.length, (i) => i);

  final maxLabelPx =
      labels.map((l) => l.length * 7.0).reduce(max) + 20;
  final maxVisible = max(2, (plotWidth / maxLabelPx).floor());

  if (labels.length <= maxVisible) {
    return List.generate(labels.length, (i) => i);
  }

  final step = ((labels.length - 1) / (maxVisible - 1)).ceil();
  final indices = <int>[];
  for (int i = 0; i < labels.length; i += step) {
    indices.add(i);
  }
  if (!indices.contains(labels.length - 1)) {
    indices.add(labels.length - 1);
  }
  return indices;
}
