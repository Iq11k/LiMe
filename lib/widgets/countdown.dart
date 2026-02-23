import 'dart:async';
import 'package:flutter/material.dart';

class SimpleCountdown extends StatefulWidget {
  final DateTime targetTime;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? fontColor;

  const SimpleCountdown({
    super.key,
    required this.targetTime,
    this.fontSize,
    this.fontWeight,
    this.fontColor,
  });

  @override
  State<SimpleCountdown> createState() => _SimpleCountdownState();
}

class _SimpleCountdownState extends State<SimpleCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final now = DateTime.now();
    final diff = widget.targetTime.difference(now);

    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });

    if (diff.isNegative) {
      _timer?.cancel();
    }
  }

  String _format(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    return "$hours Jam $minutes Menit";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(_remaining),
      style: TextStyle(
        fontSize: widget.fontSize ?? 14,
        fontWeight: widget.fontWeight ?? FontWeight.bold,
        color: widget.fontColor ?? Colors.black,
      ),
    );
  }
}
