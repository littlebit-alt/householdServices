import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/booking/bookings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/providers/providers_screen.dart';
import 'screens/providers/provider_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/profile/add_address_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/verify-otp', builder: (context, state) => const VerifyOtpScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/bookings', builder: (context, state) => const BookingsScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/providers', builder: (context, state) => const ProvidersScreen()),
GoRoute(path: '/providers/:id', builder: (context, state) => ProviderDetailScreen(providerId: int.parse(state.pathParameters['id']!))),
GoRoute(path: '/book/:providerId/:serviceId', builder: (context, state) => BookingFormScreen(
  providerId: int.parse(state.pathParameters['providerId']!),
  serviceId: int.parse(state.pathParameters['serviceId']!),
  
)),
GoRoute(path: '/add-address', builder: (context, state) => const AddAddressScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HouseServ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF06B6D4),
          primary: const Color(0xFF06B6D4),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}