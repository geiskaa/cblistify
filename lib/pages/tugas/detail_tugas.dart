// lib/pages/tugas/detail_tugas.dart

import 'package:cblistify/pages/tugas/setdate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailTugasPage extends StatefulWidget {
  final String taskId;
  const DetailTugasPage({super.key, required this.taskId});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  DateTime _tanggal = DateTime.now();
  TimeOfDay _waktu = TimeOfDay.now();
  DateTime _endTanggal = DateTime.now();
  TimeOfDay _endWaktu = TimeOfDay.now();

  // ✅ DIUBAH: dari Set<String> menjadi String
  String _prioritas = "Sedang";
  final List<String> _prioritasList = ["Tinggi", "Sedang", "Rendah"];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_fetchTaskDetails(), _fetchCategories()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final response =
          await Supabase.instance.client
              .from('task')
              .select()
              .eq('id', widget.taskId)
              .single();

      if (mounted) {
        setState(() {
          _judulController.text = response['title'] ?? '';
          _deskripsiController.text = response['description'] ?? '';
          _tanggal = DateTime.parse(response['start_date']);
          _waktu = _parseTime(response['start_time']);
          _endTanggal = DateTime.parse(response['end_date']);
          _endWaktu = _parseTime(response['end_time']);
          _selectedCategoryId = response['category_id'];

          // ✅ DIUBAH: Konversi nilai prioritas dari integer ke String
          _prioritas = _mapPriorityIntToString(response['priority']);
        });
      }
    } catch (e) {
      _showErrorSnackBar("Gagal memuat detail tugas: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "Pengguna tidak login";

      final response = await Supabase.instance.client
          .from('categories')
          .select()
          .or('is_global.eq.true,user_id.eq.${user.id}')
          .order('created_at');

      if (mounted) {
        // ✅ DISESUAIKAN: Key diubah agar cocok dengan widget builder
        final List<Map<String, dynamic>> dbCategories =
            (response as List)
                .map(
                  (item) => {
                    'id': item['id'],
                    'name': item['category'], // Menggunakan key 'name'
                  },
                )
                .toList();
        setState(() => _categories = dbCategories);
      }
    } catch (e) {
      _showErrorSnackBar("Gagal memuat kategori: $e");
    }
  }

  Future<void> _updateTask() async {
    if (_judulController.text.trim().isEmpty) {
      _showErrorSnackBar("Judul tugas tidak boleh kosong.");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "Pengguna tidak login";

      // ✅ DIUBAH: Logika konversi prioritas disamakan dengan buat_tugas.dart
      final int priorityValue =
          _prioritas == 'Tinggi'
              ? 3
              : _prioritas == 'Sedang'
              ? 2
              : 1;

      final updatedData = {
        'title': _judulController.text.trim(),
        'description': _deskripsiController.text.trim(),
        'start_date': DateFormat('yyyy-MM-dd').format(_tanggal),
        'start_time': _formatTimeOfDay(_waktu),
        'end_date': DateFormat('yyyy-MM-dd').format(_endTanggal),
        'end_time': _formatTimeOfDay(_endWaktu),
        'category_id': _selectedCategoryId,
        'priority': priorityValue,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('task').update(updatedData).match({
        'id': widget.taskId,
        'user_id': user.id,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Kirim sinyal sukses
    } catch (e) {
      _showErrorSnackBar("Gagal memperbarui tugas: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTask() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Hapus Tugas?"),
            content: const Text(
              "Tindakan ini tidak dapat diurungkan. Anda yakin ingin menghapus tugas ini?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Hapus"),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        setState(() => _isSaving = true);
        await Supabase.instance.client
            .from('task')
            .delete()
            .eq('id', widget.taskId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar("Gagal menghapus tugas: $e");
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  // --- Helper Functions ---

  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  String _mapPriorityIntToString(int priority) {
    if (priority >= 3) return "Tinggi";
    if (priority == 2) return "Sedang";
    return "Rendah";
  }

  // ✅ DIUBAH: Nama fungsi disamakan dengan buat_tugas.dart, logika di dalamnya sudah benar
  Future<void> _selectDate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => DateTimePickerDialog(
              initialStartDate: _tanggal,
              initialEndDate: _endTanggal,
              initialStartTime: _waktu,
              initialEndTime: _endWaktu,
              onConfirm: (
                DateTime startDate,
                TimeOfDay startTime,
                DateTime endDate,
                TimeOfDay endTime,
              ) {
                final startDateTime = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day,
                  startTime.hour,
                  startTime.minute,
                );
                final endDateTime = DateTime(
                  endDate.year,
                  endDate.month,
                  endDate.day,
                  endTime.hour,
                  endTime.minute,
                );

                if (endDateTime.isBefore(startDateTime)) {
                  _showErrorSnackBar(
                    'Waktu selesai tidak boleh mendahului waktu mulai.',
                  );
                  return;
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

  void _showErrorSnackBar(String message) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(dt);
  }

  // --- WIDGET BUILDER BARU (Dicopy dari BuatTugas) ---

  @override
  Widget build(BuildContext context) {
    // ✅ DIUBAH: Menggunakan Theme.of(context) agar konsisten
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Detail Tugas",
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTask,
              tooltip: "Hapus Tugas",
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _updateTask,
        backgroundColor: _isSaving ? Colors.grey : theme.primaryColor,
        icon:
            _isSaving
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.save_outlined, color: Colors.white),
        label: Text(
          _isSaving ? "Menyimpan..." : "Simpan Perubahan",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul & Deskripsi
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          TextField(
                            controller: _deskripsiController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  "Masukkan Deskripsi Tugas Anda (Opsional)",
                              hintStyle: TextStyle(color: theme.hintColor),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kategori
                    _buildCustomDropdown(
                      icon: Icons.category_outlined,
                      label: "Kategori",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              _categories.any(
                                    (cat) => cat['id'] == _selectedCategoryId,
                                  )
                                  ? _selectedCategoryId
                                  : null,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 16,
                          ),
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['id'],
                                  child: Text(category['name']),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedCategoryId = val);
                          },
                          hint: const Text("Pilih Kategori"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Waktu Pelaksanaan
                    _buildSectionHeader(
                      Icons.schedule_outlined,
                      "Waktu Pelaksanaan",
                    ),
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
                            child: _buildTimeRow(
                              "Starts",
                              _tanggal,
                              _waktu,
                              onTap: _selectDate,
                            ),
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

                    // Prioritas
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
                          items:
                              _prioritasList.map((val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 12,
                                        color:
                                            val == "Tinggi"
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
                    const SizedBox(height: 100),
                  ],
                ),
              ),
    );
  }

  // --- Widget Builder Helpers (Dicopy dari BuatTugas) ---

  Widget _buildSectionHeader(IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.iconTheme.color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDropdown({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
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

  Widget _buildTimeRow(
    String label,
    DateTime date,
    TimeOfDay time, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

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
}
