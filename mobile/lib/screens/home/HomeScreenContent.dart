import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/back_button_handler.dart';
import '../providers/providers_screen.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenContent> {
  List categories = [];
  List services = [];
  bool loading = true;

  final List<Map<String, dynamic>> categoryGradients = [
    {'colors': [const Color(0xFF0891B2), const Color(0xFF0E7490)], 'emoji': '🧹'},
    {'colors': [const Color(0xFF059669), const Color(0xFF047857)], 'emoji': '🔧'},
    {'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)], 'emoji': '⚡'},
    {'colors': [const Color(0xFFEC4899), const Color(0xFFDB2777)], 'emoji': '🎨'},
    {'colors': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], 'emoji': '🔨'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
    NotificationService.setContext(context);
  }

  Future<void> _fetchData() async {
    try {
      final catRes = await ApiService.get('/categories');
      final serRes = await ApiService.get('/services');
      setState(() {
        categories = catRes['categories'];
        services = serRes['services'];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final firstName = auth.user?['fullName']?.toString().split(' ')[0] ?? 'there';

    return 
      
         Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0891B2), strokeWidth: 2))
              : CustomScrollView(
                  slivers: [
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
                                    Text('Good morning,', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(firstName, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.read<NotificationService>().markAllRead();
                                },
                                child: Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF1E3A5F), width: 1.5),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                  ),
                                  child: Consumer<NotificationService>(
                                    builder: (_, notifService, __) => Stack(
                                      children: [
                                        Center(child: Icon(Icons.notifications_outlined, color: Colors.grey.shade600, size: 20)),
                                        if (notifService.unreadCount > 0)
                                          Positioned(
                                            top: 8, right: 8,
                                            child: Container(
                                              width: 8, height: 8,
                                              decoration: const BoxDecoration(color: Color(0xFF0891B2), shape: BoxShape.circle),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvidersScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E3A5F), width: 1.5),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                                const SizedBox(width: 10),
                                Text('Search services, providers...', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        
                    // Featured Banner
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                            ),
                            border: Border.all(color: const Color(0xFF1E3A5F), width: 1.5),
                          ),
                          child: Stack(
                            children: [
                              Positioned(right: -20, top: -20,
                                child: Container(width: 130, height: 130,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                              Positioned(right: 20, bottom: -30,
                                child: Container(width: 90, height: 90,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                                      child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Book Your First\nService Today!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvidersScreen())),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                        child: const Text('Explore Now', style: TextStyle(color: Color(0xFF0891B2), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        
                    // Categories Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Categories', style: TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvidersScreen())),
                              child: const Text('See all', style: TextStyle(color: Color(0xFF0891B2), fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ),
        
                    // Categories
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final gradient = categoryGradients[index % categoryGradients.length];
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvidersScreen())),
                              child: Container(
                                width: 76,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60, height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: gradient['colors'] as List<Color>,
                                        ),
                                        border: Border.all(color: const Color(0xFF1E3A5F), width: 1.5),
                                        boxShadow: [BoxShadow(color: (gradient['colors'] as List<Color>)[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                                      ),
                                      child: Center(child: Text(gradient['emoji'] as String, style: const TextStyle(fontSize: 26))),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(cat['name'], style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        
                    // Services Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Popular Services', style: TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.bold)),
                            Text('${services.length} available', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
        
                    // Services Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = services[index];
                            final gradient = categoryGradients[index % categoryGradients.length];
                            return GestureDetector(
onTap: () => Navigator.push(context, MaterialPageRoute(
  builder: (_) => ProvidersScreen(serviceId: service['id'], serviceName: service['name']),
)),                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFF1E3A5F), width: 1.5),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 96,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: (gradient['colors'] as List<Color>).map((c) => c.withOpacity(0.15)).toList(),
                                        ),
                                      ),
                                      child: Center(child: Text(gradient['emoji'] as String, style: const TextStyle(fontSize: 38))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(service['name'], style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text(service['category']['name'], style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                          const SizedBox(height: 6),
                                          Text('\$${service['basePrice']}', style: const TextStyle(color: Color(0xFF0891B2), fontSize: 15, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: services.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
          
        );
      
    
  }
}