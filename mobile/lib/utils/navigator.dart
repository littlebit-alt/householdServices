import 'package:flutter/material.dart';
import '../screens/providers/providers_screen.dart';
import '../screens/providers/provider_detail_screen.dart';
import '../screens/booking/booking_form_screen.dart';
import '../screens/profile/add_address_screen.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get _navigator => navigatorKey.currentState!;

  static Future<T?> push<T>(Widget screen) {
    return _navigator.push<T>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static Future<T?> pushProviders<T>() {
    return push<T>(const ProvidersScreen());
  }

  static Future<T?> pushProviderDetail<T>(int providerId) {
    return push<T>(ProviderDetailScreen(providerId: providerId));
  }

  static Future<T?> pushBookingForm<T>(int providerId, int serviceId) {
    return push<T>(BookingFormScreen(providerId: providerId, serviceId: serviceId));
  }

  static Future<T?> pushAddAddress<T>() {
    return push<T>(const AddAddressScreen());
  }

  static void pop<T>([T? result]) {
    if (_navigator.canPop()) _navigator.pop(result);
  }
}