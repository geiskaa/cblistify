import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class ProfilPage extends StatelessWidget {
  final int selectedIndex;
  const ProfilPage({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 250,
                color: const Color(0xFFFCE4EC),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Icon(Icons.person, size: 80, color: Colors.grey[300]),
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit, size: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Hello', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        Text('USER NAME', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Tugas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildSummaryCard(1, 'Tugas Selesai')),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSummaryCard(2, 'Tugas Tertunda')),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text('Rekap Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildBarChart(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: selectedIndex),
    );
  }

  Widget _buildSummaryCard(int count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE7ED),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB((255 * 0.1).round(), 128, 128, 128),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB((255 * 0.1).round(), 128, 128, 128),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 8,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitles,
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(fontSize: 12)),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 7, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6.5, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6.5, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 6.5, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1.5, color: const Color(0xFFFDE7ED), width: 16, borderRadius: BorderRadius.circular(5))]),
          ],
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Sen', style: style);
        break;
      case 1:
        text = const Text('Sel', style: style);
        break;
      case 2:
        text = const Text('Rab', style: style);
        break;
      case 3:
        text = const Text('Kam', style: style);
        break;
      case 4:
        text = const Text('Jum', style: style);
        break;
      case 5:
        text = const Text('Sab', style: style);
        break;
      case 6:
        text = const Text('Min', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
}
