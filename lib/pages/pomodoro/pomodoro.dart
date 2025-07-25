import 'package:cblistify/pages/pomodoro/timer_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cblistify/pages/pomodoro/tasks_dialog.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:cblistify/pages/pomodoro/settings_dialog.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'dart:async';

class PomodoroHome extends StatefulWidget {
  final int selectedIndex;
  const PomodoroHome({super.key, this.selectedIndex = 3});

  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome> with TickerProviderStateMixin {
  TabController? _tabController;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  Map<int, int> _tabDurations = {0: 25 * 60, 1: 5 * 60, 2: 15 * 60};
  String? _selectedTaskId;
  String? _selectedTaskName;

  late AnimationController _alarmController;
  late Animation<double> _shakeAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();

  int _totalSets = 4;
  int _totalCycles = 1;
  int _currentSets = 0;
  int _currentCycle = 1;
  bool _isAlarmSounded = false;
  bool _isSessionComplete = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(_onTabChanged);
    _resetTimer(_tabDurations[0]!); 

    _alarmController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _alarmController.reverse();
      });
    _shakeAnimation = Tween<double>(begin: 0, end: 5.0).animate(CurvedAnimation(parent: _alarmController, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController?.dispose();
    _alarmController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _isSessionComplete) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds <= 10 && !_isAlarmSounded) {
          _playFinishSound();
          setState(() => _isAlarmSounded = true);
          _alarmController.forward(from: 0.0);
        }
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _moveToNextTab();
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
      _isAlarmSounded = false;
    });
  }

  void _onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      _resetTimer(_tabDurations[_tabController!.index]!);
    }
  }

  void _moveToNextTab() {
    if (_tabController == null) return;
    bool shouldStartNextTimer = true;

    if (_tabController!.index == 0) {
      _savePomodoroSession(); 
      setState(() => _currentSets++);
      if (_currentSets > 0 && _currentSets % _totalSets == 0) {
        _tabController!.animateTo(2);
      } else {
        _tabController!.animateTo(1);
      }
    } else {
      if (_tabController!.index == 2 && _currentCycle >= _totalCycles) {
        setState(() => _isSessionComplete = true);
        shouldStartNextTimer = false;
      } else {
        if (_tabController!.index == 2) {
          setState(() {
            _currentSets = 0;
            _currentCycle++;
          });
        }
        _tabController!.animateTo(0);
      }
    }

    _playFinishSound();
    if (shouldStartNextTimer) {
      Future.delayed(const Duration(milliseconds: 500), () => _startTimer());
    }
  }

  Future<void> _savePomodoroSession() async {
    if (_selectedTaskId == null) return;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw "User tidak login";
      final sessionData = {
        'id': const Uuid().v4(),
        'user_id': user.id,
        'task_id': _selectedTaskId,
        'duration_minutes': _tabDurations[0]! ~/ 60,
        'completed_at': DateTime.now().toIso8601String(),
      };
      await supabase.from('pomodoro_sessions').insert(sessionData);
      print("Sesi pomodoro berhasil disimpan");
    } catch (e) {
      print("Gagal menyimpan sesi pomodoro: $e");
    }
  }

  void _resetSession() {
    setState(() {
      _currentCycle = 1;
      _currentSets = 0;
      _isSessionComplete = false;
      _tabController?.animateTo(0);
      _resetTimer(_tabDurations[0]!);
    });
  }

  Future<void> _playFinishSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/timercountdown.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  String get _timeFormatted => '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';
  double get _progress => _tabController != null && _tabDurations[_tabController!.index]! > 0 ? (_remainingSeconds / _tabDurations[_tabController!.index]!) : 1.0;

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        initialPomodoroDuration: _tabDurations[0]!,
        initialShortBreakDuration: _tabDurations[1]!,
        initialLongBreakDuration: _tabDurations[2]!,
        initialSets: _totalSets,
        initialCycles: _totalCycles,
        onApply: ({
          required pomodoroDuration,
          required shortBreakDuration,
          required longBreakDuration,
          required sets,
          required cycles,
        }) {
          setState(() {
            _tabDurations[0] = pomodoroDuration;
            _tabDurations[1] = shortBreakDuration;
            _tabDurations[2] = longBreakDuration;
            _totalSets = sets;
            _totalCycles = cycles;
            _currentSets = 0;
            _currentCycle = 1;
            _isSessionComplete = false;
            if (_tabController != null) {
              _tabController!.animateTo(0);
              _resetTimer(_tabDurations[0]!);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan berhasil diterapkan!')));
        },
      ),
    );
  }

  void _showTasksDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TasksDialog(
        selectedTaskId: _selectedTaskId,
        onTaskSelected: (taskId, taskName) {
          setState(() {
            _selectedTaskId = taskId;
            _selectedTaskName = taskName;
          });
        },
      ),
    );
  }

  String get _friendlyMessage {
    if (_isSessionComplete) return "Sesi selesai! Kamu hebat!";
    if (!_isRunning) return "Siap untuk fokus?";
    if (_tabController?.index == 0) return "Waktunya fokus! Kamu pasti bisa.";
    if (_tabController?.index == 1) return "Ambil nafas sejenak, regangkan badanmu.";
    return "Kerja bagus! Istirahat yang cukup ya.";
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FD),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pomodoro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black54), onPressed: _showSettingsDialog),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (_tabController != null) _buildModeSelector(palette),
            const Spacer(),
            _buildTimerCircle(palette),
            const SizedBox(height: 20),
            _buildCycleIndicators(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(_friendlyMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700])),
            ),
            const Spacer(),
            _buildTaskDisplay(),
            const SizedBox(height: 20),
            _buildStartButton(palette),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: widget.selectedIndex),
    );
  }
  
  Widget _buildModeSelector(ThemePalette palette) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          final titles = ['Fokus', 'Jeda Pendek', 'Jeda Panjang'];
          bool isSelected = _tabController!.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isRunning) _pauseTimer();
                _tabController!.animateTo(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: isSelected ? palette.base : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(titles[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimerCircle(ThemePalette palette) {
    final bool isAlmostUp = _remainingSeconds <= 10 && _remainingSeconds > 0;
    final Color progressColor = isAlmostUp ? Colors.red.shade400 : palette.base;
    return SizedBox(
      width: 280,
      height: 280,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: _progress, end: _progress),
        duration: const Duration(milliseconds: 200),
        builder: (context, double value, child) => CustomPaint(
          painter: TimerPainter(progress: value, progressColor: progressColor, backgroundColor: Colors.grey[200]!),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAlmostUp)
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child),
                  child: Icon(Icons.notifications_active, color: progressColor, size: 32),
                ),
              Text(_timeFormatted, style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: _isSessionComplete ? Colors.grey : progressColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDisplay() {
    return _selectedTaskId == null
        ? OutlinedButton.icon(
            icon: const Icon(Icons.add_task, size: 20),
            label: const Text("Pilih Tugas untuk Pomodoro"),
            onPressed: _showTasksDialog,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.black54, side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_outlined, color: Colors.black54),
                const SizedBox(width: 12),
                Flexible(child: Text(_selectedTaskName!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))),
                const SizedBox(width: 12),
                InkWell(onTap: _showTasksDialog, child: Text("Ganti", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold))),
              ],
            ),
          );
  }

  Widget _buildStartButton(ThemePalette palette) {
    String buttonText;
    VoidCallback onPressedAction;

    if (_isSessionComplete) {
      buttonText = 'Mulai Sesi Baru';
      onPressedAction = _resetSession;
    } else if (_isRunning) {
      buttonText = 'JEDA';
      onPressedAction = _pauseTimer;
    } else {
      buttonText = 'MULAI';
      onPressedAction = _startTimer;
    }

    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressedAction,
        style: ElevatedButton.styleFrom(backgroundColor: palette.base, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 10, shadowColor: palette.base.withOpacity(0.5)),
        child: Text(buttonText, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildCycleIndicators() {
    final setsToShow = _totalSets == 0 ? 0 : (_currentSets % _totalSets == 0 && _currentSets > 0 ? _totalSets : _currentSets % _totalSets);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Set: $setsToShow / $_totalSets", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        const SizedBox(width: 24),
        Text("Siklus: $_currentCycle / $_totalCycles", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ],
    );
  }
}