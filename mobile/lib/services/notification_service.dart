import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

enum NotificationType { success, error, info, warning }

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static NotificationService? _instance;
  static BuildContext? _context;

  static void setContext(BuildContext ctx) {
    _context = ctx;
  }

  void show(
    String title,
    String message, {
    NotificationType type = NotificationType.info,
  }) {
    final notif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    );
    _notifications.insert(0, notif);
    notifyListeners();

    if (_context != null) {
      _showBanner(_context!, notif);
    }
  }

  void markAllRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void _showBanner(BuildContext context, AppNotification notif) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotificationBanner(
        notification: notif,
        onDismiss: () {
          entry.remove();
        },
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _NotificationBanner extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;
  const _NotificationBanner({required this.notification, required this.onDismiss});

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.notification.type) {
      case NotificationType.success: return const Color(0xFF0891B2);
      case NotificationType.error: return const Color(0xFFEF4444);
      case NotificationType.warning: return const Color(0xFFF59E0B);
      case NotificationType.info: return const Color(0xFF6366F1);
    }
  }

  IconData get _icon {
    switch (widget.notification.type) {
      case NotificationType.success: return Icons.check_circle_rounded;
      case NotificationType.error: return Icons.error_rounded;
      case NotificationType.warning: return Icons.warning_rounded;
      case NotificationType.info: return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(_icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.notification.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (widget.notification.message.isNotEmpty)
                            Text(
                              widget.notification.message,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.8), size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}