import 'package:cblistify/pages/profil/edit_profil.dart';
import 'package:cblistify/pages/tugas/riwayat_tugas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:cblistify/widgets/custom_navbar.dart';

class ProfilPage extends StatefulWidget {
  final int selectedIndex;
  const ProfilPage({super.key, required this.selectedIndex});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _tugasSelesaiCount = 0;
  int _tugasTertundaCount = 0;

  String _fullName = 'Memuat...';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadTaskCounts();
  }

  Future<void> _loadProfileData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    if (!mounted) return;

    setState(() {
      _fullName = response['full_name'] ?? 'Tanpa Nama';
      _avatarUrl =
          '${response['avatar_url']}?v=${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  Future<void> _loadTaskCounts() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('User belum login');
      return;
    }

    try {
      // Ambil semua task milik user ini
      final response = await supabase
          .from('task')
          .select('is_completed') // hanya ambil status
          .eq('user_id', user.id); // filter user

      final allTasks = response as List<dynamic>;

      final selesaiCount = allTasks.where((task) =>
        task['is_completed'] == true).length;

      final tertundaCount = allTasks.where((task) =>
        task['is_completed'] == false).length;

      setState(() {
        _tugasSelesaiCount = selesaiCount;
        _tugasTertundaCount = tertundaCount;
      });

      debugPrint('SELESAI: $selesaiCount, TERTUNDA: $tertundaCount');
    } catch (e) {
      debugPrint('Gagal ambil jumlah tugas: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: palette.lighter,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(palette),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Tugas',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: palette.darker)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(_tugasSelesaiCount, 'Tugas Selesai', palette, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RiwayatTugasPage(isCompleted: true),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSummaryCard(_tugasTertundaCount, 'Tugas Tertunda', palette, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RiwayatTugasPage(isCompleted: false),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text('Rekap Harian',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: palette.darker)),
                  const SizedBox(height: 15),
                  _buildBarChart(palette),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: widget.selectedIndex,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }

  Widget _buildProfileHeader(ThemePalette palette) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(top: 60, bottom: 24),
      decoration: BoxDecoration(
        color: palette.base.withOpacity(0.25),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                    : null,
              ),
              Container(
                decoration: BoxDecoration(
                  color: palette.lighter,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.base.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: palette.darker,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilPage()));

                    if (result == true) {
                      await _loadProfileData();
                    }
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Hello', style: TextStyle(color: palette.darker, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            _fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: palette.darker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int count, String label, ThemePalette palette, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildBarChart(ThemePalette palette) {
    final barValues = [7.0, 3.0, 6.5, 6.5, 2.0, 6.5, 1.5];

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Grafik batang transparan
          Opacity(
            opacity: 0.25,
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
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
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
                        color: palette.base.withOpacity(0.6), // pastikan warnanya tidak full solid
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 8,
                          color: palette.lighter.withOpacity(0.3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Teks overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Akan segera hadir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Fitur baru, stay tune ya!',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
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