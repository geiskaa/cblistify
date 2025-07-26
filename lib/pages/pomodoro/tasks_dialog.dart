import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksDialog extends StatefulWidget {
  final Function(String? taskId, String? taskName) onTaskSelected;
  final String? selectedTaskId;

  const TasksDialog({
    super.key,
    required this.onTaskSelected,
    this.selectedTaskId,
  });

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  String? _tempSelectedTaskId;
  String? _tempSelectedTaskName;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _fetchTasksFromDatabase();
    _tempSelectedTaskId = widget.selectedTaskId;
  }

  Future<List<Map<String, dynamic>>> _fetchTasksFromDatabase() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw "Pengguna tidak ditemukan";

      final response = await supabase
          .from('task')
          .select('id, title, categories(category)')
          .eq('user_id', user.id)
          .eq('is_completed', false)
          .order('created_at', ascending: false);

      final fetchedTasks = List<Map<String, dynamic>>.from(response);

      if (widget.selectedTaskId != null && fetchedTasks.isNotEmpty) {
        final task = fetchedTasks.firstWhere((t) => t['id'] == widget.selectedTaskId, orElse: () => {});
        if (task.isNotEmpty) {
          _tempSelectedTaskName = task['title'];
        }
      }
      return fetchedTasks;
    } catch (e) {
      print("Error fetching tasks: $e");
      throw "Gagal memuat tugas.";
    }
  }

  void _applySelection() {
    widget.onTaskSelected(_tempSelectedTaskId, _tempSelectedTaskName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Container(
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Pilih Tugas untuk Sesi Pomodoro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 24),
            Flexible(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Tidak ada tugas aktif yang tersedia.", style: TextStyle(color: Colors.grey)));

                  final tasks = snapshot.data!;
                  final Map<String, List<Map<String, dynamic>>> groupedTasks = {};
                  for (var task in tasks) {
                    final categoryName = task['categories']?['category'] ?? 'Tanpa Kategori';
                    if (!groupedTasks.containsKey(categoryName)) groupedTasks[categoryName] = [];
                    groupedTasks[categoryName]!.add(task);
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      ...groupedTasks.entries.map((entry) => _buildCategorySection(entry.key, entry.value, palette)),
                      _buildClearSelectionTile(),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applySelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.base,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_tempSelectedTaskId == null ? 'Lanjutkan Tanpa Tugas' : 'Pilih Tugas Ini', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> tasks, ThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(category.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(children: tasks.map((task) => _buildTaskItem(task, palette)).toList()),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, ThemePalette palette) {
    final String taskId = task['id'];
    final String taskName = task['title'];
    final bool isSelected = _tempSelectedTaskId == taskId;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () => setState(() {
          _tempSelectedTaskId = taskId;
          _tempSelectedTaskName = taskName;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(taskName, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? palette.base : Colors.black87)),
        trailing: Radio<String>(
          value: taskId,
          groupValue: _tempSelectedTaskId,
          onChanged: (value) => setState(() {
            _tempSelectedTaskId = value;
            _tempSelectedTaskName = taskName;
          }),
          activeColor: palette.base,
        ),
      ),
    );
  }

  Widget _buildClearSelectionTile() {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () => setState(() {
          _tempSelectedTaskId = null;
          _tempSelectedTaskName = null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.grey),
        title: Text("Tidak ada tugas (fokus umum)", style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
      ),
    );
  }
}