import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  // example weekly data (Sun..Sat)
  List<FlSpot> get _spots => const [
    FlSpot(0, 3),
    FlSpot(1, 4),
    FlSpot(2, 3.5),
    FlSpot(3, 5),
    FlSpot(4, 4),
    FlSpot(5, 6),
    FlSpot(6, 6.5),
  ];

  static const _week = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String _yLabel(double v) {
    // compact axis labels: 0, 2, 4, 6, 8...
    if (v % 2 != 0) return '';
    // format 1000 -> 1k, etc. (you can swap to NumberFormat if needed)
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = [
      const Color(0xFF7C4DFF), // deep purple A200
      const Color(0xFF00BFA5), // teal A700
    ];

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
          // header
          Row(
            children: [
              const Text(
                'Weekly Revenue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              // little legend pill
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

          // chart
          AspectRatio(
            aspectRatio: 1.75,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                // auto y-bounds, or set minY/maxY if you prefer
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: const Color(0xFFE6EAF2),
                    strokeWidth: 1,
                    dashArray: [6, 6],
                  ),
                  getDrawingVerticalLine: (v) => FlLine(
                    color: const Color(0xFFE6EAF2),
                    strokeWidth: 1,
                    dashArray: [6, 6],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          _yLabel(v),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF98A2B3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= _week.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _week[i],
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
                    getTooltipItems: (touched) => touched.map((barSpot) {
                      final x = barSpot.x.toInt();
                      final y = barSpot.y;
                      return LineTooltipItem(
                        '${_week[x]}\n\$${y.toStringAsFixed(2)}k',
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
                    spots: _spots,
                    isCurved: true,
                    gradient: LinearGradient(colors: gradient),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (s, _) =>
                          s.x == _spots.last.x, // only last point
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
