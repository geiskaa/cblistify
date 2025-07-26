import 'package:cblistify/pages/tugas/buat_tugas.dart';
import 'package:cblistify/pages/tugas/detail_tugas.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';

class Event {
  final String id;
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}

class KalenderPage extends StatefulWidget {
  final int selectedIndex;
  const KalenderPage({super.key, required this.selectedIndex});

  @override
  _KalenderPageState createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Event>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTasks();
  }
  
  Future<void> _fetchTasks() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw "Pengguna tidak login";
      final response = await supabase
          .from('task')
          .select('id, title, start_date, start_time, end_time')
          .eq('user_id', user.id)
          .eq('is_completed', false);

      final Map<DateTime, List<Event>> newEvents = {};

      for (var taskData in response) {
        final date = DateTime.parse(taskData['start_date']);
        final dayKey = DateTime.utc(date.year, date.month, date.day);

        if (newEvents[dayKey] == null) {
          newEvents[dayKey] = [];
        }

        newEvents[dayKey]!.add(Event(
          id: taskData['id'],
          title: taskData['title'],
          startTime: _parseTime(taskData['start_time']),
          endTime: _parseTime(taskData['end_time']),
        ));
      }
      
      if (mounted) {
        setState(() {
          _events = newEvents;
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat tugas: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0); 
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }
  
  Color _getContrastingTextColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      backgroundColor: palette.lighter,
      appBar: AppBar(
        title: Text("Kalender", style: TextStyle(color: _getContrastingTextColor(palette.base))),
        backgroundColor: palette.base,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendar(palette),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Tugas pada ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.darker),
                ),
                Text(
                  DateFormat("dd MMMM yyyy", 'id_ID').format(_selectedDay!),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.base),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildEventList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuatTugas(selectedDate: _selectedDay),
            ),
          ).then((_) => _fetchTasks());
        },
        backgroundColor: palette.base,
        child: Icon(Icons.add, color: _getContrastingTextColor(palette.base)),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: widget.selectedIndex),
    );
  }

  Widget _buildCalendar(ThemePalette palette) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar<Event>(
        locale: 'id_ID',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay, 
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: palette.base.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: palette.base,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: palette.darker.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: _getContrastingTextColor(palette.base)),
          todayTextStyle: TextStyle(color: palette.darker),
          weekendTextStyle: TextStyle(color: palette.base),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.darker),
          leftChevronIcon: Icon(Icons.chevron_left, color: palette.darker),
          rightChevronIcon: Icon(Icons.chevron_right, color: palette.darker),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    final selectedEvents = _getEventsForDay(_selectedDay!);

    if (selectedEvents.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: selectedEvents.length,
        itemBuilder: (context, index) {
          final event = selectedEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final palette = Provider.of<ThemeNotifier>(context, listen: false).palette;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailTugasPage(taskId: event.id)),
          ).then((_) => _fetchTasks());
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(width: 5, height: 50, decoration: BoxDecoration(color: palette.base, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Tidak ada tugas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Tekan tombol '+' untuk menambah tugas baru.",
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}