import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';


class KalenderPage extends StatefulWidget {
  final int selectedIndex;
  const KalenderPage({super.key, required this.selectedIndex});

  @override
  _KalenderPageState createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2025, 6, 1): [
      {
        'title': 'Jogging',
        'time': '06:00',
      },
    ],
  };

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kalender", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
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
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.pink,
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
          ...events.map((event) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.circle, color: Colors.pink, size: 12),
                    title: Text(event['title']),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(DateFormat("dd MMMM", 'id_ID').format(_selectedDay!)),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 4),
                        Text(event['time']),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.pink),
                  ),
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan fungsi tambah event
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: widget.selectedIndex),
    );
  }
}
