import 'package:flutter/material.dart';

class Task {
  final String category;
  final String name;

  Task({required this.category, required this.name});
}

class TasksDialog extends StatefulWidget {
  final Function(String?) onTaskSelected; // Callback when a task is selected
  final String? selectedTaskName; // Currently selected task

  const TasksDialog({
    super.key,
    required this.onTaskSelected,
    this.selectedTaskName,
  });

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  // Contoh daftar tugas statis
  final List<Task> _tasks = [
    Task(category: "Study", name: "Belajar Flutter"),
    Task(category: "Study", name: "Belajar HTML"),
    Task(category: "Sport", name: "Jogging"),
    Task(category: "Work", name: "Laporan Bulanan"),
  ];

  String? _tempSelectedTaskName;

  @override
  void initState() {
    super.initState();
    _tempSelectedTaskName = widget.selectedTaskName;
  }

  @override
  Widget build(BuildContext context) {
    // Group tasks by category
    final Map<String, List<Task>> groupedTasks = {};
    for (var task in _tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Tugas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[300],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ...groupedTasks.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key, // Category name
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...entry.value.map((task) {
                      return _buildTaskItem(task.name);
                    }).toList(),
                    const SizedBox(height: 20), // Space after each category
                  ],
                );
              }).toList(),
              // Add a section for "Add Task" if desired
              // TextButton(
              //   onPressed: () {
              //     // TODO: Implement add new task functionality
              //   },
              //   child: Text('Add New Task', style: TextStyle(color: Colors.blue)),
              // )
              // const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink[300],
                      side: BorderSide(color: Colors.pink[300]!, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      widget.onTaskSelected(_tempSelectedTaskName);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(String taskName) {
    final bool isSelected = _tempSelectedTaskName == taskName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelectedTaskName = taskName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[100] : Colors.pink[50], // Highlight if selected
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.pink[300]!, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              taskName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.pink[300], size: 22),
          ],
        ),
      ),
    );
  }
}