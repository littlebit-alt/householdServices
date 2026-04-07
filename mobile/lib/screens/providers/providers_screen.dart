import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_nav.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List providers = [];
  bool loading = true;
  final _searchController = TextEditingController();
  String search = '';

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    try {
      final res = await ApiService.get('/providers');
      setState(() { providers = res['providers']; loading = false; });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List get filtered => providers.where((p) =>
    p['fullName'].toString().toLowerCase().contains(search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Find Providers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => search = v),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                    hintText: 'Search providers...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 2))
                  : filtered.isEmpty
                      ? Center(child: Text('No providers found', style: TextStyle(color: Colors.white.withOpacity(0.3))))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            return GestureDetector(
                              onTap: () => context.go('/providers/${p['id']}'),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141414),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56, height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0055AA)]),
                                      ),
                                      child: Center(
                                        child: Text(p['fullName'].toString().substring(0, 1),
                                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p['fullName'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD600)),
                                              const SizedBox(width: 4),
                                              Text('${p['rating']} · ${p['totalReviews']} reviews',
                                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (p['isVerified'])
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00D4FF).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
                                        ),
                                        child: const Text('Verified', style: TextStyle(color: Color(0xFF00D4FF), fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
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
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}