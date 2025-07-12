import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/home/home_page.dart';
import 'package:cblistify/pages/kalender.dart';
import 'package:cblistify/pages/menu.dart';
import 'package:cblistify/pages/pomodoro/tasks_dialog.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:cblistify/pages/pomodoro/settings_dialog.dart';
import 'package:cblistify/theme_notifier.dart';

import 'dart:async';

class PomodoroHome extends StatefulWidget {
  final int selectedIndex;
  const PomodoroHome({super.key, this.selectedIndex = 3});

  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _remainingSeconds = 15 * 60;
  bool _isRunning = false;
  Timer? _timer;

  Map<int, int> _tabDurations = {
    0: 15 * 60,
    1: 5 * 60,
    2: 15 * 60,
  };

  int _currentSets = 4;
  String? _selectedTaskName;
  late int _localCurrentIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(_onTabChanged);
    _resetTimer(_tabDurations[_tabController!.index]!);
    _localCurrentIndex = widget.selectedIndex;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer(int duration) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = duration;
    });
  }

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging) {
      _resetTimer(_tabDurations[_tabController!.index]!);
    }
  }

  String get _timeFormatted {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalDuration = _tabDurations[_tabController!.index]!;
    return _remainingSeconds / totalDuration;
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return SettingsDialog(
          initialPomodoroDuration: _tabDurations[0]! ~/ 60,
          initialShortBreakDuration: _tabDurations[1]! ~/ 60,
          initialLongBreakDuration: _tabDurations[2]! ~/ 60,
          initialSets: _currentSets,
          onApply: ({pomodoroDuration, shortBreakDuration, longBreakDuration, sets}) {
            setState(() {
              if (pomodoroDuration != null) _tabDurations[0] = pomodoroDuration;
              if (shortBreakDuration != null) _tabDurations[1] = shortBreakDuration;
              if (longBreakDuration != null) _tabDurations[2] = longBreakDuration;
              if (sets != null) _currentSets = sets;

              _resetTimer(_tabDurations[_tabController!.index]!);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pengaturan berhasil diterapkan!')),
            );
          },
        );
      },
    );
  }

  void _showTasksDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TasksDialog(
          onTaskSelected: (taskName) {
            setState(() {
              _selectedTaskName = taskName;
            });
          },
        );
      },
    );
  }

  void _onNavBarItemTapped(int index) {
    if (index == _localCurrentIndex) return;

    setState(() => _localCurrentIndex = index);

    Widget nextPage;
    switch (index) {
      case 0: nextPage = DrawerMenu(); break;
      case 1: nextPage = KalenderPage(selectedIndex: index); break;
      case 2: nextPage = HomePage(selectedIndex: index); break;
      case 3: nextPage = PomodoroHome(selectedIndex: index); break;
      default: return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;
    const double tabBarHeight = 50.0;
    const double buttonHeight = 55.0;

    return Scaffold(
      backgroundColor: palette.lighter,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double timerSize = (constraints.maxHeight * 0.40).clamp(200.0, 280.0);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        'Pomodoro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: palette.darker,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showSettingsDialog,
                        child: Icon(Icons.more_vert, color: palette.darker),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  height: tabBarHeight,
                  decoration: BoxDecoration(
                    color: palette.lighter,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.darker.withOpacity(0.1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: palette.base,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: palette.darker,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    tabs: const [
                      Tab(text: 'Pomodoro'),
                      Tab(text: 'Jeda Singkat'),
                      Tab(text: 'Jeda Panjang'),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: timerSize,
                  height: timerSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: timerSize,
                        height: timerSize,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 15,
                          backgroundColor: palette.lighter,
                          valueColor: AlwaysStoppedAnimation<Color>(palette.base),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _tabController?.index == 0
                                ? 'Pomodoro'
                                : _tabController?.index == 1
                                    ? 'Jeda Singkat'
                                    : 'Jeda Panjang',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: palette.base),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _timeFormatted,
                            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: palette.base),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 180,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isRunning ? _pauseTimer() : _startTimer()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.base,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 5,
                      shadowColor: palette.darker.withOpacity(0.1),
                    ),
                    child: Text(
                      _isRunning ? 'Jeda' : 'Mulai',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedTaskName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tugas saat ini: $_selectedTaskName',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.base),
                      ),
                    ),
                  ),
                if (_selectedTaskName != null) const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showTasksDialog,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: palette.darker.withOpacity(0.08),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: palette.base,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                      title: const Text("Tugas", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      subtitle: Text(
                        _selectedTaskName ?? "Pilih Tugas",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      trailing: Icon(Icons.arrow_drop_down, color: palette.base, size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: widget.selectedIndex,
      ),
    );
  }
}
