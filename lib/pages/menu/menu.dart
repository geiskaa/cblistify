import 'package:cblistify/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/pages/menu/cetak_laporan.dart';
import 'package:cblistify/home/home_page.dart';
import 'package:cblistify/pages/menu/kategori.dart';
import 'package:cblistify/pages/menu/notifikasi.dart';
import 'package:cblistify/pages/menu/pengaturan.dart';
import 'package:cblistify/pages/profil/profil.dart';
import 'package:cblistify/tema/tema_page.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Drawer(
      child: Material(
        color: Theme.of(context).canvasColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildGreetingHeader(palette),
            _buildDrawerItem(
              icon: Icons.person,
              text: 'My Profile',
              onTap: () => _navigateAfterClose(context, const ProfilPage(selectedIndex: 4)),
              iconColor: palette.darker,
            ),
            _buildDrawerItem(
              icon: Icons.home,
              text: 'Home',
              onTap: () => _navigateAfterClose(context, const HomePage(selectedIndex: 2)),
              iconColor: palette.darker,
            ),
            _buildDrawerItem(
              icon: Icons.category,
              text: 'Kategori',
              onTap: () => _navigateAfterClose(context, const KategoriPage()),
              iconColor: palette.darker,
            ),
            _buildDrawerItem(
              icon: Icons.print,
              text: 'Cetak Laporan',
              onTap: () => _navigateAfterClose(context, const CetakLaporanPage()),
              iconColor: palette.darker,
            ),
            _buildDrawerItem(
              icon: Icons.notifications_none,
              text: 'Notifikasi',
              onTap: () => _navigateAfterClose(context, const NotifikasiPage()),
              iconColor: palette.darker,
            ),
            _buildDrawerItem(
              icon: Icons.color_lens,
              text: 'Tema',
              onTap: () => _navigateAfterClose(context, TemaPage()),
              iconColor: palette.darker,
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              text: 'Pengaturan',
              onTap: () => _navigateAfterClose(context, const PengaturanPage()),
              iconColor: palette.darker,
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        final palette = Provider.of<ThemeNotifier>(parentContext, listen: false).palette;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop(); 

                  final response = await Supabase.instance.client.auth.signOut();

                  Navigator.pushAndRemoveUntil(
                    parentContext,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Gagal logout: $e')),
                  );
                }
              },

            ),
          ],
        );
      },
    );
  }

  void _navigateAfterClose(BuildContext context, Widget? page) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (page != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    });
  }

  Widget _buildGreetingHeader(ThemePalette palette) {
    final hour = DateTime.now().hour;
    String greeting;
    String imagePath;

    if (hour >= 5 && hour < 12) {
      greeting = 'Selamat pagi!';
      imagePath = 'assets/images/maskot_pagi.png';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Selamat siang!';
      imagePath = 'assets/images/maskot_siang.png';
    } else if (hour >= 17 && hour < 20) {
      greeting = 'Selamat sore!';
      imagePath = 'assets/images/maskot_sore.png';
    } else {
      greeting = 'Selamat malam!';
      imagePath = 'assets/images/maskot_malam.png';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.lighter,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, height: 64, width: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Cara terbaik untuk memprediksi masa depan adalah dengan menciptakannya.",
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "- Peter Drucker",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      color: Colors.black54,
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(color: iconColor),
      ),
      onTap: onTap,
    );
  }
}
