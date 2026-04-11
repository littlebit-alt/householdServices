import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    boxShadow: [BoxShadow(color: const Color(0xFF00D4FF).withOpacity(0.2), blurRadius: 20)],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Image.asset('lib/asset/logo.png', fit: BoxFit.cover),
  ),
),
              const SizedBox(height: 32),
              const Text('Who are\nyou?', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.1, letterSpacing: -1)),
              const SizedBox(height: 12),
              Text('Choose how you want to use HouseServ', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
              const Spacer(),

              // Client Card
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0055AA)]),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('I\'m a Client', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Find and book home services', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Provider Card
              GestureDetector(
                onTap: () => context.go('/provider-login'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00FFB3).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(colors: [Color(0xFF00FFB3), Color(0xFF00AA77)]),
                        ),
                        child: const Icon(Icons.home_repair_service_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('I\'m a Provider', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Offer your services to clients', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}