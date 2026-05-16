import 'package:flutter/material.dart';
import 'models.dart';
import 'chart_painter.dart';

/// A customizable line chart widget with zone backgrounds,
/// auto-ticking axes, and interactive data point tooltips.
class CustomLineChart extends StatefulWidget {
  /// Data points to plot.
  final List<DataPoint> data;

  /// Controls X axis label formatting.
  final XAxisUnit xAxisUnit;

  /// Unit string appended to Y axis labels and tooltip (e.g. "°C").
  final String yAxisUnit;

  /// Fixed Y range. When null the range is computed automatically.
  final (double, double)? yAxisRange;

  /// Colored horizontal bands drawn behind the line.
  final List<ChartZone> zones;

  /// Card title shown above the chart.
  final String? title;

  /// Subtitle / description below the title.
  final String? description;

  /// Height of the chart drawing area (excluding title, legend).
  final double chartHeight;

  /// Color of the line and data dots.
  final Color lineColor;

  /// Tooltip title (e.g. "Temperature Log"). Shown above the timestamp.
  final String? tooltipLabel;

  /// Tooltip value label (e.g. "Value"). Shown next to the dot.
  final String tooltipValueLabel;

  const CustomLineChart({
    super.key,
    required this.data,
    this.xAxisUnit = XAxisUnit.number,
    this.yAxisUnit = '',
    this.yAxisRange,
    this.zones = const [],
    this.title,
    this.description,
    this.chartHeight = 350,
    this.lineColor = const Color(0xFF2563EB),
    this.tooltipLabel,
    this.tooltipValueLabel = 'Value',
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(
              height: widget.chartHeight,
              child: LayoutBuilder(builder: _buildChart),
            ),
            if (widget.zones.isNotEmpty) _buildLegend(),
          ],
        ),
      ),
    );
  }

  // ----------- header -----------

  Widget _buildHeader() {
    if (widget.title == null && widget.description == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Color(0xFF0F172A),
              ),
            ),
          if (widget.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.description!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ),
        ],
      ),
    );
  }

  // ----------- chart area -----------

  Widget _buildChart(BuildContext context, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final metrics = computeChartMetrics(
      canvasSize: size,
      data: widget.data,
      xAxisUnit: widget.xAxisUnit,
      yAxisUnit: widget.yAxisUnit,
      yAxisRange: widget.yAxisRange,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _onTap(d.localPosition, metrics),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: size,
            painter: ChartPainter(
              data: widget.data,
              metrics: metrics,
              zones: widget.zones,
              yAxisUnit: widget.yAxisUnit,
              selectedIndex: _selectedIndex,
              lineColor: widget.lineColor,
            ),
          ),
          if (_selectedIndex != null) _buildTooltip(metrics),
        ],
      ),
    );
  }

  // ----------- gesture handling -----------

  void _onTap(Offset pos, ChartMetrics metrics) {
    double best = double.infinity;
    int? idx;
    for (int i = 0; i < metrics.pointPositions.length; i++) {
      final d = (pos - metrics.pointPositions[i]).distance;
      if (d < best && d < 36) {
        best = d;
        idx = i;
      }
    }
    setState(() {
      _selectedIndex = idx == _selectedIndex ? null : idx;
    });
  }

  // ----------- tooltip -----------

  Widget _buildTooltip(ChartMetrics metrics) {
    final i = _selectedIndex!;
    if (i >= widget.data.length) return const SizedBox.shrink();
    final point = widget.data[i];
    final screenPos = metrics.pointPositions[i];
    final timestamp = metrics.fullTimestamps[i];

    const tooltipW = 210.0;
    final left =
        (screenPos.dx - tooltipW / 2).clamp(0.0, metrics.plotArea.right - tooltipW);
    var top = screenPos.dy - 120;
    if (top < -4) top = screenPos.dy + 24;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 180),
          child: _TooltipCard(
            timestamp: timestamp,
            value: point.y,
            unit: widget.yAxisUnit,
            note: point.metadata?['note']?.toString(),
            lineColor: widget.lineColor,
            label: widget.tooltipLabel,
            valueLabel: widget.tooltipValueLabel,
          ),
        ),
      ),
    );
  }

  // ----------- zone legend -----------

  Widget _buildLegend() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Divider(color: Colors.grey[200], height: 1),
        const SizedBox(height: 14),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: widget.zones.map((z) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: z.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(z.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(width: 4),
                Text(
                  '${_fmtLegendNum(z.minY)}-${_fmtLegendNum(z.maxY)}${widget.yAxisUnit}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  String _fmtLegendNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ---------------------------------------------------------------------------
// Tooltip card (stateless, extracted for clarity)
// ---------------------------------------------------------------------------

class _TooltipCard extends StatelessWidget {
  final String timestamp;
  final double value;
  final String unit;
  final String? note;
  final Color lineColor;
  final String? label;
  final String valueLabel;

  const _TooltipCard({
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
    required this.lineColor,
    this.label,
    required this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label!,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF94A3B8),
              ),
            ),
          const SizedBox(height: 2),
          Text(
            timestamp,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: lineColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: lineColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                valueLabel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const Spacer(),
              Text(
                _fmtValue(value),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: const Border(
                  left: BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
              child: Text(
                note!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtValue(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
