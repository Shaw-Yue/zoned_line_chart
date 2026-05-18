# zoned_line_chart

A highly customizable line chart widget for Flutter featuring colored zone backgrounds, practitioner target lines, collapsible UI, data filtering, automatic axis ticking, smooth curves, and interactive tap-to-inspect tooltips.

## Features

- **Collapsible chart** – A toggle button in the top-right corner to fold/unfold the chart with smooth animation.
- **Data filtering** – Built-in filter chips (5 / 10 / 20 / 50 / All) to quickly show the most recent N data points.
- **Zone backgrounds** – Define colored horizontal bands to indicate thresholds (e.g. normal, warning, danger). Areas beyond the defined zones are automatically filled with the nearest zone's color — no white gaps.
- **Practitioner target lines** – Dashed black horizontal lines with labels for clinical or reference targets.
- **Two-line X-axis labels** – Date on top (MM/dd), time below (HH:mm) for datetime axes.
- **Smart label visibility** – All labels shown for small datasets (≤7 points); 4 evenly-spaced labels for larger ones.
- **Smooth line rendering** – Catmull-Rom spline interpolation for natural-looking curves.
- **Auto-ticking axes** – Heckbert "nice numbers" algorithm generates clean Y-axis tick values automatically.
- **Tap interaction** – Tap any data point to display a tooltip with timestamp, value, and custom notes.
- **Minimal dependencies** – Built entirely with Flutter's `CustomPainter`; only `intl` (>=0.19.0 <1.0.0) is used for date formatting.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  zoned_line_chart: ^1.1.2
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:zoned_line_chart/zoned_line_chart.dart';

CustomLineChart(
  data: [
    DataPoint(x: '2024-10-01T08:00:00Z', y: 36.5, metadata: {'note': 'Morning'}),
    DataPoint(x: '2024-10-01T12:00:00Z', y: 37.8, metadata: {'note': 'After lunch'}),
    DataPoint(x: '2024-10-01T18:00:00Z', y: 37.1),
  ],
  xAxisUnit: XAxisUnit.time,
  yAxisUnit: '°C',
  yAxisRange: (35, 43),
  zones: [
    ChartZone(name: 'Normal',    minY: 35.5, maxY: 37.5, color: Colors.green),
    ChartZone(name: 'Low Fever', minY: 37.5, maxY: 38.5, color: Colors.orange),
    ChartZone(name: 'High Fever', minY: 38.5, maxY: 43,  color: Colors.red),
  ],
  targetLines: [
    TargetLine(name: 'Target Low',  value: 36.0),
    TargetLine(name: 'Target High', value: 37.0),
  ],
  title: 'Temperature Monitoring',
  description: 'Tap a data point for details',
  collapsible: true,
  showFilter: true,
)
```

## API Reference

### `CustomLineChart`

| Property | Type | Default | Description |
|---|---|---|---|
| `data` | `List<DataPoint>` | **required** | Data points to plot |
| `xAxisUnit` | `XAxisUnit` | `.number` | X-axis formatting mode |
| `yAxisUnit` | `String` | `''` | Unit string for Y-axis labels & tooltip |
| `yAxisRange` | `(double, double)?` | auto | Fixed Y range; auto-computed when null |
| `zones` | `List<ChartZone>` | `[]` | Colored horizontal background bands |
| `targetLines` | `List<TargetLine>` | `[]` | Dashed horizontal target/reference lines |
| `title` | `String?` | `null` | Card title above the chart |
| `description` | `String?` | `null` | Subtitle below the title |
| `chartHeight` | `double` | `350` | Height of the chart area |
| `lineColor` | `Color` | `#1860A8` | Color for the line and data dots |
| `tooltipLabel` | `String?` | `null` | Small label shown above the timestamp in tooltip |
| `tooltipValueLabel` | `String` | `'Value'` | Label next to the value dot in tooltip |
| `collapsible` | `bool` | `true` | Show a fold/unfold button in the top-right corner |
| `initiallyExpanded` | `bool` | `true` | Whether the chart starts expanded |
| `showFilter` | `bool` | `true` | Show the data-count filter chips |
| `filterOptions` | `List<int?>` | `[5,10,20,50,null]` | Available filter counts; `null` = "All" |

### `DataPoint`

| Property | Type | Description |
|---|---|---|
| `x` | `dynamic` | X value – `DateTime`, `String` (ISO 8601), or `num` |
| `y` | `double` | Y value (numeric) |
| `metadata` | `Map<String, dynamic>?` | Optional metadata; `'note'` key is shown in tooltip |

### `ChartZone`

| Property | Type | Description |
|---|---|---|
| `name` | `String` | Zone name (shown in legend) |
| `minY` | `double` | Lower bound of the zone |
| `maxY` | `double` | Upper bound of the zone |
| `color` | `Color` | Zone background and legend color |
| `label` | `String?` | Optional short label |

### `TargetLine`

| Property | Type | Description |
|---|---|---|
| `name` | `String` | Target name (shown on chart and in legend) |
| `value` | `double` | Y-axis value where the dashed line is drawn |

### `XAxisUnit`

| Value | Axis Labels | Description |
|---|---|---|
| `.time` | MM/dd + HH:mm (two lines) | Date on top, time below |
| `.date` | MM/dd + HH:mm (two lines) | Date on top, time below |
| `.number` | raw value | Numeric display |
| `.string` | raw value | String display |

## Copy-paste Usage

If you prefer not to add a package dependency, copy these three files into your project:

```
lib/widgets/chart/
├── models.dart
├── chart_painter.dart
└── custom_line_chart.dart
```

Make sure `intl` is in your `pubspec.yaml`. The files use relative imports and work together in any directory.

## License

MIT
