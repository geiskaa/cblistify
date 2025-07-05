import 'package:flutter/material.dart';

// Callback function to return updated settings
typedef SettingsCallback = void Function({
  int? pomodoroDuration,
  int? shortBreakDuration,
  int? longBreakDuration,
  int? sets,
});

class SettingsDialog extends StatefulWidget {
  final int initialPomodoroDuration;
  final int initialShortBreakDuration;
  final int initialLongBreakDuration;
  final int initialSets;
  final SettingsCallback onApply;

  const SettingsDialog({
    super.key,
    required this.initialPomodoroDuration,
    required this.initialShortBreakDuration,
    required this.initialLongBreakDuration,
    required this.initialSets,
    required this.onApply,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _pomodoroController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;
  late int _currentSets;

  @override
  void initState() {
    super.initState();
    _pomodoroController = TextEditingController(text: (widget.initialPomodoroDuration ~/ 60).toString());
    _shortBreakController = TextEditingController(text: (widget.initialShortBreakDuration ~/ 60).toString());
    _longBreakController = TextEditingController(text: (widget.initialLongBreakDuration ~/ 60).toString());
    _currentSets = widget.initialSets;
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[300],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Atur Waktu (Menit)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInputField(
                      controller: _pomodoroController,
                      label: 'Pomodoro',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeInputField(
                      controller: _shortBreakController,
                      label: 'Jeda Singkat',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeInputField(
                      controller: _longBreakController,
                      label: 'Jeda Panjang',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Jumlah Set',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _currentSets.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink[300],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _currentSets++;
                            });
                          },
                          child: Icon(Icons.arrow_drop_up, color: Colors.pink[300]),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_currentSets > 1) _currentSets--;
                            });
                          },
                          child: Icon(Icons.arrow_drop_down, color: Colors.pink[300]),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink[300],
                        side: BorderSide(color: Colors.pink[300]!, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final int? pomodoro = int.tryParse(_pomodoroController.text);
                        final int? shortBreak = int.tryParse(_shortBreakController.text);
                        final int? longBreak = int.tryParse(_longBreakController.text);

                        widget.onApply(
                          pomodoroDuration: (pomodoro != null) ? pomodoro * 60 : null,
                          shortBreakDuration: (shortBreak != null) ? shortBreak * 60 : null,
                          longBreakDuration: (longBreak != null) ? longBreak * 60 : null,
                          sets: _currentSets,
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 5),
        Container(
          height: 50, // Fixed height for consistency
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none, // Remove default border
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true, // Make the input smaller
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.pink[300],
            ),
            validator: (value) {
              if (value == null || value.isEmpty || int.tryParse(value) == null) {
                return ''; // Return empty string for subtle validation hint
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}