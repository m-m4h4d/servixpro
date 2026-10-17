import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class StorageHelper {
  static const String _bucket = 'images';

  /// Uploads [bytes] under the current user's folder and returns its public URL.
  static Future<String> uploadImage(Uint8List bytes, {required String name, String? extension}) async {
    final userId = supabase.auth.currentUser!.id;
    final ext = (extension == null || extension.isEmpty) ? 'jpg' : extension.toLowerCase();
    final path = '$userId/$name-${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}'),
        );
    return supabase.storage.from(_bucket).getPublicUrl(path);
  }
}
