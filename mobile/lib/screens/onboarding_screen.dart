import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.home_repair_service_rounded,
      'title': 'Find Services\nNear You',
      'subtitle': 'Browse hundreds of verified home service professionals in your area',
      'color': const Color(0xFF00D4FF),
    },
    {
      'icon': Icons.verified_rounded,
      'title': 'Verified\nProfessionals',
      'subtitle': 'All service providers are background-checked and verified',
      'color': const Color(0xFF00FFB3),
    },
    {
      'icon': Icons.bolt_rounded,
      'title': 'Book in\nSeconds',
      'subtitle': 'Schedule appointments with just a few taps, anytime anywhere',
      'color': const Color(0xFFFFD600),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: pages.length,
                itemBuilder: (context, i) {
                  final page = pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(36),
    color: (page['color'] as Color).withOpacity(0.08),
    border: Border.all(color: (page['color'] as Color).withOpacity(0.2), width: 1),
    boxShadow: [BoxShadow(color: (page['color'] as Color).withOpacity(0.2), blurRadius: 30, spreadRadius: 2)],
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Image.asset('lib/asset/logo.png', fit: BoxFit.contain),
  ),
),
                        const SizedBox(height: 40),
                        Text(
                          page['title'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.1, letterSpacing: -1),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle'] as String,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == i ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage == pages.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/role'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D4FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/role'),
                      child: Text('Already have an account', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}