import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/back_button_handler.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFF0891B2).withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset('lib/asset/logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Who are\nyou?', style: TextStyle(color: Color(0xFF1E293B), fontSize: 36,
                 fontWeight: FontWeight.bold, height: 1.1, letterSpacing: -1)),
                const SizedBox(height: 10),
                Text('Choose how you want to use ServeMe', style: TextStyle(color: Colors.grey.shade500, 
                fontSize: 15)),
                const Spacer(),

                // Client Card
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: const Color(0xFF0891B2).withOpacity(0.08), blurRadius: 20)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0891B2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person_rounded, color: Color(0xFF0891B2), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('I\'m a Client', style: TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text('Find and book home services', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Provider Card
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/provider-login'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF059669).withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: const Color(0xFF059669).withOpacity(0.08), blurRadius: 20)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.home_repair_service_rounded, color: Color(0xFF059669), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('I\'m a Provider', style: TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text('Offer your services to clients', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}