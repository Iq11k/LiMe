import 'package:doku/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _counter = 0;
  int? _target;
  final TextEditingController _targetController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _targetController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _notifikasi() async {
    try {
      await _audioPlayer.setAsset('assets/notif.wav');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    if (_target != null && _counter == _target) {
      _notifikasi();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎯 Target $_target tercapai!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: const Color(0xFFC4F000),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _decrementCounter() {
    if (_counter <= 0) return;
    setState(() {
      _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _setTarget(String value) {
    setState(() {
      _target = int.tryParse(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool targetReached = _target != null && _counter >= _target!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: GlassBox(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    onChanged: _setTarget,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan Target',
                      hintStyle: GoogleFonts.poppins(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.flag_rounded,
                        color: Color(0xFFC4F000),
                      ),
                      suffixIcon: _targetController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                _targetController.clear();
                                setState(() => _target = null);
                              },
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFC4F000),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFC4F000),
                          width: 2.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_target != null)
                  Text(
                    'Target: $_target',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: targetReached
                          ? const Color(0xFFC4F000)
                          : Colors.blueGrey,
                    ),
                  ),
                Text(
                  '$_counter',
                  style: GoogleFonts.poppins(
                    fontSize: 78,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4F000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _incrementCounter,
                    icon: const Icon(
                      Icons.add,
                      size: 48,
                      fontWeight: FontWeight.w700,
                    ),
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 100),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _decrementCounter,
                        icon: const Icon(
                          Icons.remove,
                          size: 48,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC4F000),
                        ),
                        color: Colors.black,
                      ),
                      IconButton(
                        onPressed: _resetCounter,
                        icon: const Icon(
                          Icons.refresh,
                          size: 48,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC4F000),
                        ),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
