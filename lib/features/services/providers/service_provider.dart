import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';
import '../../auth/providers/auth_provider.dart';

// Provider to fetch all services (for Customers)
final allServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getAllServices();
});

// Provider to fetch services created by the currently logged-in Provider
final providerServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null || user.role != 'Provider') return [];
  
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getServicesByProvider(user.id);
});

// Notifier for adding/updating services
final serviceControllerProvider = NotifierProvider<ServiceController, bool>(() {
  return ServiceController();
});

class ServiceController extends Notifier<bool> {
  late final ServiceRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(serviceRepositoryProvider);
    return false;
  }

  Future<void> addService({
    required String title,
    required String description,
    required String category,
    required double price,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    state = true;
    try {
      await _repository.createService(
        title: title,
        description: description,
        category: category,
        price: price,
        imageBytes: imageBytes,
        imageExtension: imageExtension,
      );
      ref.invalidate(allServicesProvider);
      ref.invalidate(providerServicesProvider);
    } finally {
      state = false;
    }
  }

  Future<void> deleteService(String id) async {
    state = true;
    try {
      await _repository.deleteService(id);
      ref.invalidate(allServicesProvider);
      ref.invalidate(providerServicesProvider);
    } finally {
      state = false;
    }
  }
}
