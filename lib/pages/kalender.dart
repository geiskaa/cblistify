import 'package:cblistify/pages/tugas/buat_tugas.dart';
import 'package:cblistify/pages/tugas/detail_tugas.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KalenderPage extends StatefulWidget {
  final int selectedIndex;
  const KalenderPage({super.key, required this.selectedIndex});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map<Date, List of tasks>
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    initializeDateFormatting('id_ID', null);
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('task')
        .select('id, title, start_date, start_time, category_id, categories(category)')
        .eq('user_id', user.id);

    Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

    for (final task in data) {
      final startDate = DateTime.parse(task['start_date']);
      final dateKey = DateTime(startDate.year, startDate.month, startDate.day);

      final taskEntry = {
        'id': task['id'],
        'title': task['title'],
        'time': task['start_time'],
        'category_id': task['category_id'],
        'category': task['categories']['category'],
      };

      if (!tempEvents.containsKey(dateKey)) {
        tempEvents[dateKey] = [taskEntry];
      } else {
        tempEvents[dateKey]!.add(taskEntry);
      }
    }

    setState(() {
      _events = tempEvents;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'belajar':
        return Colors.blue;
      case 'kerja':
        return Colors.green;
      case 'olahraga':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;
    final events = _getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: palette.lighter,
      appBar: AppBar(
        title: const Text("Kalender", style: TextStyle(color: Colors.black)),
        backgroundColor: palette.base,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: palette.darker, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                locale: 'id_ID',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: palette.lighter,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: palette.base,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  markerDecoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Tidak ada jadwal/tugas/acara hari ini.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ...events.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailTugasPage(taskId: event['id']),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.lighter,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.darker, width: 1),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.circle,
                            color: _getCategoryColor(event['category']),
                            size: 12,
                          ),
                          title: Text(event['title']),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14),
                              const SizedBox(width: 4),
                              Text(DateFormat("dd MMMM", 'id_ID').format(_selectedDay!)),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text(event['time'] ?? "-"),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right, color: palette.base),
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuatTugas(selectedDate: _selectedDay!),
            ),
          );
        },
        backgroundColor: palette.base,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: widget.selectedIndex),
    );
  }
}
