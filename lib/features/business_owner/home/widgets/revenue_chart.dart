import 'dart:math' as math;
import 'package:fidden/features/business_owner/home/model/revenue_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatelessWidget {
  final List<RevenuePoint> data;
  const RevenueChart({super.key, required this.data});

  static const _fallbackWeek = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  String _yLabel(double v) {
  final actual = v * 1000.0;
  final abs = actual.abs();
  String s;
  if (abs >= 1e6)      s = '${(abs / 1e6).toStringAsFixed(1)}M';
  else if (abs >= 1e3) s = '${(abs / 1e3).toStringAsFixed(0)}k';
  else                 s = abs.toStringAsFixed(0);
  return actual < 0 ? '-$s' : s;
}


  @override
  Widget build(BuildContext context) {
    final gradient = [const Color(0xFF7C4DFF), const Color(0xFF00BFA5)];

    // build labels & spots from provided data
    final labels = data.isEmpty
        ? _fallbackWeek
        : data.map((p) => DateFormat('EEE').format(p.ts)).toList();

    final spots = data.isEmpty
        ? <FlSpot>[]
        : List<FlSpot>.generate(
            data.length,
            (i) => FlSpot(i.toDouble(), data[i].revenue / 1000.0),
          );

    debugPrint(
      '[chart] spots: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}',
    );

    // ✅ SAFE Y-AXIS BOUNDS
    // ✅ SAFE Y-AXIS BOUNDS (supports negatives)
late double minY, maxY, interval;
if (spots.isEmpty) {
  minY = 0; maxY = 1; interval = 1;
} else {
  final ys = spots.map((s) => s.y);
  final yMin = ys.reduce(math.min);
  final yMax = ys.reduce(math.max);
  // small headroom before "nice" rounding
  final pad = (yMax - yMin).abs() * 0.1 + 0.01;
  final nice = _niceAxis(yMin - pad, yMax + pad, maxTicks: 5);
  minY = nice.min;
  maxY = nice.max;
  interval = nice.tick; // clean steps like 1, 2, 5, 10, …
}


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header (unchanged)
          Row(
            children: [
              const Text(
                'Weekly Revenue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Revenue',
                      style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // if no data yet, just draw an empty area (no zero-line)
          AspectRatio(
            aspectRatio: 1.75,
            child: LineChart(
              LineChartData(
                extraLinesData: ExtraLinesData(horizontalLines: [
  HorizontalLine(
    y: 0,
    color: const Color(0xFFCBD5E1), // subtle grey
    strokeWidth: 1.2,
  ),
]),
                minX: 0,
                maxX: (spots.isEmpty ? 6 : (spots.length - 1)).toDouble().clamp(
                  0,
                  6,
                ),
                minY: minY,
                maxY: maxY,
                clipData: FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE6EAF2),
                    strokeWidth: 1,
                    dashArray: [6, 6],
                  ),
                  getDrawingVerticalLine: (_) => const FlLine(
                    color: Color(0xFFE6EAF2),
                    strokeWidth: 1,
                    dashArray: [6, 6],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 40, // <- more room for “-100k”
    interval: interval,
    getTitlesWidget: (v, _) {
      // render only values on our tick grid
      final onTick = ((v - minY) / interval).abs() < 1e-6 ||
                     (((v - minY) / interval) - ((v - minY) / interval).round()).abs() < 1e-6;
      if (!onTick) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Text(
          _yLabel(v),
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF98A2B3),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    },
  ),
),



// 3) Bottom titles: read the label for the matching index
bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 30,
    interval: 1,
    getTitlesWidget: (v, _) {
      final i = v.round();
      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          labels[i], // <- from points, not a static week
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF98A2B3),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    },
  ),
),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFFE6EAF2), width: 1),
                ),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 10,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    tooltipBgColor: Colors.black.withOpacity(0.85),
                    getTooltipItems: (touched) => touched.map((s) {
                      final x = s.x.toInt().clamp(
                        0,
                        data.isEmpty ? 0 : data.length - 1,
                      );
                      final amt = data.isEmpty ? 0.0 : data[x].revenue;
                      final day = data.isEmpty
                          ? labels[x]
                          : DateFormat('EEE').format(data[x].ts);
                      return LineTooltipItem(
                        '$day\n${NumberFormat.simpleCurrency().format(amt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(colors: gradient),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.isNotEmpty,
                      checkToShowDot: (s, _) =>
                          spots.isNotEmpty && s.x == spots.last.x,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: gradient.last,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradient
                            .map((c) => c.withOpacity(0.15))
                            .toList(),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _NiceAxis {
  final double min, max, tick;
  const _NiceAxis(this.min, this.max, this.tick);
}

_NiceAxis _niceAxis(double min, double max, {int maxTicks = 5}) {
  // protect against degenerate ranges
  if (min == max) {
    final d = min == 0 ? 1.0 : (min.abs() * 0.25);
    min -= d; max += d;
  }
  final range = max - min;
  final rough = range / (maxTicks.clamp(2, 10));
  final exponent = (rough == 0 ? 0 : (math.log(rough) / math.ln10).floor());
  final fraction = rough / math.pow(10, exponent);

  double niceFraction;
  if (fraction <= 1)      niceFraction = 1;
  else if (fraction <= 2) niceFraction = 2;
  else if (fraction <= 5) niceFraction = 5;
  else                    niceFraction = 10;

  final step = niceFraction * math.pow(10, exponent);
  final niceMin = (min / step).floor() * step;
  final niceMax = (max / step).ceil() * step;

  return _NiceAxis(niceMin.toDouble(), niceMax.toDouble(), step.toDouble());
}