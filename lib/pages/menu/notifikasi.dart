import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/tema/theme_notifier.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: palette.base,
        foregroundColor: palette.darker,
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 80, color: palette.darker),
              const SizedBox(height: 20),
              Text(
                'Halaman "Notifikasi" masih dalam proses pengembangan 🔔',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: palette.darker,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Stay tuned yaa! Fitur ini akan segera hadir untukmu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: palette.base),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
