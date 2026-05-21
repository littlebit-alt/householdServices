import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav.dart';
import 'add_address_screen.dart';
import '../booking/bookings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00D4FF), Color(0xFF0055AA)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user?['fullName']?.toString().substring(0, 1) ?? 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: Color(0xFF00FFB3), shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 14, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(user?['fullName'] ?? '', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user?['email'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 28),

              // Stats row
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Bookings', value: '0'),
                    Container(width: 1, height: 30, color: Colors.grey.shade200),
                    _StatItem(label: 'Reviews', value: '0'),
                    Container(width: 1, height: 30, color: Colors.grey.shade200),
                    _StatItem(label: 'Saved', value: '0'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu
              _MenuSection(
                title: 'Account',
                items: [
                  _MenuItem(icon: Icons.calendar_today_rounded, label: 'My Bookings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
                  _MenuItem(icon: Icons.location_on_rounded, label: 'My Addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()))),
                  _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () {}),
                ],
              ),
              const SizedBox(height: 12),
              _MenuSection(
                title: 'Support',
                items: [
                  _MenuItem(icon: Icons.help_rounded, label: 'Help Center', onTap: () {}),
                  _MenuItem(icon: Icons.star_rounded, label: 'Rate the App', onTap: () {}),
                ],
              ),
              const SizedBox(height: 12),

              // Logout
              GestureDetector(
                onTap: () async { await auth.logout(); if (context.mounted) Navigator.pushReplacementNamed(context, '/role'); },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Colors.red.withOpacity(0.7)),
                      const SizedBox(width: 12),
                      Text('Sign Out', style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
    ],
  );
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: items),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: const Color(0xFF0891B2)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w500))),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade300),
        ],
      ),
    ),
  );
}