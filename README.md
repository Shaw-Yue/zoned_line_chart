# zoned_line_chart

A highly customizable line chart widget for Flutter featuring colored zone backgrounds, automatic axis ticking, smooth curves, and interactive tap-to-inspect tooltips.

## Features

- **Smooth line rendering** – Catmull-Rom spline interpolation for natural-looking curves.
- **Auto-ticking axes** – Heckbert "nice numbers" algorithm generates clean Y-axis tick values automatically.
- **Zone backgrounds** – Define colored horizontal bands to indicate thresholds (e.g. normal, warning, danger).
- **Tap interaction** – Tap any data point to display a tooltip with timestamp, value, and custom notes.
- **Flexible X-axis** – Supports `time` (HH:mm), `date` (MM-dd), raw `number`, or `string` modes.
- **Zero dependencies** – Built entirely with Flutter's `CustomPainter`; only `intl` is used for date formatting.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  zoned_line_chart: ^1.0.0
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
  title: 'Temperature Monitoring',
  description: 'Tap a data point for details',
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
| `title` | `String?` | `null` | Card title above the chart |
| `description` | `String?` | `null` | Subtitle below the title |
| `chartHeight` | `double` | `350` | Height of the chart area |
| `lineColor` | `Color` | Blue (#2563EB) | Color for the line and data dots |
| `tooltipLabel` | `String?` | `null` | Small label shown above the timestamp in tooltip |
| `tooltipValueLabel` | `String` | `'Value'` | Label next to the value dot in tooltip |

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

### `XAxisUnit`

| Value | Format | Description |
|---|---|---|
| `.time` | `HH:mm` | Time-of-day formatting |
| `.date` | `MM-dd` | Month-day formatting |
| `.number` | raw | Numeric display |
| `.string` | raw | String display |

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
