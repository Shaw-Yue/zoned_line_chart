import 'package:flutter/material.dart';
import 'models.dart';
import 'chart_painter.dart';

/// A customizable line chart widget with zone backgrounds,
/// auto-ticking axes, collapsible UI, data filtering,
/// target lines, and interactive data point tooltips.
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

  /// Horizontal dashed target lines (e.g. practitioner target).
  final List<TargetLine> targetLines;

  /// Card title shown above the chart.
  final String? title;

  /// Subtitle / description below the title.
  final String? description;

  /// Height of the chart drawing area (excluding title, legend).
  final double chartHeight;

  /// Color of the line and data dots.
  final Color lineColor;

  /// Tooltip title (e.g. "TEMP LOG"). Shown above the timestamp.
  final String? tooltipLabel;

  /// Tooltip value label (e.g. "Value"). Shown next to the dot.
  final String tooltipValueLabel;

  /// Whether the chart can be collapsed via a button.
  final bool collapsible;

  /// Whether the chart starts in expanded state.
  final bool initiallyExpanded;

  /// Whether to show the data-count filter chips.
  final bool showFilter;

  /// Available filter counts. `null` means "All".
  final List<int?> filterOptions;

  const CustomLineChart({
    super.key,
    required this.data,
    this.xAxisUnit = XAxisUnit.number,
    this.yAxisUnit = '',
    this.yAxisRange,
    this.zones = const [],
    this.targetLines = const [],
    this.title,
    this.description,
    this.chartHeight = 350,
    this.lineColor = const Color(0xFF1860A8),
    this.tooltipLabel,
    this.tooltipValueLabel = 'Value',
    this.collapsible = true,
    this.initiallyExpanded = true,
    this.showFilter = true,
    this.filterOptions = const [5, 10, 20, 50, null],
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  int? _selectedIndex;
  late bool _isExpanded;
  int? _filterCount; // null = All

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  List<DataPoint> get _filteredData {
    if (_filterCount == null || widget.data.length <= _filterCount!) {
      return widget.data;
    }
    return widget.data.sublist(widget.data.length - _filterCount!);
  }

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
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: _buildBody(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  // ----------- header (always visible) -----------

  Widget _buildHeader() {
    final hasTitle = widget.title != null || widget.description != null;
    if (!hasTitle && !widget.collapsible) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: _isExpanded ? 4 : 0),
      child: Row(
        children: [
          Expanded(
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
                      style:
                          const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.collapsible)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedRotation(
                  turns: _isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.expand_more,
                      size: 20, color: Color(0xFF64748B)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ----------- expandable body -----------

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showFilter) _buildFilterChips(),
        SizedBox(
          height: widget.chartHeight,
          child: LayoutBuilder(builder: _buildChart),
        ),
        if (widget.zones.isNotEmpty || widget.targetLines.isNotEmpty)
          _buildLegend(),
      ],
    );
  }

  // ----------- filter chips -----------

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: widget.filterOptions.map((count) {
          final label = count?.toString() ?? 'All';
          final isSelected = _filterCount == count;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() {
                _filterCount = count;
                _selectedIndex = null;
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.lineColor
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------- chart area -----------

  Widget _buildChart(BuildContext context, BoxConstraints constraints) {
    final data = _filteredData;
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final metrics = computeChartMetrics(
      canvasSize: size,
      data: data,
      xAxisUnit: widget.xAxisUnit,
      yAxisUnit: widget.yAxisUnit,
      yAxisRange: widget.yAxisRange,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _onTap(d.localPosition, metrics, data),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: size,
            painter: ChartPainter(
              data: data,
              metrics: metrics,
              zones: widget.zones,
              targetLines: widget.targetLines,
              yAxisUnit: widget.yAxisUnit,
              selectedIndex: _selectedIndex,
              lineColor: widget.lineColor,
            ),
          ),
          if (_selectedIndex != null &&
              _selectedIndex! < data.length)
            _buildTooltip(metrics, data),
        ],
      ),
    );
  }

  // ----------- gesture handling -----------

  void _onTap(Offset pos, ChartMetrics metrics, List<DataPoint> data) {
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

  Widget _buildTooltip(ChartMetrics metrics, List<DataPoint> data) {
    final i = _selectedIndex!;
    final point = data[i];
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
    );
  }

  // ----------- legend (zones + target lines) -----------

  Widget _buildLegend() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Divider(color: Colors.grey[200], height: 1),
        const SizedBox(height: 14),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            ...widget.zones.map((z) => _zoneLegendItem(z)),
            ...widget.targetLines.map((t) => _targetLegendItem(t)),
          ],
        ),
      ],
    );
  }

  Widget _zoneLegendItem(ChartZone z) {
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155))),
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
  }

  Widget _targetLegendItem(TargetLine t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dashed line icon
        SizedBox(
          width: 16,
          height: 10,
          child: CustomPaint(painter: _DashIconPainter()),
        ),
        const SizedBox(width: 6),
        Text(t.name,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155))),
        const SizedBox(width: 4),
        Text(
          '${_fmtLegendNum(t.value)}${widget.yAxisUnit}',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _fmtLegendNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ---------------------------------------------------------------------------
// Small painter for the dashed-line legend icon
// ---------------------------------------------------------------------------

class _DashIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1.5;
    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final end = (x + 3).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
