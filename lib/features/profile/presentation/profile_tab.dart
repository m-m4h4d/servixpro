import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart';
import '../../../core/shared_prefs/shared_prefs_helper.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  ImageProvider? _getProfileImage(String? path) {
    if (path == null) return null;
    if (kIsWeb) {
      return MemoryImage(base64Decode(path));
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final isDarkMode = ref.watch(themeProvider);

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  String imagePathToSave;
                  if (kIsWeb) {
                    final bytes = await pickedFile.readAsBytes();
                    imagePathToSave = base64Encode(bytes);
                  } else {
                    imagePathToSave = pickedFile.path;
                  }
                  await ref.read(authStateProvider.notifier).updateProfileImage(imagePathToSave);
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _getProfileImage(user.profileImage),
                child: user.profileImage == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.role,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone'),
            subtitle: Text(user.phone),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (value) async {
              await SharedPrefsHelper.setDarkMode(value);
              ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
