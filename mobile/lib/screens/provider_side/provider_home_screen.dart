import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/provider_bottom_nav.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  Map? stats;
  List recentBookings = [];
  List reviews = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final res = await ApiService.get('/provider-dashboard/stats');
      setState(() {
        stats = res['stats'];
        recentBookings = res['recentBookings'];
        reviews = res['reviews'];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING': return const Color(0xFFFFD600);
      case 'CONFIRMED': return const Color(0xFF00D4FF);
      case 'ONGOING': return const Color(0xFFB44FFF);
      case 'COMPLETED': return const Color(0xFF00FFB3);
      case 'CANCELLED': return Colors.white.withOpacity(0.3);
      default: return Colors.white.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final provider = auth.provider;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB3), strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: const Color(0xFF00FFB3),
              backgroundColor: const Color(0xFF141414),
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    provider?['fullName']?.toString().split(' ')[0] ?? 'Provider',
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                  ),
                                ],
                              ),
                            ),
                            if (provider?['isVerified'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FFB3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF00FFB3).withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF00FFB3)),
                                    const SizedBox(width: 4),
                                    const Text('Verified', style: TextStyle(color: Color(0xFF00FFB3), fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stats Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        children: [
                          // Revenue card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF00FFB3), Color(0xFF00AA77)],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Earnings', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                Text('\$${stats?['totalEarnings'] ?? 0}',
                                  style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _MiniStat(label: 'Completed', value: '${stats?['completedBookings'] ?? 0}', dark: true),
                                    const SizedBox(width: 16),
                                    _MiniStat(label: 'Pending', value: '${stats?['pendingBookings'] ?? 0}', dark: true),
                                    const SizedBox(width: 16),
                                    _MiniStat(label: 'Total', value: '${stats?['totalBookings'] ?? 0}', dark: true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Stats row
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Confirmed',
                                  value: '${stats?['confirmedBookings'] ?? 0}',
                                  icon: Icons.check_circle_rounded,
                                  color: const Color(0xFF00D4FF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: 'Cancelled',
                                  value: '${stats?['cancelledBookings'] ?? 0}',
                                  icon: Icons.cancel_rounded,
                                  color: Colors.red.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Bookings
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Bookings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => context.go('/provider/bookings'),
                            child: const Text('See all', style: TextStyle(color: Color(0xFF00FFB3), fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  recentBookings.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 40, color: Colors.white.withOpacity(0.1)),
                                  const SizedBox(height: 12),
                                  Text('No bookings yet', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final b = recentBookings[index];
                              final statusColor = _statusColor(b['status']);
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141414),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(Icons.person_rounded, color: statusColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(b['user']['fullName'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 2),
                                            Text(b['service']['name'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(b['status'], style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('\$${b['totalPrice']}', style: const TextStyle(color: Color(0xFF00FFB3), fontSize: 14, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: recentBookings.length > 5 ? 5 : recentBookings.length,
                          ),
                        ),

                  // Reviews section
                  if (reviews.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: const Text('Latest Reviews', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final r = reviews[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFFFFD600), Color(0xFFFF8800)]),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(r['user']['fullName'].toString().substring(0, 1),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(r['user']['fullName'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                      ),
                                      Row(
                                        children: List.generate(r['rating'], (_) =>
                                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD600))),
                                      ),
                                    ],
                                  ),
                                  if (r['comment'] != null) ...[
                                    const SizedBox(height: 10),
                                    Text(r['comment'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.5)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: reviews.length,
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF141414),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Row(
      children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ]),
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final bool dark;
  const _MiniStat({required this.label, required this.value, this.dark = false});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: TextStyle(color: dark ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: dark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.4), fontSize: 10)),
    ],
  );
}