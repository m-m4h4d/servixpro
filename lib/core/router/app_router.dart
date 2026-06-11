import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared_prefs/shared_prefs_helper.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/services/presentation/add_service_screen.dart';
import '../../features/services/presentation/service_details_screen.dart';
import '../../features/services/models/service_model.dart';

// Placeholder screens for routing setup
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-service',
        builder: (context, state) => const AddServiceScreen(),
      ),
      GoRoute(
        path: '/service-details',
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          return ServiceDetailsScreen(service: service);
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = SharedPrefsHelper.loggedInUserId != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isAtSplash = state.matchedLocation == '/';

      if (isAtSplash) {
        return isLoggedIn ? '/dashboard' : '/login';
      }

      if (!isLoggedIn && !isGoingToLogin) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/dashboard';

      return null;
    },
  );
});
