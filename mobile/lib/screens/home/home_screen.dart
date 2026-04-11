import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List categories = [];
  List services = [];
  bool loading = true;

  final List<Map<String, dynamic>> categoryGradients = [
    {'colors': [const Color(0xFF00D4FF), const Color(0xFF0066FF)], 'emoji': '🧹'},
    {'colors': [const Color(0xFF00FFB3), const Color(0xFF00AA77)], 'emoji': '🔧'},
    {'colors': [const Color(0xFFFFD600), const Color(0xFFFF8800)], 'emoji': '⚡'},
    {'colors': [const Color(0xFFFF6B9D), const Color(0xFFCC0066)], 'emoji': '🎨'},
    {'colors': [const Color(0xFFB44FFF), const Color(0xFF7700CC)], 'emoji': '🔨'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 2))
          : CustomScrollView(
              slivers: [
                // App Bar
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
                                Text('Good morning,', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(firstName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Stack(
                              children: [
                                Center(child: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.7), size: 20)),
                                Positioned(top: 8, right: 8, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF00D4FF), shape: BoxShape.circle))),
                              ],
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
                      onTap: () => context.go('/providers'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                            const SizedBox(width: 10),
                            Text('Search services, providers...', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Featured Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00D4FF), Color(0xFF0055AA)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(right: -20, top: -20,
                            child: Container(width: 150, height: 150,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                          Positioned(right: 20, bottom: -30,
                            child: Container(width: 100, height: 100,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                  child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ),
                                const SizedBox(height: 10),
                                const Text('Book Your First\nService Free!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => context.go('/providers'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: const Text('Explore Now', style: TextStyle(color: Color(0xFF0055AA), fontSize: 12, fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => context.go('/providers'),
                          child: Text('See all', style: TextStyle(color: const Color(0xFF00D4FF), fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Categories horizontal scroll
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final gradient = categoryGradients[index % categoryGradients.length];
                        return GestureDetector(
                          onTap: () => context.go('/providers'),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: gradient['colors'] as List<Color>,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      gradient['emoji'] as String,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name'],
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Popular Services Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Popular Services', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${services.length} available', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                      ],
                    ),
                  ),
                ),

                // Services grid
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
                          onTap: () => context.go('/providers'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: (gradient['colors'] as List<Color>).map((c) => c.withOpacity(0.3)).toList(),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(gradient['emoji'] as String, style: const TextStyle(fontSize: 40)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service['name'],
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        service['category']['name'],
                                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${service['basePrice']}',
                                        style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
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

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}