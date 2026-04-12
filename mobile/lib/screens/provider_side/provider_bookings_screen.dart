import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/provider_bottom_nav.dart';
import '../../utils/snackbar.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List allBookings = [];
  bool loading = true;

  final tabs = ['All', 'PENDING', 'CONFIRMED', 'ONGOING', 'COMPLETED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _fetchBookings() async {
    try {
      final res = await ApiService.get('/provider-dashboard/bookings');
      setState(() { allBookings = res['bookings']; loading = false; });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiService.put('/provider-dashboard/bookings/$id/status', {'status': status});
      _fetchBookings();
      showSuccess(context, 'Status updated to $status');
    } catch (e) {
      showError(context, 'Failed to update status');
    }
  }

  List _filtered(String tab) => tab == 'All' ? allBookings : allBookings.where((b) => b['status'] == tab).toList();

  Color _statusColor(String s) {
    switch (s) {
      case 'PENDING': return const Color(0xFFFFD600);
      case 'CONFIRMED': return const Color(0xFF00D4FF);
      case 'ONGOING': return const Color(0xFFB44FFF);
      case 'COMPLETED': return const Color(0xFF00FFB3);
      default: return Colors.white.withOpacity(0.3);
    }
  }

  void _showStatusSheet(Map booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Status', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...['CONFIRMED', 'ONGOING', 'COMPLETED', 'CANCELLED'].map((status) {
              final color = _statusColor(status);
              return GestureDetector(
                onTap: () { Navigator.pop(context); _updateStatus(booking['id'], status); },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Text(status, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bookings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  Text('${allBookings.length} total', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              labelColor: const Color(0xFF00FFB3),
              unselectedLabelColor: Colors.white.withOpacity(0.3),
              indicatorColor: const Color(0xFF00FFB3),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB3), strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: tabs.map((tab) {
                        final list = _filtered(tab);
                        if (list.isEmpty) return Center(child: Text('No $tab bookings', style: TextStyle(color: Colors.white.withOpacity(0.3))));
                        return RefreshIndicator(
                          onRefresh: _fetchBookings,
                          color: const Color(0xFF00FFB3),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final b = list[index];
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
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0055AA)]),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Center(
                                            child: Text(b['user']['fullName'].toString().substring(0, 1),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(b['user']['fullName'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 2),
                                              Text(b['service']['name'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: statusColor.withOpacity(0.2)),
                                          ),
                                          child: Text(b['status'], style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded, size: 13, color: Colors.white.withOpacity(0.3)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${b['address']?['address'] ?? ''}, ${b['address']?['city'] ?? ''}',
                                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, size: 13, color: Colors.white.withOpacity(0.3)),
                                        const SizedBox(width: 4),
                                        Text(b['scheduledAt'].toString().substring(0, 16).replaceAll('T', ' '),
                                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                        const Spacer(),
                                        Text('\$${b['totalPrice']}', style: const TextStyle(color: Color(0xFF00FFB3), fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    if (b['notes'] != null && b['notes'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.03),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.notes_rounded, size: 13, color: Colors.white.withOpacity(0.3)),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text(b['notes'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12))),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (b['status'] != 'COMPLETED' && b['status'] != 'CANCELLED') ...[
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_rounded, size: 14, color: const Color(0xFF00FFB3)),
                                          const SizedBox(width: 6),
                                          Text(b['user']['phone'] ?? '', style: const TextStyle(color: Color(0xFF00FFB3), fontSize: 13)),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () => _showStatusSheet(b),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00FFB3).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFF00FFB3).withOpacity(0.2)),
                                              ),
                                              child: const Text('Update Status', style: TextStyle(color: Color(0xFF00FFB3), fontSize: 12, fontWeight: FontWeight.w600)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 1),
    );
  }
}