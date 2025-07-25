import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/tema/theme_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef SettingsCallback = void Function({
  required int pomodoroDuration,
  required int shortBreakDuration,
  required int longBreakDuration,
  required int sets,
  required int cycles,
});

class SettingsDialog extends StatefulWidget {
  final int initialPomodoroDuration;
  final int initialShortBreakDuration;
  final int initialLongBreakDuration;
  final int initialSets;
  final int initialCycles;
  final SettingsCallback onApply;

  const SettingsDialog({
    super.key,
    required this.initialPomodoroDuration,
    required this.initialShortBreakDuration,
    required this.initialLongBreakDuration,
    required this.initialSets,
    required this.initialCycles,
    required this.onApply,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _pomodoroController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;
  late TextEditingController _setsController;
  late TextEditingController _cyclesController;

  @override
  void initState() {
    super.initState();
    _pomodoroController = TextEditingController(text: (widget.initialPomodoroDuration ~/ 60).toString());
    _shortBreakController = TextEditingController(text: (widget.initialShortBreakDuration ~/ 60).toString());
    _longBreakController = TextEditingController(text: (widget.initialLongBreakDuration ~/ 60).toString());
    _setsController = TextEditingController(text: widget.initialSets.toString());
    _cyclesController = TextEditingController(text: widget.initialCycles.toString());
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    _setsController.dispose();
    _cyclesController.dispose();
    super.dispose();
  }

  void _applyChanges() {
    final pomodoroMins = int.tryParse(_pomodoroController.text) ?? 25;
    final shortBreakMins = int.tryParse(_shortBreakController.text) ?? 5;
    final longBreakMins = int.tryParse(_longBreakController.text) ?? 15;
    final sets = int.tryParse(_setsController.text) ?? 4;
    final cycles = int.tryParse(_cyclesController.text) ?? 1;

    widget.onApply(
      pomodoroDuration: pomodoroMins * 60,
      shortBreakDuration: shortBreakMins * 60,
      longBreakDuration: longBreakMins * 60,
      sets: sets,
      cycles: cycles,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: const Center(
        child: Text('Pengaturan Pomodoro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDurationSetter(label: 'Durasi Fokus', controller: _pomodoroController, palette: palette),
            const Divider(height: 24),
            _buildDurationSetter(label: 'Jeda Singkat', controller: _shortBreakController, palette: palette),
            const Divider(height: 24),
            _buildDurationSetter(label: 'Jeda Panjang', controller: _longBreakController, palette: palette),
            const Divider(height: 24),
            _buildDurationSetter(label: 'Set per Siklus', controller: _setsController, isTime: false, palette: palette),
            const Divider(height: 24),
            _buildDurationSetter(label: 'Jumlah Siklus', controller: _cyclesController, isTime: false, palette: palette),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Batal', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _applyChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.base,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSetter({required String label, required TextEditingController controller, bool isTime = true, required ThemePalette palette}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStepperButton(
              icon: Icons.remove,
              onPressed: () {
                int currentValue = int.tryParse(controller.text) ?? 1;
                if (currentValue > 1) controller.text = (currentValue - 1).toString();
              },
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  suffixText: isTime ? ' min' : '',
                  suffixStyle: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            _buildStepperButton(
              icon: Icons.add,
              onPressed: () {
                int currentValue = int.tryParse(controller.text) ?? 0;
                controller.text = (currentValue + 1).toString();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }
}