import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _timeout;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _openLogin();
      });
    // Keep startup usable even if the animation cannot load.
    _timeout = Timer(const Duration(seconds: 8), _openLogin);
  }

  void _openLogin() {
    if (!mounted || _finished) return;
    _finished = true;
    _timeout.cancel();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _timeout.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Center(
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller,
              repeat: false,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).width * 422 / 964,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                if (!mounted || _finished) return;
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _openLogin(),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
