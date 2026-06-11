import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../main.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/shared_prefs/shared_prefs_helper.dart';
import '../../../core/utils/constants.dart';
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

    final isDesktopWeb = kIsWeb && MediaQuery.of(context).size.width > 600;

    PreferredSizeWidget? webAppBar;
    if (kIsWeb) {
      webAppBar = AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Text('ServixPro', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(ref.watch(themeProvider) ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              final newTheme = !ref.read(themeProvider);
              await SharedPrefsHelper.setDarkMode(newTheme);
              ref.read(themeProvider.notifier).setTheme(newTheme);
            },
          ),
          if (isDesktopWeb) ...[
            TextButton(
              onPressed: () => setState(() => _currentIndex = 0),
              style: TextButton.styleFrom(foregroundColor: _currentIndex == 0 ? AppColors.secondary : Colors.white),
              child: const Text('Home'),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              style: TextButton.styleFrom(foregroundColor: _currentIndex == 1 ? AppColors.secondary : Colors.white),
              child: Text(isProvider ? 'My Services' : 'Services'),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 2),
              style: TextButton.styleFrom(foregroundColor: _currentIndex == 2 ? AppColors.secondary : Colors.white),
              child: const Text('Bookings'),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 3),
              style: TextButton.styleFrom(foregroundColor: _currentIndex == 3 ? AppColors.secondary : Colors.white),
              child: const Text('Alerts'),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 4),
              style: TextButton.styleFrom(foregroundColor: _currentIndex == 4 ? AppColors.secondary : Colors.white),
              child: const Text('Profile'),
            ),
            const SizedBox(width: 16),
          ] else ...[
            PopupMenuButton<int>(
              icon: const Icon(Icons.menu),
              onSelected: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 0, child: Text('Home')),
                PopupMenuItem(value: 1, child: Text(isProvider ? 'My Services' : 'Services')),
                const PopupMenuItem(value: 2, child: Text('Bookings')),
                const PopupMenuItem(value: 3, child: Text('Alerts')),
                const PopupMenuItem(value: 4, child: Text('Profile')),
              ],
            ),
          ]
        ],
      );
    }

    return Scaffold(
      appBar: webAppBar,
      body: IndexedStack(
        index: _currentIndex,
        children: currentTabs,
      ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomNavigationBar(
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
