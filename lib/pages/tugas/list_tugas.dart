import 'package:cblistify/pages/tugas/buat_tugas.dart';
import 'package:cblistify/pages/tugas/detail_tugas.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListTugasPage extends StatefulWidget {
  const ListTugasPage({Key? key}) : super(key: key);

  @override
  _ListTugasPageState createState() => _ListTugasPageState();
}

class _ListTugasPageState extends State<ListTugasPage> {
  List<Map<String, dynamic>> _tugasList = [];

  @override
  void initState() {
    super.initState();
    fetchTugas();
  }

  Future<void> fetchTugas() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('todos')
        .select('id, judul, prioritas, tanggal')
        .order('tanggal', ascending: true);

    setState(() {
      _tugasList = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuatTugas()),
              );
              fetchTugas(); 
            },
          )
        ],
      ),
      body: _tugasList.isEmpty
          ? const Center(child: Text('Belum ada tugas.'))
          : ListView.builder(
              itemCount: _tugasList.length,
              itemBuilder: (context, index) {
                final tugas = _tugasList[index];

                return ListTile(
                  title: Text(tugas['judul'] ?? 'Tanpa Judul'),
                  subtitle: Text('Prioritas: ${tugas['prioritas']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTugasPage(
                          taskId: tugas['id'], 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
