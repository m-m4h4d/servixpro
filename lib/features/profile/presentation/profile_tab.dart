import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart';
import '../../../core/shared_prefs/shared_prefs_helper.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

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
                  final bytes = await pickedFile.readAsBytes();
                  final extension = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : null;
                  try {
                    await ref.read(authStateProvider.notifier).updateProfileImage(bytes, extension);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not update profile picture.')),
                      );
                    }
                  }
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
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
