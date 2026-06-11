import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/constants.dart';
import '../../auth/providers/auth_provider.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final serviceTipsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchServiceTips();
});

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _isOffline = results.every((result) => result == ConnectivityResult.none);
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = results.every((result) => result == ConnectivityResult.none);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final tipsAsync = ref.watch(serviceTipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.fullName ?? ''}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isOffline)
            Container(
              color: AppColors.error,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'You are currently offline. Viewing local data only.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(AppConstants.padding),
            child: Text(
              'Service Tips & News',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: tipsAsync.when(
              data: (tips) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(tip['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tip['body'], maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Failed to load tips. \n\$err')),
            ),
          ),
        ],
      ),
    );
  }
}
