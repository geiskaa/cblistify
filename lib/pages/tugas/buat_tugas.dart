import 'package:flutter/material.dart';
import 'setdate.dart'; 

class CreateTaskPage extends StatefulWidget {
  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String selectedCategory = 'STUDY';
  String selectedPriority = 'Medium';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool enableReminder = false;

  final List<Map<String, dynamic>> categories = [
    {'name': 'STUDY', 'color': Color(0xFFFFB6C1), 'icon': Icons.school},
    {'name': 'WORK', 'color': Color(0xFFE6E6FA), 'icon': Icons.work},
    {'name': 'SPORT', 'color': Color(0xFFB0E0E6), 'icon': Icons.sports},
  ];

  final List<String> priorities = ['Low', 'Medium', 'High'];
  final Map<String, Color> priorityColors = {
    'Low': Colors.green,
    'Medium': Colors.orange,
    'High': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Tugas Baru',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Tugas
            _buildSectionTitle('Judul Tugas'),
            SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'Masukkan judul tugas...',
            ),
            SizedBox(height: 20),

            // Deskripsi
            _buildSectionTitle('Deskripsi (Opsional)'),
            SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Masukkan deskripsi tugas...',
              maxLines: 3,
            ),
            SizedBox(height: 20),

            // Pilih Kategori
            _buildSectionTitle('Pilih Kategori'),
            SizedBox(height: 12),
            _buildCategorySelector(),
            SizedBox(height: 20),

            // Pilih Tanggal dan Waktu
            _buildSectionTitle('Pilih Tanggal dan Waktu'),
            SizedBox(height: 12),
            _buildDateTimeSelector(),
            SizedBox(height: 20),

            // Pilih Prioritas
            _buildSectionTitle('Pilih Prioritas'),
            SizedBox(height: 12),
            _buildPrioritySelector(),
            SizedBox(height: 20),

            // Pengaturan Pengingat
            _buildReminderToggle(),
            SizedBox(height: 40),

            // Tombol Buat Tugas
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE9ECEF)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: categories.map((category) {
        bool isSelected = selectedCategory == category['name'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['name'];
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? category['color'] : Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? category['color'] : Color(0xFFE9ECEF),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          // Date Range
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDateTimePicker(),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE9ECEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Mulai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          selectedStartDate != null
                              ? '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}'
                              : 'Pilih tanggal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (startTime != null) ...[
                          SizedBox(height: 4),
                          Text(
                            '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF69B4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDateTimePicker(),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE9ECEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Selesai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          selectedEndDate != null
                              ? '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}'
                              : 'Pilih tanggal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (endTime != null) ...[
                          SizedBox(height: 4),
                          Text(
                            '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF69B4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: priorities.map((priority) {
        bool isSelected = selectedPriority == priority;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedPriority = priority;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? priorityColors[priority] : Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? priorityColors[priority]! : Color(0xFFE9ECEF),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : priorityColors[priority],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    priority,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderToggle() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: Color(0xFFFF69B4),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dapatkan Pengingat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: enableReminder,
            onChanged: (value) {
              setState(() {
                enableReminder = value;
              });
            },
            activeColor: Color(0xFFFF69B4),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _createTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF69B4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Buat Tugas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDateTimePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DateTimePickerDialog(
          initialStartDate: selectedStartDate,
          initialEndDate: selectedEndDate,
          initialStartTime: startTime,
          initialEndTime: endTime,
          onConfirm: (startDate, endDate, startTimeOfDay, endTimeOfDay) {
            setState(() {
              selectedStartDate = startDate;
              selectedEndDate = endDate;
              startTime = startTimeOfDay;
              endTime = endTimeOfDay;
            });
          },
        );
      },
    );
  }

  void _createTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judul tugas tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Buat object tugas baru
    Map<String, dynamic> newTask = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': selectedCategory,
      'priority': selectedPriority,
      'startDate': selectedStartDate,
      'endDate': selectedEndDate,
      'startTime': startTime,
      'endTime': endTime,
      'reminderEnabled': enableReminder,
      'isCompleted': false,
      'createdAt': DateTime.now(),
    };

    // Return data ke halaman sebelumnya
    Navigator.pop(context, newTask);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tugas berhasil dibuat!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}