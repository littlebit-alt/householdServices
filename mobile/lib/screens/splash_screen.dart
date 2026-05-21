import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthService>();
    while (!auth.loaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    NotificationService.setContext(context);
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, auth.isProvider ? '/provider/home' : '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: const Color(0xFF0891B2).withOpacity(0.25), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset('lib/asset/logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('ServeMe', style: TextStyle(color: Color(0xFF1E293B), fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Services at your fingertips', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}