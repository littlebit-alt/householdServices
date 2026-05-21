import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_filled,
              label: 'Home',
              index: 0,
              current: currentIndex,
              onTap: () {
                if (currentIndex != 0) {
                  context.pushReplacement('/home');
                }
              },
            ),
            _NavItem(
              icon: Icons.search,
              label: 'Search',
              index: 1,
              current: currentIndex,
              onTap: () {
                if (currentIndex != 1) {
                  context.pushReplacement('/providers');
                }
              },
            ),
            _NavItem(
              icon: Icons.calendar_month,
              label: 'Bookings',
              index: 2,
              current: currentIndex,
              onTap: () {
                if (currentIndex != 2) {
                  context.pushReplacement('/bookings');
                }
              },
            ),
            _NavItem(
              icon: Icons.person,
              label: 'Profile',
              index: 3,
              current: currentIndex,
              onTap: () {
                if (currentIndex != 3) {
                  context.pushReplacement('/profile');
                }
              },
            ),
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
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0891B2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0891B2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 22 : 20,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}