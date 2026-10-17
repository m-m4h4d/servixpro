import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/storage_helper.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/service_model.dart';

final serviceRepositoryProvider = Provider((ref) => ServiceRepository());

class ServiceRepository {
  Future<ServiceModel> createService({
    required String title,
    required String description,
    required String category,
    required double price,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await StorageHelper.uploadImage(imageBytes, name: 'service', extension: imageExtension);
    }

    // id, provider_id and created_at are filled in by the database.
    final map = await supabase
        .from('services')
        .insert({
          'title': title,
          'description': description,
          'category': category,
          'price': price,
          'image_url': imageUrl,
        })
        .select()
        .single();
    return ServiceModel.fromMap(map);
  }

  Future<List<ServiceModel>> getAllServices() async {
    final maps = await supabase.from('services').select().order('created_at', ascending: false);
    return maps.map(ServiceModel.fromMap).toList();
  }

  Future<List<ServiceModel>> getServicesByProvider(String providerId) async {
    final maps = await supabase
        .from('services')
        .select()
        .eq('provider_id', providerId)
        .order('created_at', ascending: false);
    return maps.map(ServiceModel.fromMap).toList();
  }

  Future<void> deleteService(String id) async {
    await supabase.from('services').delete().eq('id', id);
  }
}
