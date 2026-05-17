## 1.1.1

- Widened `intl` dependency to `>=0.19.0 <1.0.0` for compatibility with projects using `intl` 0.19.x or 0.20.x.

## 1.1.0

- **Collapsible chart**: top-right button to fold/unfold the entire chart area.
- **Data filter chips**: quickly show the most recent 5, 10, 20, 50, or all data points.
- **Practitioner target lines** (`TargetLine`): horizontal dashed black lines with labels, included in the legend.
- **Two-line X-axis labels**: date on top, time below (for `time`/`date` axis modes).
- **Smart label visibility**: all labels shown for ≤7 points; 4 evenly-spaced labels for larger datasets.
- **Default line color** changed to `#1860A8`.

## 1.0.0

- Initial release.
- `CustomLineChart` widget with smooth Catmull-Rom line rendering.
- Configurable Y-axis range, unit, and automatic "nice number" tick generation.
- X-axis support for `time` (HH:mm), `date` (MM-dd), `number`, and `string` modes.
- Colored zone backgrounds (`ChartZone`) for visual threshold indication.
- Tap-to-inspect interaction with tooltip card showing timestamp, value, and metadata notes.
- Auto-skipping of overlapping X-axis labels.
- Zone legend rendered below the chart.
