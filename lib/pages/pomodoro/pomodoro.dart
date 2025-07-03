import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';

class PomodoroPlaceholderPage extends StatelessWidget {
  final int selectedIndex;
  const PomodoroPlaceholderPage({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Halaman Pomodoro (belum tersedia)', style: TextStyle(fontSize: 20))),
      bottomNavigationBar: CustomNavBar(currentIndex: selectedIndex),
    );
  }
}
