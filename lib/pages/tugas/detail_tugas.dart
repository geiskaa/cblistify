import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cblistify/pages/tugas/setdate.dart';

class DetailTugasPage extends StatefulWidget {
  final String taskId;
  final VoidCallback? onDelete;

  const DetailTugasPage({required this.taskId, this.onDelete});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  DateTime _tanggal = DateTime.now();
  TimeOfDay _waktu = TimeOfDay.now();
  DateTime _endTanggal = DateTime.now();
  TimeOfDay _endWaktu = TimeOfDay.now();

  String _prioritas = "Sedang";
  String selectedCategoryId = '';
  List<Map<String, dynamic>> categories = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchTask(),
      _fetchCategories(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchTask() async {
  final data = await Supabase.instance.client
      .from('task')
      .select()
      .eq('id', widget.taskId)
      .single();

    setState(() {
      _judulController.text = data['title'] ?? '';
      _deskripsiController.text = data['description'] ?? '';
      _tanggal = DateTime.parse(data['start_date']);
      _waktu = _parseTime(data['start_time']);        // ✅ benar
      _endTanggal = DateTime.parse(data['end_date']);
      _endWaktu = _parseTime(data['end_time']);       // ✅ benar
      _prioritas = _mapPriorityIntToString(data['priority']);
      selectedCategoryId = data['category_id'] ?? '';
    });
  }


  Future<void> _fetchCategories() async {
    final result = await Supabase.instance.client
        .from('categories')
        .select('id, category');

    setState(() {
      categories = List<Map<String, dynamic>>.from(result);
    });
  }

  String _mapPriorityIntToString(int? val) {
    switch (val) {
      case 1:
        return "Rendah";
      case 2:
        return "Sedang";
      case 3:
        return "Tinggi";
      default:
        return "Sedang";
    }
  }

  int _mapPriorityStringToInt(String val) {
    switch (val) {
      case "Rendah":
        return 1;
      case "Sedang":
        return 2;
      case "Tinggi":
        return 3;
      default:
        return 2;
    }
  }

  Future<void> _updateTask() async {
    final updated = {
      'title': _judulController.text,
      'description': _deskripsiController.text,
      'start_date': DateFormat('yyyy-MM-dd').format(_tanggal),
      'start_time': _formatTimeOfDay(_waktu),
      'end_date': DateFormat('yyyy-MM-dd').format(_endTanggal),
      'end_time': _formatTimeOfDay(_endWaktu),
      'priority': _mapPriorityStringToInt(_prioritas),
      'category_id': selectedCategoryId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await Supabase.instance.client
        .from('task')
        .update(updated)
        .eq('id', widget.taskId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tugas berhasil diperbarui')),
    );
  }

  Future<void> _deleteTask() async {
    await Supabase.instance.client
        .from('task')
        .delete()
        .eq('id', widget.taskId);

    if (widget.onDelete != null) widget.onDelete!();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tugas'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateTask,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _konfirmasiHapus,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextFields(theme),
                  SizedBox(height: 20),
                  _buildInfoTile(Icons.category, 'Kategori',
                      _getCategoryNameById(selectedCategoryId),
                      onTap: _showCategoryPopup),
                  _buildInfoTile(Icons.calendar_today, 'Tanggal',
                      DateFormat('dd MMM yyyy').format(_tanggal),
                      onTap: _selectDate),
                  _buildInfoTile(Icons.access_time, 'Waktu',
                      _waktu.format(context)),
                  _buildInfoTile(Icons.calendar_today_outlined, 'Tanggal Selesai',
                      DateFormat('dd MMM yyyy').format(_endTanggal),
                      onTap: _selectDate),
                  _buildInfoTile(Icons.access_time_outlined, 'Waktu Selesai',
                      _endWaktu.format(context)),
                  _buildDropdownTile(Icons.priority_high, 'Prioritas', _prioritas,
                      ['Tinggi', 'Sedang', 'Rendah'], (val) {
                    setState(() => _prioritas = val!);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildTextFields(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: _judulController,
            decoration: InputDecoration(
              hintText: 'Judul Tugas',
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _deskripsiController,
            decoration: InputDecoration(
              hintText: 'Deskripsi Tugas',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(IconData icon, String label, String currentValue,
      List<String> list, ValueChanged<String?>? onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: SizedBox(),
        items: list.map((val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Row(
              children: [
                Icon(Icons.circle,
                    size: 10,
                    color: val == "Tinggi"
                        ? Colors.red
                        : val == "Sedang"
                            ? Colors.orange
                            : Colors.green),
                SizedBox(width: 6),
                Text(val),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _getCategoryNameById(String id) {
    final category = categories.firstWhere(
        (cat) => cat['id'] == id,
        orElse: () => {'category': 'Tidak Diketahui'});
    return category['category'];
  }

  void _showCategoryPopup() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Wrap(
          children: [
            Text('Pilih Kategori',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...categories.map((cat) => ListTile(
                  title: Text(cat['category']),
                  onTap: () {
                    setState(() {
                      selectedCategoryId = cat['id'];
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Tugas?"),
        content: Text("Apakah kamu yakin ingin menghapus tugas ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask();
            },
            child: Text("Hapus"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DateTimePickerDialog(
          initialStartDate: _tanggal,
          initialEndDate: _endTanggal,
          initialStartTime: _waktu,
          initialEndTime: _endWaktu,
          onConfirm: (startDate, endDate, startTime, endTime) {
            if (startDate != null &&
                startTime != null &&
                endDate != null &&
                endTime != null) {
              setState(() {
                _tanggal = startDate;
                _waktu = startTime;
                _endTanggal = endDate;
                _endWaktu = endTime;
              });
            }
          },
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt); // hanya jam dan menit
  }


  @override

  TimeOfDay _parseTime(String timeString) {
  // timeString format: 'HH:mm:ss' atau 'HH:mm'
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Gagal parsing waktu: $e");
      return TimeOfDay.now();
    }
  }

  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}
