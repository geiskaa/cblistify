import 'package:cblistify/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';

class MenuPlaceholderPage extends StatelessWidget {
  final int selectedIndex;

  const MenuPlaceholderPage({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Halaman Menu')),
      bottomNavigationBar: CustomNavBar(currentIndex: selectedIndex),
    );
  }
}

