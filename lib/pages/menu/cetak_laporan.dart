import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cblistify/tema/theme_notifier.dart';

class CetakLaporanPage extends StatelessWidget {
  const CetakLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Laporan'),
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
              Icon(Icons.print, size: 80, color: palette.darker),
              const SizedBox(height: 20),
              Text(
                'Halaman "Cetak Laporan" masih dalam proses pengembangan 🖨️',
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