import 'package:cblistify/pages/menu/menu.dart';
import 'package:cblistify/pages/tugas/buat_tugas.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/tema/theme_notifier.dart';

class KalenderPage extends StatefulWidget {
  final int selectedIndex;
  const KalenderPage({super.key, required this.selectedIndex});

  @override
  _KalenderPageState createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    initializeDateFormatting('id_ID', null);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;
    final events = _getEventsForDay(_selectedDay!);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: palette.lighter,
      appBar: AppBar(
        title: const Text("Kalender", style: TextStyle(color: Colors.black)),
        backgroundColor: palette.base,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Kalender dibungkus Container agar seperti "dalam kotak"
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
            ...events.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: palette.lighter,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.darker, width: 1),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.circle, color: palette.base, size: 12),
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
                      trailing: Icon(Icons.edit, color: palette.base),
                    ),
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah tugas
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
      bottomNavigationBar: CustomNavBar(
        currentIndex: widget.selectedIndex,
        onMenuTap: (){
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }
}
