import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'provider_home_screen.dart';
import 'provider_bookings_screen.dart';
import 'provider_notifications_screen.dart';
import 'provider_profile_screen.dart';

class ProviderMainScreen extends StatefulWidget {
  const ProviderMainScreen({super.key});

  @override
  State<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends State<ProviderMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProviderHomeContent(),
    const ProviderBookingsScreen(),
    const ProviderNotificationsScreen(),
    const ProviderProfileScreen(),
  ];

  Future<void> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit App', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Stay', style: TextStyle(color: Color(0xFF0891B2)))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Exit', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (shouldExit == true) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0, current: _currentIndex, onTap: () => setState(() => _currentIndex = 0)),
                  _NavItem(icon: Icons.calendar_month_rounded, label: 'Bookings', index: 1, current: _currentIndex, onTap: () => setState(() => _currentIndex = 1)),
                  _NavItem(icon: Icons.notifications_rounded, label: 'Alerts', index: 2, current: _currentIndex, onTap: () => setState(() => _currentIndex = 2)),
                  _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 3, current: _currentIndex, onTap: () => setState(() => _currentIndex = 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0891B2).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? const Color(0xFF0891B2) : Colors.grey.shade400),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF0891B2) : Colors.grey.shade400, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}