import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:cblistify/tema/theme_notifier.dart';
// Model untuk fetch dari Supabase
class TaskItem {
  final String id;
  final String name;
  final String categoryName;

  TaskItem({
    required this.id,
    required this.name,
    required this.categoryName,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      name: json['title'],
      categoryName: json['categories']['category'],
    );
  }
}

class TasksDialog extends StatefulWidget {
  final Function(String?) onTaskSelected;
  final String? selectedTaskName;

  const TasksDialog({
    super.key,
    required this.onTaskSelected,
    this.selectedTaskName,
  });

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  List<TaskItem> _tasks = [];
  bool _isLoading = true;
  String? _tempSelectedTaskName;

  @override
  void initState() {
    super.initState();
    _tempSelectedTaskName = widget.selectedTaskName;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('task')
        .select('id, title, categories(category)')
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    setState(() {
      _tasks = data.map((json) => TaskItem.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  void _applySelection() {
    widget.onTaskSelected(_tempSelectedTaskName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    final Map<String, List<TaskItem>> groupedTasks = {};
    for (var task in _tasks) {
      groupedTasks.putIfAbsent(task.categoryName, () => []).add(task);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Tugas untuk Sesi Pomodoro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ...groupedTasks.entries.map((entry) {
                          return _buildCategorySection(
                            entry.key,
                            entry.value,
                            palette,
                          );
                        }).toList(),
                        _buildClearSelectionTile(),
                      ],
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Pilih Tugas Ini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<TaskItem> tasks,
    ThemePalette palette,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: tasks
                .map((task) => _buildTaskItem(task.name, palette))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTaskItem(String taskName, ThemePalette palette) {
    final bool isSelected = _tempSelectedTaskName == taskName;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () => setState(() => _tempSelectedTaskName = taskName),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          taskName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? palette.base : Colors.black87,
          ),
        ),
        trailing: Radio<String>(
          value: taskName,
          groupValue: _tempSelectedTaskName,
          onChanged: (value) => setState(() => _tempSelectedTaskName = value),
          activeColor: palette.base,
        ),
      ),
    );
  }

  Widget _buildClearSelectionTile() {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () => setState(() => _tempSelectedTaskName = null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.do_not_disturb, color: Colors.grey),
        title: Text(
          "Tidak ada tugas (fokus umum)",
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
