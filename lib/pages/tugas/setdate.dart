import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

typedef DateTimeRangeConfirmCallback =
    void Function(
      DateTime startDate,
      TimeOfDay startTime, 
      DateTime endDate, 
      TimeOfDay endTime,
    );

class DateTimePickerDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final TimeOfDay initialStartTime;
  final DateTime initialEndDate;
  final TimeOfDay initialEndTime;
  final DateTimeRangeConfirmCallback onConfirm;

  const DateTimePickerDialog({
    super.key,
    required this.initialStartDate,
    required this.initialStartTime,
    required this.initialEndDate,
    required this.initialEndTime,
    required this.onConfirm,
  });

  @override
  _DateTimePickerDialogState createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  late DateTime _startDate, _endDate;
  late TimeOfDay _startTime, _endTime;
  late DateTime _currentMonth;
  int _selectedTab = 0; 

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _startTime = widget.initialStartTime;
    _endDate = widget.initialEndDate;
    _endTime = widget.initialEndTime;
    _currentMonth = DateTime(_startDate.year, _startDate.month, 1);
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_selectedTab == 0) {
        _startDate = date;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = date;
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate;
        }
      }
    });
  }

  void _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTab == 0 ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary:
                    Provider.of<ThemeNotifier>(
                      context,
                      listen: false,
                    ).palette.base,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        if (_selectedTab == 0) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildCalendar(palette),
            const Divider(height: 32),
            _buildTimeSectionHeader(palette),
            const SizedBox(height: 12),
            _buildDateTimeSelector(palette),
            const SizedBox(height: 24),
            _buildActionButtons(palette),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed:
              () => setState(
                () =>
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    ),
              ),
          icon: const Icon(Icons.chevron_left, color: Colors.black54),
        ),
        Text(
          DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed:
              () => setState(
                () =>
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    ),
              ),
          icon: const Icon(Icons.chevron_right, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCalendar(ThemePalette palette) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              ['S', 'S', 'R', 'K', 'J', 'S', 'M']
                  .map(
                    (day) => Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 12),
        ..._buildCalendarRows(palette),
      ],
    );
  }

  List<Widget> _buildCalendarRows(ThemePalette palette) {
    List<Widget> rows = [];
    DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    int startWeekday = firstDayOfMonth.weekday;
    int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    List<Widget> days = List.generate(
      startWeekday - 1,
      (_) => const SizedBox(width: 36, height: 36),
    );

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isStartDate =
          date.year == _startDate.year &&
          date.month == _startDate.month &&
          date.day == _startDate.day;
      final isEndDate =
          date.year == _endDate.year &&
          date.month == _endDate.month &&
          date.day == _endDate.day;
      final isInRange = date.isAfter(_startDate) && date.isBefore(_endDate);

      Color bgColor = Colors.transparent;
      Color fgColor = Colors.black87;

      if (isStartDate || isEndDate) {
        bgColor = palette.base;
        fgColor = Colors.white;
      } else if (isInRange) {
        bgColor = palette.base.withOpacity(0.1);
        fgColor = palette.base;
      }

      days.add(
        GestureDetector(
          onTap: () => _selectDate(date),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: fgColor,
                  fontWeight:
                      isStartDate || isEndDate
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < days.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.sublist(
              i,
              (i + 7 > days.length) ? days.length : i + 7,
            ),
          ),
        ),
      );
    }
    return rows;
  }


  Widget _buildActionButtons(ThemePalette palette) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onConfirm(_startDate, _startTime, _endDate, _endTime);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.base,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSectionHeader(ThemePalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTimeTab("Mulai", 0, palette),
        _buildTimeTab("Selesai", 1, palette),
      ],
    );
  }

  Widget _buildTimeTab(String title, int index, ThemePalette palette) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap:
          () => setState(() {
            _selectedTab = index;
            final dateToView = index == 0 ? _startDate : _endDate;
            _currentMonth = DateTime(dateToView.year, dateToView.month, 1);
          }),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            color: isSelected ? palette.base : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector(ThemePalette palette) {
    final date = _selectedTab == 0 ? _startDate : _endDate;
    final time = _selectedTab == 0 ? _startTime : _endTime;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: palette.base, size: 20),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: palette.base, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    time.format(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
