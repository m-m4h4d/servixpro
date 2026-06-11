import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import 'home_tab.dart';
import '../../services/presentation/services_tab.dart';
import '../../bookings/presentation/bookings_tab.dart';
import '../../notifications/presentation/notifications_tab.dart';
import '../../profile/presentation/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _customerTabs = const [
    HomeTab(),
    ServicesTab(),
    BookingsTab(),
    NotificationsTab(),
    ProfileTab(),
  ];

  final List<Widget> _providerTabs = const [
    HomeTab(),
    ServicesTab(), // Providers will see 'My Services' here eventually
    BookingsTab(), // Providers will see incoming bookings here
    NotificationsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final isProvider = user?.role == 'Provider';
    final currentTabs = isProvider ? _providerTabs : _customerTabs;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: currentTabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.handyman),
            label: isProvider ? 'My Services' : 'Services',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
