import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/provider_bottom_nav.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Map? profileData;
  bool loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final res = await ApiService.get('/provider-dashboard/profile');
      setState(() { profileData = res['provider']; loading = false; });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final provider = auth.provider;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB3), strokeWidth: 2))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Avatar & info
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 88, height: 88,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF00FFB3), Color(0xFF00AA77)],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    provider?['fullName']?.toString().substring(0, 1) ?? 'P',
                                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              if (provider?['isVerified'] == true)
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    width: 26, height: 26,
                                    decoration: const BoxDecoration(color: Color(0xFF00FFB3), shape: BoxShape.circle),
                                    child: const Icon(Icons.verified_rounded, size: 16, color: Colors.black),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(provider?['fullName'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(provider?['email'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFD600)),
                              const SizedBox(width: 4),
                              Text('${provider?['rating'] ?? 0} · ${provider?['totalReviews'] ?? 0} reviews',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat('Bookings', '${profileData?['_count']?['bookings'] ?? 0}'),
                          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.06)),
                          _Stat('Reviews', '${profileData?['_count']?['reviews'] ?? 0}'),
                          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.06)),
                          _Stat('Services', '${(profileData?['services'] as List?)?.length ?? 0}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Services offered
                    if (profileData?['services'] != null && (profileData!['services'] as List).isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('My Services', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 14),
                            ...(profileData!['services'] as List).map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00FFB3).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.home_repair_service_rounded, color: Color(0xFF00FFB3), size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(s['service']['name'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
                                  Text('\$${s['price']}', style: const TextStyle(color: Color(0xFF00FFB3), fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Menu items
                    _MenuSection(items: [
                      _MenuTile(icon: Icons.calendar_month_rounded, label: 'My Bookings', color: const Color(0xFF00FFB3), onTap: () => context.go('/provider/bookings')),
                      _MenuTile(icon: Icons.notifications_rounded, label: 'Notifications', color: const Color(0xFF00D4FF), onTap: () => context.go('/provider/notifications')),
                      _MenuTile(icon: Icons.star_rounded, label: 'My Reviews', color: const Color(0xFFFFD600), onTap: () {}),
                    ]),
                    const SizedBox(height: 14),

                    // Logout
                    GestureDetector(
                      onTap: () async { await auth.logout(); if (context.mounted) context.go('/role'); },
                      child: Container(
                        width: double.infinity,
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
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 3),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
    ],
  );
}

class _MenuSection extends StatelessWidget {
  final List<Widget> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF141414),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(children: items),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(width: 34, height: 34,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white.withOpacity(0.2)),
        ],
      ),
    ),
  );
}