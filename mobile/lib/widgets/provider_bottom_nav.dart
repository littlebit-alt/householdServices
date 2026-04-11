import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderBottomNav extends StatelessWidget {
  final int currentIndex;
  const ProviderBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0, current: currentIndex, onTap: () => context.go('/provider/home')),
              _NavItem(icon: Icons.calendar_month_rounded, label: 'Bookings', index: 1, current: currentIndex, onTap: () => context.go('/provider/bookings')),
              _NavItem(icon: Icons.notifications_rounded, label: 'Alerts', index: 2, current: currentIndex, onTap: () => context.go('/provider/notifications')),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 3, current: currentIndex, onTap: () => context.go('/provider/profile')),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00FFB3).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? const Color(0xFF00FFB3) : Colors.white.withOpacity(0.4)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF00FFB3) : Colors.white.withOpacity(0.4), fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}