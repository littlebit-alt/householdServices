import 'package:flutter/material.dart';
import '../booking/booking_form_screen.dart';
import '../../services/api_service.dart';
import '../providers/provider_detail_screen.dart';

class ProvidersScreen extends StatefulWidget {
  final int? serviceId;
  final String? serviceName;
  const ProvidersScreen({super.key, this.serviceId, this.serviceName});

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
      List allProviders = [];

      if (widget.serviceId != null) {
        // Fetch providers for specific service
        final res = await ApiService.get('/services/${widget.serviceId}');
        final serviceData = res['service'];
        final providerServices = serviceData['providers'] as List;

        // Extract provider details with their custom price
        allProviders = providerServices.map((ps) {
          final p = ps['provider'];
          return {
            ...Map<String, dynamic>.from(p),
            'customPrice': ps['price'],
          };
        }).toList();
      } else {
        // Fetch all providers
        final res = await ApiService.get('/providers');
        allProviders = res['providers'];
      }

      setState(() {
        providers = allProviders;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List get filtered => providers.where((p) =>
    p['fullName'].toString().toLowerCase().contains(search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName ?? 'All Providers',
                          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (widget.serviceId != null)
                          Text(
                            '${filtered.length} provider${filtered.length != 1 ? 's' : ''} available',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => search = v),
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                    hintText: 'Search providers...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0891B2), strokeWidth: 2))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.person_search_rounded, size: 32, color: Colors.grey.shade400),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                widget.serviceId != null
                                    ? 'No providers for this service yet'
                                    : 'No providers found',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ProviderDetailScreen(providerId: p['id']),
                              )),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey.shade100),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 54, height: 54,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          p['fullName'].toString().substring(0, 1).toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p['fullName'],
                                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${p['rating']} · ${p['totalReviews']} reviews',
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          if (p['customPrice'] != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.attach_money_rounded, size: 14, color: Color(0xFF0891B2)),
                                                Text(
                                                  '${p['customPrice']}',
                                                  style: const TextStyle(color: Color(0xFF0891B2), fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Verified + Arrow
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (p['isVerified'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0891B2).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text('Verified', style: TextStyle(color: Color(0xFF0891B2), fontSize: 10, fontWeight: FontWeight.w600)),
                                          ),
                                        const SizedBox(height: 8),
                                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
                                      ],
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
    );
  }
}