import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatTugasPage extends StatefulWidget {
  final bool isCompleted; 
  const RiwayatTugasPage({super.key, required this.isCompleted});

  @override
  State<RiwayatTugasPage> createState() => _RiwayatTugasPageState();
}

class _RiwayatTugasPageState extends State<RiwayatTugasPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('task')
        .select()
        .eq('user_id', user.id)
        .eq('is_completed', widget.isCompleted)
        .order('updated_at');

    setState(() {
      _tasks = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCompleted ? "Tugas Selesai" : "Tugas Tertunda";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text("${task['start_date']} - ${task['start_time']}"),
            trailing: widget.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.pending_actions, color: Colors.orange),
          );
        },
      ),
    );
  }
}
