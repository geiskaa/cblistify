import 'dart:async';
import 'package:cblistify/pages/menu/menu.dart';
import 'package:cblistify/pages/tugas/buat_tugas.dart';
import 'package:cblistify/pages/tugas/detail_tugas.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  const HomePage({super.key, required this.selectedIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _semuaCategoryId = 'semua-tasks-id';

  List<Map<String, dynamic>> _allTasks = [];
  List<Map<String, dynamic>> _foundTasks = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String _userName = 'Pengguna';

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _mascotAnimationController;
  late Animation<double> _mascotAnimation;
  late Timer _quoteTimer;
  int _currentQuoteIndex = 0;
  final List<Map<String, String>> _quotes = [
    {"text": "Jangan hanya hitung hari, buatlah hari-hari itu berarti.", "author": "- Muhammad Ali"},
    {"text": "Kerja keras mengalahkan bakat saat bakat tidak bekerja keras.", "author": "- Tim Notke"},
    {"text": "Waktu terbaik untuk memulai adalah sekarang.", "author": "- Anonim"}
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAnimations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mascotAnimationController.dispose();
    _quoteTimer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    await Future.wait([_fetchCategories(), _fetchTasks(), _loadUserData()]);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _runFilter('');
      });
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
        final dbCategories = List<Map<String, dynamic>>.from(response);
        final semuaCategory = {'id': _semuaCategoryId, 'category': 'Semua'};
        _categories = [semuaCategory, ...dbCategories];

        if (_selectedCategoryId == null) {
          _selectedCategoryId = _semuaCategoryId; 
        }
      }
    } catch (e) {
      _showErrorSnackBar("Gagal memuat kategori: $e");
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "Pengguna tidak login";

      final response = await Supabase.instance.client
          .from('task') 
          .select()
          .eq('user_id', user.id) 
          .eq('is_completed', false)
          .order('start_date');
      if (mounted) _allTasks = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _showErrorSnackBar("Gagal memuat tugas: $e");
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final profile = await Supabase.instance.client.from('profiles').select('full_name').eq('id', user.id).single();
      if (mounted) _userName = profile['full_name'] ?? 'Pengguna';
    } catch (e) {
      print("Gagal memuat nama pengguna: $e");
    }
  }

  void _runFilter(String keyword) {
    if (_selectedCategoryId == null) return;
    List<Map<String, dynamic>> results;

    if (_selectedCategoryId == _semuaCategoryId) {
      results = keyword.isEmpty
          ? _allTasks 
          : _allTasks.where((task) => task['title'].toLowerCase().contains(keyword.toLowerCase())).toList();
    } 
    else {
      results = keyword.isEmpty
          ? _allTasks.where((task) => task['category_id'] == _selectedCategoryId).toList()
          : _allTasks.where((task) =>
              task['category_id'] == _selectedCategoryId &&
              task['title'].toLowerCase().contains(keyword.toLowerCase())).toList();
    }
    if (mounted) setState(() => _foundTasks = results);
  }

  void _changeCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _searchController.clear();
      _runFilter('');
    });
  }

  Future<void> _handleTaskCompletion(Map<String, dynamic> task) async {
    final bool? confirmed = await _showConfirmationDialog(task['title']);
    if (confirmed == true && mounted) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw "Pengguna tidak login";

        await Supabase.instance.client
            .from('task')
            .update({'is_completed': true, 'updated_at': DateTime.now().toIso8601String()})
            .match({'id': task['id'], 'user_id': user.id}); 

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil diselesaikan!'), backgroundColor: Colors.green),
        );
        await _loadData();
      } catch (e) {
        _showErrorSnackBar("Gagal memperbarui tugas: $e");
      }
    }
  }

  void _startAnimations() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length);
    });
    _mascotAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _mascotAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(CurvedAnimation(parent: _mascotAnimationController, curve: Curves.easeInOutSine));
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  Future<bool?> _showConfirmationDialog(String taskTitle) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesaikan Tugas?'),
        content: Text("Tugas '$taskTitle' akan dipindahkan ke riwayat. Anda yakin?"),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi, $_userName!';
    if (hour < 15) return 'Selamat siang, $_userName!';
    if (hour < 18) return 'Selamat sore, $_userName!';
    return 'Selamat malam, $_userName!';
  }

  String _getMascotImage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'assets/images/maskot_pagi.png';
    if (hour < 15) return 'assets/images/maskot_siang.png';
    if (hour < 18) return 'assets/images/maskot_sore.png';
    return 'assets/images/maskot_malam.png';
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;
    final contrastingColor = _getContrastingTextColor(palette.base);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerMenu(),
      backgroundColor: palette.lighter,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: palette.base))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: palette.base,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildAnimatedHeader(palette, contrastingColor)),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Kategori"),
                        _buildCategoryList(palette),
                        const SizedBox(height: 16),
                        _buildSearchBar(palette),
                        const SizedBox(height: 16),
                        _buildSectionHeader("Tugas Aktif"),
                      ],
                    ),
                  ),
                  _buildTaskList(palette),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BuatTugas()))
            .then((_) => _loadData()),
        backgroundColor: palette.base,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: contrastingColor, size: 30),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: widget.selectedIndex,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _buildAnimatedHeader(ThemePalette palette, Color contrastingColor) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(color: palette.base, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_getGreeting(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: contrastingColor)),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: Text(
                    '"${_quotes[_currentQuoteIndex]["text"]!}"\n- ${_quotes[_currentQuoteIndex]["author"]!}',
                    key: ValueKey<int>(_currentQuoteIndex),
                    style: TextStyle(color: contrastingColor.withOpacity(0.9), height: 1.5, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: AnimatedBuilder(
              animation: _mascotAnimation,
              builder: (context, child) => Transform.translate(offset: Offset(0, _mascotAnimation.value), child: child),
              child: Image.asset(_getMascotImage(), height: 140, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
    );
  }

  Widget _buildCategoryList(ThemePalette palette) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category, palette);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, ThemePalette palette) {
    final int count;
    if (category['id'] == _semuaCategoryId) {
      count = _allTasks.length; 
    } else {
      count = _allTasks.where((task) => task['category_id'] == category['id']).length;
    }
    
    final isSelected = _selectedCategoryId == category['id'];
    final color = isSelected ? palette.base : Colors.white;
    final textColor = isSelected ? _getContrastingTextColor(palette.base) : palette.darker;

    return GestureDetector(
      onTap: () => _changeCategory(category['id']),
      child: Card(
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected ? palette.base.withOpacity(0.4) : Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.only(right: 12),
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$count Tugas", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500)),
              Text(category['category'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemePalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: InputDecoration(
          hintText: 'Cari tugas...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: palette.base, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTaskList(ThemePalette palette) {
    if (_foundTasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            _searchController.text.isEmpty ? "Tidak ada tugas di kategori ini." : "Tugas tidak ditemukan.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 80.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildTaskCard(_foundTasks[index], palette),
          childCount: _foundTasks.length,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, ThemePalette palette) {
    final date = DateTime.parse(task['start_date']);
    final timeString = task['start_time'];
    final time = TimeOfDay(hour: int.parse(timeString.split(':')[0]), minute: int.parse(timeString.split(':')[1]));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _handleTaskCompletion(task),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: palette.base, width: 2)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(DateFormat("dd MMM", 'id_ID').format(date), style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(time.format(context), style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
              onPressed: () {
                if (task['id'] == 'default-task') {
                  _showErrorSnackBar("Tugas contoh tidak bisa diedit.");
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => DetailTugasPage(taskId: task['id'])))
                    .then((_) => _loadData());
              },
            ),
          ],
        ),
      ),
    );
  }
}