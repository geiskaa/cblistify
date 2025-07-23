import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/home/home_page.dart';
import 'package:cblistify/pages/kalender.dart';
import 'package:cblistify/pages/menu/menu.dart';
import 'package:cblistify/pages/pomodoro/pomodoro.dart';
import 'package:cblistify/pages/profil/profil.dart';
import 'package:cblistify/tema/theme_notifier.dart';

class CustomNavbar extends CustomClipper<Path> {
  final double center;
  final double curveWidth = 80;
  final double curveDepth = 30;

  CustomNavbar({required this.center});

  @override
  Path getClip(Size size) {
    final path = Path();
    final itemWidth = size.width / 5;

    path.moveTo(0, 0);

    for (int i = 0; i < 5; i++) {
      final itemCenter = itemWidth * i + itemWidth / 2;
      if ((itemCenter - center).abs() < 1) {
        path.lineTo(itemCenter - curveWidth / 2, 0);
        path.cubicTo(
          itemCenter - curveWidth / 4,
          0,
          itemCenter - curveWidth / 4,
          curveDepth,
          itemCenter,
          curveDepth,
        );
        path.cubicTo(
          itemCenter + curveWidth / 4,
          curveDepth,
          itemCenter + curveWidth / 4,
          0,
          itemCenter + curveWidth / 2,
          0,
        );
      }
    }

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
  final VoidCallback? onMenuTap;
  final int totalItems = 5;

  static const double _kBarHeight = 60.0;
  static const double _kCircleDiameter = 56.0;
  static const double _kTotalNavBarHeight = 76.0;

  const CustomNavBar({super.key, required this.currentIndex, this.onMenuTap,});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      onMenuTap?.call();
      return;
    }
    Widget nextPage;
    switch (index) {
      case 1:
        nextPage = KalenderPage(selectedIndex: index);
        break;
      case 2:
        nextPage = HomePage(selectedIndex: index);
        break;
      case 3:
        nextPage = PomodoroHome(selectedIndex: index);
        break;
      case 4:
        nextPage = ProfilPage(selectedIndex: index);
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
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

    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Container(
      width: size.width,
      height: _kTotalNavBarHeight,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            width: size.width,
            height: _kBarHeight,
            child: ClipPath(
              clipper: CustomNavbar(center: activeCenter),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.base,
                  boxShadow: [
                    BoxShadow(
                      color: palette.darker.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            width: size.width,
            height: _kTotalNavBarHeight,
            child: Row(
              children: [
                _buildNavItem(context, Icons.menu, 'Menu', 0, palette),
                _buildNavItem(
                  context,
                  Icons.calendar_today,
                  'Kalender',
                  1,
                  palette,
                ),
                _buildNavItem(context, Icons.home_rounded, 'Home', 2, palette),
                _buildNavItem(context, Icons.timer, 'Timer', 3, palette),
                _buildNavItem(
                  context,
                  Icons.analytics_outlined,
                  'Analisis',
                  4,
                  palette,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    palette,
  ) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment:
              isSelected ? MainAxisAlignment.start : MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? _kCircleDiameter : 40,
              height: isSelected ? _kCircleDiameter : 40,
              decoration: BoxDecoration(
                color: isSelected ? palette.darker : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Icon(
                icon,
                size: isSelected ? 28 : 24,
                color:
                    isSelected ? Colors.white : palette.darker.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? palette.darker
                        : palette.darker.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}