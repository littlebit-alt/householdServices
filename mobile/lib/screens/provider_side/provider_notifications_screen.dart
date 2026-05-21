import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/provider_bottom_nav.dart';

class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  State<ProviderNotificationsScreen> createState() => _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState extends State<ProviderNotificationsScreen> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final res = await ApiService.get('/provider-dashboard/notifications');
      setState(() { notifications = res['notifications']; loading = false; });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _markRead(int id) async {
    try {
      await ApiService.put('/provider-dashboard/notifications/$id/read', {});
      _fetch();
    } catch (_) {}
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'NEW_BOOKING': return Icons.calendar_today_rounded;
      case 'BOOKING_UPDATE': return Icons.update_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'NEW_BOOKING': return const Color(0xFF0891B2);
      case 'BOOKING_UPDATE': return const Color(0xFF00D4FF);
      default: return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications', style: TextStyle(color: Color(0xFF1E293B), fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${notifications.where((n) => !n['isRead']).length} unread', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0891B2), strokeWidth: 2))
                  : notifications.isEmpty
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_rounded, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No notifications', style: TextStyle(color: Colors.grey.shade400)),
                          ],
                        ))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final n = notifications[index];
                            final isRead = n['isRead'] as bool;
                            final color = _getColor(n['type']);
                            return GestureDetector(
                              onTap: () => !isRead ? _markRead(n['id']) : null,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isRead ? Colors.grey.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: isRead ? Colors.grey.shade200 : color.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(_getIcon(n['type']), color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(n['title'], style: TextStyle(color: isRead ? Colors.grey.shade500 : const Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 3),
                                          Text(n['body'], style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.4)),
                                        ],
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}