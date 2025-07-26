import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class TemaPage extends StatelessWidget {
  TemaPage({super.key});

  final List<Color> colorOptions = [
    const Color.fromARGB(255, 231, 180, 197)!,
    const Color.fromARGB(255, 228, 189, 235)!,
    const Color.fromARGB(255, 219, 211, 71)!,
    const Color.fromARGB(255, 113, 207, 116)!,
    const Color.fromARGB(255, 136, 177, 211)!,
    const Color.fromARGB(255, 231, 133, 67)!,
    const Color.fromARGB(255, 239, 107, 107)!,
    const Color.fromARGB(255, 129, 107, 63)!,
  ];

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tema"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Warna", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: colorOptions.map((color) {
                return GestureDetector(
                  onTap: () {
                    themeNotifier.setThemeColor(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text("Tekstur", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(6, (index) {
                return Container(
                  width: 80,
                  height: 40,
                  color: Colors.grey[300],
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text("Gambar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(9, (index) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
