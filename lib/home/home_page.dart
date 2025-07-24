import 'dart:async';
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final supabase = Supabase.instance.client;

  List<dynamic> _allTasks = [];
  List<dynamic> _foundTasks = [];
  List<Map<String, dynamic>> _categories = [];

  String _selectedCategory = '';
  String _userName = '';
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _mascotAnimation;
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> _quotes = [
    {
      "text": "Kerja keras mengalahkan bakat saat bakat tidak bekerja keras.",
      "author": "- Tim Notke"
    },
    {
      "text": "Kebiasaan kecil menciptakan hasil besar.",
      "author": "- James Clear"
    },
    {
      "text": "Waktu terbaik untuk memulai adalah sekarang.",
      "author": "- Anonim"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCategories();
    _fetchTasks();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _mascotAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startQuoteRotation();
  }

  void _startQuoteRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return false;
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        ? _allTasks
            .where((task) =>
                task['category_id'] == _selectedCategory &&
                task['is_completed'] == false)
            .toList()
        : _allTasks
            .where((task) =>
                task['category_id'] == _selectedCategory &&
                task['is_completed'] == false &&
                (task['title'] as String)
                    .toLowerCase()
                    .contains(keyword.toLowerCase()))
            .toList();

    setState(() => _foundTasks = results);
  }

  void _changeCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
      _searchController.clear();
      _runFilter('');
    });
  }

  Future<bool?> _showConfirmationDialog(String taskTitle) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Selesaikan Tugas?'),
        content: Text(
          "Tugas '$taskTitle' akan dipindahkan ke riwayat. Anda yakin?",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesaikan'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  void _handleTaskCompletion(Map<String, dynamic> task) async {
    final bool? confirmed = await _showConfirmationDialog(task['title']);
    if (confirmed == true) {
      setState(() {
        task['is_completed'] = true;
        _runFilter(_searchController.text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas dipindahkan ke riwayat.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, ThemePalette palette) {
    final categoryId = category['id'];
    final categoryName = category['category'];
    final count = _allTasks
        .where((task) =>
            task['category_id'] == categoryId && task['is_completed'] == false)
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi!';
    if (hour < 15) return 'Selamat siang!';
    if (hour < 18) return 'Selamat sore!';
    return 'Selamat malam!';
  }

  String _getMascotImage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'assets/images/maskot_pagi.png';
    if (hour < 15) return 'assets/images/maskot_siang.png';
    if (hour < 18) return 'assets/images/maskot_sore.png';
    return 'assets/images/maskot_malam.png';
  }

  Widget _buildAnimatedHeader(ThemePalette palette) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 70,
            left: 15,
            child: AnimatedBuilder(
              animation: _mascotAnimation,
              builder: (context, child) =>
                  Transform.translate(offset: Offset(0, _mascotAnimation.value), child: child),
              child: Image.asset(
                _getMascotImage(),
                height: 130,
                width: 130,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.sentiment_very_satisfied,
                  size: 120,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 175,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: RichText(
                    key: ValueKey<int>(_currentQuoteIndex),
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                      children: [
                        TextSpan(
                          text: '"${_quotes[_currentQuoteIndex]["text"]!}"\n',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(text: '\n'),
                        TextSpan(
                          text: _quotes[_currentQuoteIndex]["author"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

              _fetchTasks();
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
          _buildAnimatedHeader(palette),
          const SizedBox(height: 20),
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
          ).then((_) => _fetchTasks());
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
