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
        colorSchemeSeed: const Color(0xFF2563EB),
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
  ChartZone(name: 'Hypothermia', minY: 35, maxY: 35.5, color: Color(0xFF94A3B8), label: 'Low'),
  ChartZone(name: 'Recommended', minY: 36, maxY: 37, color: Color(0xFF10B981), label: 'Ideal'),
  ChartZone(name: 'Normal', minY: 35.5, maxY: 37.5, color: Color(0xFF34D399), label: 'Normal'),
  ChartZone(name: 'Low Fever', minY: 37.5, maxY: 38.5, color: Color(0xFFF59E0B), label: 'Warning'),
  ChartZone(name: 'High Fever', minY: 38.5, maxY: 43, color: Color(0xFFEF4444), label: 'Danger'),
];

final _sampleData = <DataPoint>[
  DataPoint(x: '2024-01-15T08:00:00Z', y: 36.5, metadata: {'note': 'Routine check in January'}),
  DataPoint(x: '2024-05-10T12:00:00Z', y: 36.8, metadata: {'note': 'May record (long gap)'}),
  DataPoint(x: '2024-10-01T08:00:00Z', y: 37.2, metadata: {'note': 'Autumn onset record'}),
  DataPoint(x: '2024-10-01T10:00:00Z', y: 38.6, metadata: {'note': 'Sudden high fever (2h later)'}),
  DataPoint(x: '2024-10-01T14:00:00Z', y: 37.8, metadata: {'note': '30 min after medication'}),
  DataPoint(x: '2024-10-01T20:00:00Z', y: 37.2, metadata: {'note': 'Temperature dropping'}),
  DataPoint(x: '2024-10-02T08:00:00Z', y: 36.9, metadata: {'note': 'Next morning'}),
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
                color: const Color(0xFF2563EB),
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
                  color: Color(0xFF2563EB)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Welcome header ---
            Text(
              'MEDICAL CASE STUDY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: const Color(0xFF2563EB),
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
              'Demonstrates how to build a chart with medical-grade background zones using the ChartMaster plugin. '
              'Features auto-scaling ticks, interactive tooltips, and multi-level zone coloring.',
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
              title: 'Real-time Temperature Monitoring',
              description: 'Unit: Celsius (\u00B0C) | Update interval: 4 hours',
              tooltipLabel: 'TEMP LOG',
            ),

            const SizedBox(height: 24),

            // --- Config info card ---
            _InfoCard(
              items: const [
                ('Y-Axis Range', '35\u00B0C - 43\u00B0C'),
                ('X-Axis Unit', 'Time (HH:mm)'),
                ('Zone Coloring', '5 alert levels'),
                ('Interaction', 'Tap to show notes'),
              ],
            ),

            const SizedBox(height: 16),

            // --- Status card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.thermostat, color: Colors.white, size: 32),
                  const SizedBox(height: 10),
                  const Text(
                    'Status: Recovering',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last reading: 36.9\u00B0C (14:00)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Data table ---
            _DataTable(data: _sampleData, zones: _temperatureZones),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final List<(String, String)> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(Icons.info_outline, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 6),
              Text('Chart Configuration',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((e) => Padding(
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
    );
  }
}

class _DataTable extends StatelessWidget {
  final List<DataPoint> data;
  final List<ChartZone> zones;
  const _DataTable({required this.data, required this.zones});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: const Row(
              children: [
                Text('Raw Data',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...data.map((d) {
            final dt = DateTime.tryParse(d.x.toString());
            final zone = zones
                .where((z) => d.y >= z.minY && d.y < z.maxY)
                .firstOrNull;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      dt != null
                          ? '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}'
                          : d.x.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('${d.y}\u00B0C',
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'monospace')),
                  ),
                  Expanded(
                    flex: 2,
                    child: zone != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: zone.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              zone.name,
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          )
                        : const Text('Unknown',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      d.metadata?['note']?.toString() ?? '-',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}
