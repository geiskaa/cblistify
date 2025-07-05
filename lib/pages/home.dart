import 'package:flutter/material.dart';
import '../../widgets/custom_navbar.dart'; // Pastikan path ini benar

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _allTasks = [
    {
      'title': 'Belajar Flutter',
      'date': '01 Jun',
      'time': '09:00',
      'isCompleted': true,
      'category': 'STUDY',
    },
    {
      'title': 'Belajar HTML',
      'date': '01 Jun',
      'time': '12:00',
      'isCompleted': false,
      'category': 'STUDY',
    },
  ];

  List<Map<String, dynamic>> _foundTasks = [];
  String _selectedCategory = 'STUDY';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _runFilter('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter(String keyword) {
    List<Map<String, dynamic>> results;
    if (keyword.isEmpty) {
      results =
          _allTasks.where((task) => task['category'] == _selectedCategory).toList();
    } else {
      results = _allTasks
          .where((task) =>
              task['category'] == _selectedCategory &&
              task['title'].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() => _foundTasks = results);
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _runFilter('');
    });
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hello\nUSER NAME',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            // Gunakan MainAxisAlignment.spaceBetween untuk memberi jarak
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryCard('STUDY'),
              _buildCategoryCard('WORK'),
              _buildCategoryCard('SPORT'),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          Text('$_selectedCategory Task\'s',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._foundTasks.map((task) => _buildTaskCard(task)).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title) {
    final count = _allTasks
        .where((task) => task['category'] == title && !task['isCompleted'])
        .length;
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => _changeCategory(title),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDE7ED) : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count Task\'s',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search Task Here ...',
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE7ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task['isCompleted'],
            onChanged: (bool? value) {
              setState(() {
                task['isCompleted'] = value!;
                _runFilter(_searchController.text);
              });
            },
            shape: const CircleBorder(),
            activeColor: const Color(0xFFEA4C89),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(task['date'],
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(task['time'],
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit: ${task['title']}')),
              );
            },
          ),
        ],
      ),
    );
  }
  // --- AKHIR DARI LOGIKA INTERNAL ANDA ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildHomeContent()),
      // 2. HAPUS FLOATING ACTION BUTTON
      // Navigasi sudah ditangani oleh CustomNavBar, jadi FAB ini tidak diperlukan lagi
      // dan akan bertabrakan dengan UI navbar yang baru.
      
      // 3. PERBAIKI PEMANGGILAN CustomNavbar
      // Sekarang kita teruskan currentIndex yang diterima oleh HomePage.
      // Kita gunakan widget.selectedIndex untuk mengaksesnya dari dalam State.
      bottomNavigationBar: CustomNavBar(
        currentIndex: widget.selectedIndex,
      ),
    );
  }
}