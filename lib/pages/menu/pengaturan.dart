import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/tema/theme_notifier.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      backgroundColor: palette.lighter,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: palette.base,
        foregroundColor: palette.darker,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 80, color: palette.darker),
              const SizedBox(height: 20),
              Text(
                'Halaman "Pengaturan" masih dalam proses pengembangan ⚙️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: palette.darker),
              ),
              const SizedBox(height: 12),
              Text(
                'Stay tuned yaa! Fitur ini akan segera hadir untukmu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: palette.darker.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}