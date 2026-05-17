import 'package:flutter/material.dart';
import 'package:zoned_line_chart/zoned_line_chart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChartMaster Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1860A8),
        fontFamily: 'sans-serif',
      ),
      home: const ChartDemoPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data – temperature monitoring scenario
// ---------------------------------------------------------------------------

const _temperatureZones = <ChartZone>[
  ChartZone(name: 'Hypothermia', minY: 35, maxY: 35.5, color: Color(0xFF94A3B8)),
  ChartZone(name: 'Normal', minY: 35.5, maxY: 37.5, color: Color(0xFF34D399)),
  ChartZone(name: 'Low Fever', minY: 37.5, maxY: 38.5, color: Color(0xFFF59E0B)),
  ChartZone(name: 'High Fever', minY: 38.5, maxY: 43, color: Color(0xFFEF4444)),
];

const _practitionerTargets = <TargetLine>[
  TargetLine(name: 'Target Low', value: 36.0),
  TargetLine(name: 'Target High', value: 37.0),
];

final _sampleData = <DataPoint>[
  DataPoint(x: '2024-09-28T08:00:00Z', y: 36.4, metadata: {'note': 'Routine check'}),
  DataPoint(x: '2024-09-29T08:00:00Z', y: 36.6),
  DataPoint(x: '2024-09-30T14:00:00Z', y: 36.9),
  DataPoint(x: '2024-10-01T08:00:00Z', y: 37.2, metadata: {'note': 'Autumn onset'}),
  DataPoint(x: '2024-10-01T10:00:00Z', y: 38.6, metadata: {'note': 'Sudden high fever (2h later)'}),
  DataPoint(x: '2024-10-01T14:00:00Z', y: 37.8, metadata: {'note': '30 min after medication'}),
  DataPoint(x: '2024-10-01T20:00:00Z', y: 37.2, metadata: {'note': 'Temperature dropping'}),
  DataPoint(x: '2024-10-02T08:00:00Z', y: 36.9, metadata: {'note': 'Next morning'}),
  DataPoint(x: '2024-10-03T08:00:00Z', y: 36.7),
  DataPoint(x: '2024-10-04T08:00:00Z', y: 36.5, metadata: {'note': 'Fully recovered'}),
  DataPoint(x: '2024-10-05T08:00:00Z', y: 36.4),
  DataPoint(x: '2024-10-06T08:00:00Z', y: 36.6),
];

// ---------------------------------------------------------------------------
// Demo page
// ---------------------------------------------------------------------------

class ChartDemoPage extends StatelessWidget {
  const ChartDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1860A8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'ChartMaster',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const Text(
              ' Plugin',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1860A8)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEDICAL CASE STUDY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: const Color(0xFF1860A8),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Body Temperature Trend',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Collapsible chart with data filtering, zone backgrounds, '
              'practitioner target lines, and two-line date/time axis labels.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            // --- Chart ---
            CustomLineChart(
              data: _sampleData,
              xAxisUnit: XAxisUnit.time,
              yAxisUnit: '\u00B0C',
              yAxisRange: (35, 43),
              zones: _temperatureZones,
              targetLines: _practitionerTargets,
              title: 'Real-time Temperature Monitoring',
              description: 'Unit: Celsius (\u00B0C) | Update interval: 4 hours',
              tooltipLabel: 'TEMP LOG',
            ),

            const SizedBox(height: 24),

            // --- Config info card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Color(0xFF1860A8)),
                      SizedBox(width: 6),
                      Text('What\u0027s New in v1.1.0',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1860A8))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...[
                    ('Collapsible', 'Top-right button to fold/unfold'),
                    ('Filter chips', 'Show recent 5 / 10 / 20 / 50 / All'),
                    ('Target lines', 'Dashed lines for practitioner targets'),
                    ('Two-line X axis', 'Date on top, time below'),
                    ('Line color', '#1860A8'),
                  ].map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.$1,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF94A3B8))),
                            Text(e.$2,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
