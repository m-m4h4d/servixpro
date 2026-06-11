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
final serviceControllerProvider = StateNotifierProvider<ServiceController, bool>((ref) {
  return ServiceController(ref.watch(serviceRepositoryProvider), ref);
});

class ServiceController extends StateNotifier<bool> {
  final ServiceRepository _repository;
  final Ref _ref;

  ServiceController(this._repository, this._ref) : super(false);

  Future<void> addService(ServiceModel service) async {
    state = true;
    try {
      await _repository.createService(service);
      _ref.invalidate(allServicesProvider);
      _ref.invalidate(providerServicesProvider);
    } finally {
      state = false;
    }
  }

  Future<void> deleteService(String id) async {
    state = true;
    try {
      await _repository.deleteService(id);
      _ref.invalidate(allServicesProvider);
      _ref.invalidate(providerServicesProvider);
    } finally {
      state = false;
    }
  }
}
