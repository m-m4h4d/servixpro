import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase connection settings, passed at build time:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
/// or `--dart-define-from-file=supabase.env.json`. A legacy anon key also works.
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static Future<void> init() async {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be provided via --dart-define. See README.md.',
      );
    }
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

SupabaseClient get supabase => Supabase.instance.client;
