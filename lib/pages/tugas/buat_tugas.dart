import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cblistify/pages/tugas/setdate.dart';

class BuatTugas extends StatefulWidget {
  final DateTime? selectedDate;
  const BuatTugas({super.key, this.selectedDate});

  @override
  _BuatTugasPageState createState() => _BuatTugasPageState();
}

class _BuatTugasPageState extends State<BuatTugas> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String? selectedCategory; // ✅ diubah ke nullable
  List<Map<String, dynamic>> categories = [];
  final String _addNewCategoryValue = '---tambah_kategori_baru---';
  DateTime _tanggal = DateTime.now();
  TimeOfDay _waktu = TimeOfDay.now();
  DateTime _endTanggal = DateTime.now();
  TimeOfDay _endWaktu = TimeOfDay.now();


  String _prioritas = "Sedang";
  final List<String> _prioritasList = ["Tinggi", "Sedang", "Rendah"];

  @override
  void initState() {
    super.initState();
    _tanggal = widget.selectedDate ?? DateTime.now();
    _waktu = TimeOfDay.fromDateTime(widget.selectedDate ?? DateTime.now());
    _fetchCategoriesFromDatabase();
  }

  Future<void> _fetchCategoriesFromDatabase() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('categories')
        .select()
        .or('is_global.eq.true,user_id.eq.${user.id}')
        .order('created_at');

    final List<Map<String, dynamic>> dbCategories = (response as List)
        .map((item) => {
              'id': item['id'],
              'name': item['category'],
            })
        .toList();

    setState(() {
      categories = dbCategories;
      if (categories.isNotEmpty) {
        selectedCategory = categories.first['id'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        title: Text(
          "Buat Tugas Baru",
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simpanTugas,
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text("Simpan Tugas", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _judulController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Judul Tugas",
                      hintStyle: TextStyle(color: theme.hintColor),
                    ),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  TextField(
                    controller: _deskripsiController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukkan Deskripsi Tugas Anda (Opsional)",
                      hintStyle: TextStyle(color: theme.hintColor),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildCustomDropdown(
              icon: Icons.category_outlined,
              label: "Kategori",
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  // ✅ fix: hindari crash jika selectedCategory tidak valid
                  value: categories.any((cat) => cat['id'] == selectedCategory)
                      ? selectedCategory
                      : null,
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                  items: [
                    ...categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    const DropdownMenuItem<String>(
                      enabled: false,
                      child: Divider(height: 0),
                    ),
                    DropdownMenuItem<String>(
                      value: _addNewCategoryValue,
                      child: Row(
                        children: [
                          Icon(Icons.add, color: theme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text("Buat Kategori Baru", style: TextStyle(color: theme.primaryColor)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == _addNewCategoryValue) {
                      _showAddCategoryDialog();
                    } else if (val != null) {
                      setState(() => selectedCategory = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(Icons.schedule_outlined, "Waktu Pelaksanaan"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildTimeRow("Starts", _tanggal, _waktu, onTap: _selectDate),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: _buildTimeRow(
                      "Ends",
                      _endTanggal,
                      _endWaktu,
                      onTap: _selectDate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildCustomDropdown(
              icon: Icons.flag_outlined,
              label: "Prioritas",
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _prioritas,
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                  items: _prioritasList.map((val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: val == "Tinggi"
                                ? Colors.red
                                : val == "Sedang"
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Text(val),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _prioritas = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.iconTheme.color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCustomDropdown({required IconData icon, required String label, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(icon, label),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDateTimeChip(String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime date, TimeOfDay time, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: 16)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              _buildDateTimeChip(DateFormat('dd MMM yyyy').format(date)),
              const SizedBox(width: 8),
              _buildDateTimeChip(DateFormat('HH:mm').format(dateTime)),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: newCategoryController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nama kategori'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final supabase = Supabase.instance.client;
                final user = supabase.auth.currentUser;
                final newCategory = newCategoryController.text.trim();

                if (newCategory.isEmpty || user == null) return;

                final alreadyExists = categories.any((cat) =>
                    cat['name'].toString().toLowerCase() == newCategory.toLowerCase());

                if (alreadyExists) {
                  Navigator.pop(context);
                  return;
                }

                final inserted = await supabase.from('categories').insert({
                  'user_id': user.id,
                  'category': newCategory,
                  'is_global': false,
                }).select().single();

                setState(() {
                  categories.add({
                    'id': inserted['id'],
                    'name': inserted['category'],
                  });
                  selectedCategory = inserted['id'];
                });

                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

// GANTI SELURUH FUNGSI INI DI detail_tugas.dart

  Future<void> _selectDate() async {
    // `final picked` tidak lagi diperlukan karena dialog tidak mengembalikan nilai via Navigator.pop
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DateTimePickerDialog(
          initialStartDate: _tanggal,
          initialEndDate: _endTanggal,
          initialStartTime: _waktu,
          initialEndTime: _endWaktu,
          // ✅ PERBAIKI: Sesuaikan urutan parameter dan tipe datanya agar cocok dengan kontrak baru
          onConfirm: (DateTime startDate, TimeOfDay startTime, DateTime endDate, TimeOfDay endTime) {
            
            // Pengecekan null tidak lagi diperlukan karena callback menjamin nilainya.
            // Kita bisa langsung menggunakan nilainya.

            // Tambahan: Validasi agar waktu selesai tidak mendahului waktu mulai
            final startDateTime = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
            final endDateTime = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);

            if (endDateTime.isBefore(startDateTime)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Waktu selesai tidak boleh mendahului waktu mulai.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return; // Jangan update jika tidak valid
            }
            
            setState(() {
              _tanggal = startDate;
              _waktu = startTime;
              _endTanggal = endDate;
              _endWaktu = endTime;
            });
          },
        ),
      ),
    );
  }

  Future<void> _simpanTugas() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final int priorityValue = _prioritas == 'Tinggi'
        ? 3
        : _prioritas == 'Sedang'
            ? 2
            : 1;

    final taskData = {
      'id': uuid,
      'user_id': user.id,
      'title': _judulController.text.trim(),
      'description': _deskripsiController.text.trim(),
      'start_date': DateFormat('yyyy-MM-dd').format(_tanggal),
      'start_time': _formatTimeOfDay(_waktu),
      'end_date': DateFormat('yyyy-MM-dd').format(_endTanggal),
      'end_time': _formatTimeOfDay(_endWaktu),
      'created_at': now.toIso8601String(),
      'updated_at': null,
      'category_id': selectedCategory,
      'is_completed': false,
      'priority': priorityValue,
    };

    try {
      await supabase.from('task').insert(taskData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil disimpan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tugas: $e')),
      );
    }
  }
}

String _formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('HH:mm:ss').format(dt);
}
