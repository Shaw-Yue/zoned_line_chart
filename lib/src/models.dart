import 'package:flutter/material.dart';

/// A single data point on the chart.
class DataPoint {
  /// The x-axis value. Can be [DateTime], [num], or [String].
  /// When [String] is provided and xAxisUnit is time/date,
  /// it will be parsed as ISO 8601 datetime.
  final dynamic x;

  /// The y-axis numeric value.
  final double y;

  /// Optional metadata (e.g. {'note': 'Patient felt dizzy'}).
  /// The 'note' key will be displayed in the tooltip.
  final Map<String, dynamic>? metadata;

  const DataPoint({
    required this.x,
    required this.y,
    this.metadata,
  });
}

/// Defines a colored horizontal band on the chart background.
class ChartZone {
  final String name;
  final double minY;
  final double maxY;
  final Color color;
  final String? label;

  const ChartZone({
    required this.name,
    required this.minY,
    required this.maxY,
    required this.color,
    this.label,
  });
}

/// A horizontal dashed target line (e.g. practitioner target).
class TargetLine {
  final String name;
  final double value;

  const TargetLine({required this.name, required this.value});
}

/// Controls how the X axis values are formatted.
enum XAxisUnit {
  /// Format as date + time (two-line label)
  time,

  /// Format as date + time (two-line label)
  date,

  /// Display raw numeric value
  number,

  /// Display raw string value
  string,
}
