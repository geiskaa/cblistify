import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cblistify/pages/menu/menu.dart';
import 'package:cblistify/pages/tugas/buat_tugas.dart';
import 'package:cblistify/pages/tugas/detail_tugas.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import '../../../widgets/custom_navbar.dart';
import 'package:cblistify/tema/theme_notifier.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({super.key, required this.selectedIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final supabase = Supabase.instance.client;

  List<dynamic> _allTasks = [];
  List<dynamic> _foundTasks = [];
  List<Map<String, dynamic>> _categories = [];

  String _selectedCategory = '';
  String _userName = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCategories();
    _fetchTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final profile = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .single();

    if (mounted) {
      setState(() {
        _userName = profile['full_name'] ?? '';
      });
    }
  }

  Future<void> _fetchCategories() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('categories')
        .select()
        .or('is_global.eq.true,user_id.eq.${user.id}');

    setState(() {
      _categories = List<Map<String, dynamic>>.from(response);
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['id'];
      }
    });
  }

  Future<void> _fetchTasks() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('task')
        .select()
        .eq('user_id', user.id)
        .order('start_date');

    setState(() {
      _allTasks = response;
      _runFilter('');
    });
  }

  void _runFilter(String keyword) {
    final results = keyword.isEmpty
        ? _allTasks.where((task) =>
            task['category_id'] == _selectedCategory &&
            task['is_completed'] == false).toList()
        : _allTasks.where((task) =>
            task['category_id'] == _selectedCategory &&
            task['is_completed'] == false &&
            (task['title'] as String).toLowerCase().contains(keyword.toLowerCase())).toList();

    setState(() => _foundTasks = results);
  }

  void _changeCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
      _searchController.clear();
      _runFilter('');
    });
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, ThemePalette palette) {
    final categoryId = category['id'];
    final categoryName = category['category'];
    final count = _allTasks
        .where((task) => task['category_id'] == categoryId && task['is_completed'] == false)
        .length;
    final isSelected = _selectedCategory == categoryId;

    return GestureDetector(
      onTap: () => _changeCategory(categoryId),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? palette.lighter : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count Task\'s',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(categoryName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemePalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: palette.lighter,
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

  Widget _buildTaskCard(Map<String, dynamic> task, ThemePalette palette) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: palette.lighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task['is_completed'] ?? false,
            onChanged: (bool? value) async {
              await supabase
                  .from('task')
                  .update({'is_completed': value})
                  .eq('id', task['id']);

              _fetchTasks(); // refresh
            },
            shape: const CircleBorder(),
            activeColor: palette.base,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(task['start_date'] ?? '',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(task['start_time'] ?? '',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailTugasPage(taskId: task['id']),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello\n$_userName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildCategoryCard(cat, palette),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchBar(palette),
          const SizedBox(height: 20),
          const Text("Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._foundTasks.map((task) => _buildTaskCard(task, palette)).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: palette.lighter,
      appBar: AppBar(
        title: const Text("Tugas Saya"),
        backgroundColor: palette.base,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      drawer: const DrawerMenu(),
      body: _buildHomeContent(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuatTugas(selectedDate: DateTime.now()),
            ),
          ).then((_) => _fetchTasks()); // refresh setelah tambah
        },
        backgroundColor: palette.base,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: widget.selectedIndex,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }
}
