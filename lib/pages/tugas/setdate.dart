import 'package:flutter/material.dart';

class DateTimePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final Function(DateTime?, DateTime?, TimeOfDay?, TimeOfDay?) onConfirm;

  DateTimePickerDialog({
    this.initialStartDate,
    this.initialEndDate,
    this.initialStartTime,
    this.initialEndTime,
    required this.onConfirm,
  });

  @override
  _DateTimePickerDialogState createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    startTime = widget.initialStartTime ?? TimeOfDay(hour: 6, minute: 0);
    endTime = widget.initialEndTime ?? TimeOfDay(hour: 6, minute: 0);
    currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Tanggal Waktu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                    });
                  },
                  icon: Icon(Icons.chevron_left),
                ),
                Text(
                  '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                    });
                  },
                  icon: Icon(Icons.chevron_right),
                ),
              ],
            ),
            
            // Date Range Display
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    startDate != null ? '${startDate!.day}/${startDate!.month}/${startDate!.year}' : '-',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(' - '),
                  Text(
                    endDate != null ? '${endDate!.day}/${endDate!.month}/${endDate!.year}' : '-',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Calendar Grid
            _buildCalendarGrid(),
            SizedBox(height: 20),

            // Time Selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFFFF69B4), size: 8),
                          SizedBox(width: 8),
                          Text('Waktu Mulai', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectTime(true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFB6C1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${startTime!.hour.toString().padLeft(2, '0')} : ${startTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFFFF69B4), size: 8),
                          SizedBox(width: 8),
                          Text('Waktu Selesai', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectTime(false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFB6C1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${endTime!.hour.toString().padLeft(2, '0')} : ${endTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(startDate, endDate, startTime, endTime);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF69B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Simpan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        // Header hari
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Mig']
              .map((day) => Container(
                    width: 32,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 8),
        
        ..._buildCalendarRows(),
      ],
    );
  }

  List<Widget> _buildCalendarRows() {
    List<Widget> rows = [];
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    DateTime lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    int startWeekday = firstDay.weekday;
    int daysInMonth = lastDay.day;
    
    List<Widget> days = [];
    
    // Hari kosong di awal bulan
    for (int i = 1; i < startWeekday; i++) {
      days.add(Container(width: 32, height: 32));
    }
    
    // Hari dalam bulan
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(currentMonth.year, currentMonth.month, day);
      bool isSelected = (startDate != null && _isSameDay(date, startDate!)) ||
                       (endDate != null && _isSameDay(date, endDate!));
      bool isInRange = _isInDateRange(date);
      
      days.add(
        GestureDetector(
          onTap: () => _selectDate(date),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected 
                  ? Color(0xFFFF69B4) 
                  : isInRange 
                      ? Color(0xFFFFB6C1) 
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected || isInRange ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Buat rows dengan 7 kolom
    for (int i = 0; i < days.length; i += 7) {
      int end = (i + 7 < days.length) ? i + 7 : days.length;
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.sublist(i, end),
          ),
        ),
      );
    }
    
    return rows;
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (startDate == null || (endDate != null && date.isBefore(startDate!))) {
        startDate = date;
        endDate = null;
      } else if (endDate == null) {
        if (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!)) {
          endDate = date;
        } else {
          endDate = startDate;
          startDate = date;
        }
      } else {
        startDate = date;
        endDate = null;
      }
    });
  }

void _selectTime(bool isStartTime) async {
  TimeOfDay initial = isStartTime
      ? (startTime ?? TimeOfDay(hour: 6, minute: 0))
      : (endTime ?? TimeOfDay(hour: 6, minute: 0));

  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initial,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.3), // Scale up
        child: Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                dialBackgroundColor: Colors.pink.shade50,
                dialHandColor: Colors.pink,
                hourMinuteTextColor: Colors.pink,
                hourMinuteTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                dayPeriodColor: Colors.pink.shade100,
                dayPeriodTextColor: Colors.white,
                hourMinuteColor: Colors.pink.shade100,
                helpTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.pink,
                ),
                cancelButtonStyle: TextButton.styleFrom(
                  foregroundColor: Colors.pink,
                ),
                confirmButtonStyle: TextButton.styleFrom(
                  foregroundColor: Colors.pink,
                ),
              ),
              colorScheme: ColorScheme.light(
                primary: Colors.pink,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        ),
      );
    },
  );

  if (pickedTime != null) {
    setState(() {
      if (isStartTime) {
        startTime = pickedTime;
      } else {
        endTime = pickedTime;
      }
    });
  }
}



  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isInDateRange(DateTime date) {
    if (startDate == null || endDate == null) return false;
    return date.isAfter(startDate!) && date.isBefore(endDate!);
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mai', 'Juni',
      'Juli', 'Augustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }
}