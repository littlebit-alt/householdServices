import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_nav.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final res = await ApiService.get('/bookings/my');
      setState(() { bookings = res['bookings']; loading = false; });
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Bookings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('${bookings.length} bookings', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 2))
                  : bookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 80, height: 80,
                                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(24)),
                                child: Icon(Icons.calendar_today_rounded, size: 32, color: Colors.white.withOpacity(0.2))),
                              const SizedBox(height: 16),
                              Text('No bookings yet', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => context.go('/providers'),
                                child: const Text('Book a service', style: TextStyle(color: Color(0xFF00D4FF), fontSize: 14)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final b = bookings[index];
                            final statusColor = _statusColor(b['status']);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(b['service']['name'],
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: statusColor.withOpacity(0.2)),
                                        ),
                                        child: Text(b['status'], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
                                      const SizedBox(width: 6),
                                      Text(b['provider']['fullName'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                                      const Spacer(),
                                      Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white.withOpacity(0.3)),
                                      const SizedBox(width: 6),
                                      Text(b['scheduledAt'].toString().substring(0, 10),
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('\$${b['totalPrice']}', style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 18, fontWeight: FontWeight.bold)),
                                      if (b['status'] == 'COMPLETED')
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A1A),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                                          ),
                                          child: Text('Rate Service', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}