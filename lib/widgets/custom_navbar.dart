import 'dart:math' as math;

import 'package:cblistify/pages/home.dart';
import 'package:cblistify/pages/kalender.dart';
import 'package:cblistify/pages/menu.dart';
import 'package:cblistify/pages/pomodoro/pomodoro.dart';
import 'package:cblistify/pages/profil.dart';
import 'package:flutter/material.dart';

// --- Clipper untuk membuat 'lubang' pada navigation bar ---
class CustomNavbar extends CustomClipper<Path> {
  final double holeRadius;
  final double center;

  CustomNavbar({required this.center, required this.holeRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final holeRadiusPadded = holeRadius + 6; // Jarak antara lubang dan ikon

    path.moveTo(0, 0);
    path.lineTo(center - holeRadiusPadded, 0);
    path.arcToPoint(
      Offset(center + holeRadiusPadded, 0),
      radius: Radius.circular(holeRadiusPadded),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final int totalItems = 5;

  // --- Konstanta untuk Ukuran & Styling ---
  // Kita definisikan di sini agar mudah diubah jika perlu.
  static const double _kBarHeight = 60.0;
  static const double _kCircleDiameter = 56.0;
  static const double _kCircleRadius = _kCircleDiameter / 2;
  static const double _kTotalNavBarHeight = 76.0; // _kBarHeight + (_kCircleDiameter / 2) - sedikit offset

  const CustomNavBar({super.key, required this.currentIndex});

  // Logika navigasi ini sudah benar, tidak perlu diubah.
  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    Widget nextPage;
    switch (index) {
      case 0: nextPage = MenuPlaceholderPage(selectedIndex: index); break;
      case 1: nextPage = KalenderPage(selectedIndex: index); break;
      case 2: nextPage = HomePage(selectedIndex: index); break;
      case 3: nextPage = PomodoroPlaceholderPage(selectedIndex: index); break;
      case 4: nextPage = ProfilPage(selectedIndex: index); break;
      default: return;
    }
    Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final itemWidth = size.width / totalItems;
    final activeCenter = (currentIndex * itemWidth) + (itemWidth / 2);

    return Container(
      width: size.width,
      height: _kTotalNavBarHeight,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Bar Putih dengan Lubang (menggunakan Clipper)
          Positioned(
            bottom: 0,
            width: size.width,
            height: _kBarHeight,
            child: ClipPath(
              clipper: CustomNavbar(center: activeCenter, holeRadius: _kCircleRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 2. Barisan Ikon-ikon
          Positioned(
            bottom: 0,
            width: size.width,
            height: _kTotalNavBarHeight,
            child: Row(
              children: [
                _buildNavItem(context, Icons.menu, 'Menu', 0),
                _buildNavItem(context, Icons.calendar_today, 'Kalender', 1),
                _buildNavItem(context, Icons.home_rounded, 'Home', 2),
                _buildNavItem(context, Icons.timer, 'Timer', 3),
                _buildNavItem(context, Icons.person, 'Profil', 4),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Widget Builder yang Diperbarui ---
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;

    // Gunakan Expanded agar setiap item memiliki lebar yang sama
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: isSelected
            // --- TAMPILAN IKON AKTIF (MENONJOL) ---
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align ke atas
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: _kCircleDiameter,
                    height: _kCircleDiameter,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA4C89),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(
                      color: Color(0xFFEA4C89),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            // --- TAMPILAN IKON TIDAK AKTIF (DATAR) ---
            : Container(
                height: _kBarHeight, // Batasi tinggi agar bisa center dengan benar
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Align di tengah bar putih
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.grey, size: 24),
                    const SizedBox(height: 4),
                    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
      ),
    );
  }
}