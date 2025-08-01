import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    Timer(const Duration(seconds: 2), widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A0572),
              Color(0xFFC72C39),
              Color(0xFF6A0572),
            ],
          ),
        ),
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: const Icon(
              Icons.graphic_eq,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
