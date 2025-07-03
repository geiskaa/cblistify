import 'dart:async';
import 'package:flutter/material.dart';
import 'settings_dialog.dart'; 
import 'tasks_dialog.dart';

void main() => runApp(const PomodoroApp());

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.grey[50], // Light grey background
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, primary: Colors.pink[300]!),
        useMaterial3: true,
      ),
      home: const PomodoroHome(),
    );
  }
}

// --- CUSTOM WIDGET UNTUK BOTTOM NAV BAR ITEM ---
class CustomBottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final double iconSize;
  final double circleSize;

  const CustomBottomNavItem({
    super.key,
    required this.icon,
    this.isSelected = false,
    this.selectedColor = Colors.white, 
    this.unselectedColor = Colors.grey, 
    this.iconSize = 24.0,
    this.circleSize = 50.0, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.pink[300], 
              shape: BoxShape.circle,
            )
          : null, 
      child: Icon(
        icon,
        size: iconSize,
        color: isSelected ? selectedColor : unselectedColor,
      ),
    );
  }
}
// --- CUSTOM WIDGET ---

class PomodoroHome extends StatefulWidget {
  const PomodoroHome({super.key});

  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome>
    with SingleTickerProviderStateMixin {
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

  int _currentTabIndex = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(_onTabChanged);
    _resetTimer(_tabDurations[_tabController!.index]!);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Waktu habis!')),
          );
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void _resetTimer(int duration) {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = duration;
      _isRunning = false;
    });
  }

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging) {
      if (_isRunning) {
        _pauseTimer();
      }
      _resetTimer(_tabDurations[_tabController!.index]!);
    }
  }

  String get _timeFormatted {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    int totalDuration = _tabDurations[_tabController!.index] ?? 1;
    return (_remainingSeconds / totalDuration).clamp(0.0, 1.0);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(
          initialPomodoroDuration: _tabDurations[0]!,
          initialShortBreakDuration: _tabDurations[1]!,
          initialLongBreakDuration: _tabDurations[2]!,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TasksDialog(
          selectedTaskName: _selectedTaskName,
          onTaskSelected: (taskName) {
            setState(() {
              _selectedTaskName = taskName;
            });
            if (taskName != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tugas dipilih: $taskName')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double appBarHeight = 70.0;
    const double tabBarHeight = 50.0;
    const double buttonHeight = 55.0;
    const double taskSectionMaxHeight = 100.0; 
    const double bottomNavBarHeight = 80.0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableHeight = constraints.maxHeight;
            double timerSize = (availableHeight * 0.40).clamp(200.0, 280.0); 

            return Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      const Text(
                        'Pomodoro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showSettingsDialog,
                        child: Icon(Icons.more_vert, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), 

                //Button Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  height: tabBarHeight, 
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorPadding: EdgeInsets.zero,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pink[300],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    tabs: const [
                      Tab(text: 'Pomodoro'),
                      Tab(text: 'Jeda Singkat'),
                      Tab(text: 'Jeda Panjang'),
                    ],
                  ),
                ),
                const Spacer(flex: 1),

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
                          backgroundColor: Colors.pink[100],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade300!),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown, 
                            child: Text(
                              _tabController?.index == 0
                                  ? 'Pomodoro'
                                  : _tabController?.index == 1
                                      ? 'Jeda Singkat'
                                      : 'Jeda Panjang',
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[300],
                              ),
                              maxLines: 1, 
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown, 
                            child: Text(
                              _timeFormatted,
                              style: TextStyle(
                                fontSize: 60, 
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[300],
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),

                SizedBox(
                  width: 180,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_isRunning) {
                          _pauseTimer();
                        } else {
                          _startTimer();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 5,
                      shadowColor: Colors.pink[100],
                    ),
                    child: Text(
                      _isRunning ? 'Jeda' : 'Mulai',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spacing after Button

                //Tampilan Pilih Tugas
                if (_selectedTaskName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tugas saat ini: $_selectedTaskName',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink[400],
                        ),
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
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.pink[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                      title: const Text(
                        "Tugas",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      subtitle: Text(
                        _selectedTaskName ?? "Pilih Tugas",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_drop_down, color: Colors.pink[300], size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 10), 
                const Spacer(), 
                Container(
                  height: bottomNavBarHeight, 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentTabIndex,
                    selectedItemColor: Colors.transparent,
                    unselectedItemColor: Colors.transparent,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.fixed,
                    onTap: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                      if (index == 3) {
                        _tabController!.animateTo(0);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Navigasi ke index $index')),
                        );
                      }
                    },items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: CustomBottomNavItem(
                          icon: Icons.menu,
                          isSelected: _currentTabIndex == 0,
                          unselectedColor: Colors.grey[600]!,
                        ),
                        label: 'Menu',
                      ),
                      BottomNavigationBarItem(
                        icon: CustomBottomNavItem(
                          icon: Icons.calendar_today,
                          isSelected: _currentTabIndex == 1,
                          unselectedColor: Colors.grey[600]!,
                        ),
                        label: 'Calendar',
                      ),
                      BottomNavigationBarItem(
                        icon: CustomBottomNavItem(
                          icon: Icons.home,
                          isSelected: _currentTabIndex == 2,
                          unselectedColor: Colors.grey[600]!,
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: CustomBottomNavItem(
                          icon: Icons.watch_later_outlined,
                          isSelected: _currentTabIndex == 3,
                          unselectedColor: Colors.grey[600]!,
                          selectedColor: Colors.white,
                        ),
                        label: 'Pomodoro',
                      ),
                      BottomNavigationBarItem(
                        icon: CustomBottomNavItem(
                          icon: Icons.person_outline,
                          isSelected: _currentTabIndex == 4,
                          unselectedColor: Colors.grey[600]!,
                        ),
                        label: 'Profile',
                      ),
                    ],
                    
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}