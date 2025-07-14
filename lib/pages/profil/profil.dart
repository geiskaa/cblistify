import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cblistify/pages/menu.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'dart:async'; // Import for Timer

class ProfilPage extends StatefulWidget {
  final int selectedIndex;
  const ProfilPage({super.key, required this.selectedIndex});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  // Tambahkan SingleTickerProviderStateMixin di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 
  late Timer _quoteTimer;
  int _currentQuoteIndex = 0;

  // Variabel untuk animasi maskot
  late AnimationController _mascotAnimationController;
  late Animation<double> _mascotAnimation;

  final List<Map<String, String>> _quotes = [
    {
      "text": "Jangan hanya hitung hari, buatlah hari-hari itu berarti.",
      "author": "- Muhammad Ali"
    },
    {
      "text": "Cara terbaik untuk memprediksi masa depan adalah dengan menciptakannya.",
      "author": "- Peter Drucker"
    },
    {
      "text": "Percayalah pada diri sendiri, dan semua yang Anda inginkan akan menjadi milik Anda.",
      "author": "- Norman Vincent Peale"
    },
    {
      "text": "Kerja keras mengalahkan bakat ketika bakat tidak bekerja keras.",
      "author": "- Tim Notke"
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi Timer untuk quotes
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });

    // Inisialisasi AnimationController untuk maskot
    _mascotAnimationController = AnimationController(
      vsync: this, // 'this' merujuk ke SingleTickerProviderStateMixin
      duration: const Duration(seconds: 2), // Durasi satu siklus naik-turun
    )..repeat(reverse: true); // Mengulang animasi terus-menerus (maju dan mundur)

    // Definisikan animasi (pergerakan dari 0 ke -10 dan kembali ke 0)
    _mascotAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(
        parent: _mascotAnimationController,
        curve: Curves.easeInOutSine, // Kurva animasi untuk gerakan halus
      ),
    );
  }

  @override
  void dispose() {
    _quoteTimer.cancel(); // Batalkan timer quotes
    _mascotAnimationController.dispose(); // Buang controller animasi maskot
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Selamat pagi!';
    } else if (hour >= 12 && hour < 17) {
      return 'Selamat siang!';
    } else if (hour >= 17 && hour < 20) {
      return 'Selamat sore!';
    } else {
      return 'Selamat malam!';
    }
  }

  String _getMascotImage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'assets/images/maskot_pagi.png';
    } else if (hour >= 12 && hour < 17) {
      return 'assets/images/maskot_siang.png';
    } else if (hour >= 17 && hour < 20) {
      return 'assets/images/maskot_sore.png';
    } else {
      return 'assets/images/maskot_malam.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerMenu(),
      backgroundColor: palette.lighter,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                height: 250,
                color: palette.base,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dynamic Mascot Image with Animation
                    Positioned(
                      top: 20,
                      left: 20,
                      child: AnimatedBuilder(
                        animation: _mascotAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _mascotAnimation.value), // Menggerakkan maskot ke atas/bawah
                            child: Image.asset(
                              _getMascotImage(),
                              height: 150, // Adjust size as needed
                              width: 150, // Adjust size as needed
                            ),
                          );
                        },
                      ),
                    ),
                    // Dynamic Greeting
                    Positioned(
                      top: 40,
                      left: 180, // Adjust position based on mascot image
                      child: Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: palette.darker,
                        ),
                      ),
                    ),
                    // Dynamic Quote
                    Positioned(
                      top: 90, // Adjust position based on greeting
                      left: 180,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _quotes[_currentQuoteIndex]["text"]!,
                            style: TextStyle(
                              fontSize: 16,
                              color: palette.darker,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              _quotes[_currentQuoteIndex]["author"]!,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: palette.darker,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan Tugas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.darker)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildSummaryCard(1, 'Tugas Selesai', palette)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSummaryCard(2, 'Tugas Tertunda', palette)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text('Rekap Harian',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.darker)),
                    const SizedBox(height: 15),
                    _buildBarChart(palette),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: widget.selectedIndex,
      onMenuTap: (){
        _scaffoldKey.currentState?.openDrawer();
      },),
    );
  }

  Widget _buildSummaryCard(int count, String label, ThemePalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: palette.darker.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: palette.darker,
              )),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBarChart(ThemePalette palette) {
    final barValues = [7.0, 3.0, 6.5, 6.5, 2.0, 6.5, 1.5];

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: palette.darker.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 12, color: palette.darker),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barValues.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: palette.base,
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 8,
                    color: palette.lighter,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
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
      space: 12,
      child: text,
    );
  }
}