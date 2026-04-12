import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/provider_login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/booking/bookings_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/add_address_screen.dart';
import 'screens/providers/providers_screen.dart';
import 'screens/providers/provider_detail_screen.dart';
import 'screens/provider_side/provider_home_screen.dart';
import 'screens/provider_side/provider_bookings_screen.dart';
import 'screens/provider_side/provider_profile_screen.dart';
import 'screens/provider_side/provider_notifications_screen.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/role', builder: (c, s) => const RoleSelectionScreen()),
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/provider-login', builder: (c, s) => const ProviderLoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/verify-otp', builder: (c, s) => const VerifyOtpScreen()),
    GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
    // Client routes
    GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
    GoRoute(path: '/bookings', builder: (c, s) => const BookingsScreen()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
    GoRoute(path: '/add-address', builder: (c, s) => const AddAddressScreen()),
    GoRoute(path: '/providers', builder: (c, s) => const ProvidersScreen()),
    GoRoute(path: '/providers/:id', builder: (c, s) => ProviderDetailScreen(providerId: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/book/:providerId/:serviceId', builder: (c, s) => BookingFormScreen(
      providerId: int.parse(s.pathParameters['providerId']!),
      serviceId: int.parse(s.pathParameters['serviceId']!),
    )),
    // Provider routes
    GoRoute(path: '/provider/home', builder: (c, s) => const ProviderHomeScreen()),
    GoRoute(path: '/provider/bookings', builder: (c, s) => const ProviderBookingsScreen()),
    GoRoute(path: '/provider/profile', builder: (c, s) => const ProviderProfileScreen()),
    GoRoute(path: '/provider/notifications', builder: (c, s) => const ProviderNotificationsScreen()),
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4FF),
          surface: Color(0xFF141414),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}