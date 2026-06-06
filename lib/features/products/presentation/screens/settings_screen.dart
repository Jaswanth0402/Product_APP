import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:product_app/features/products/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('System default'),
            secondary: const Icon(Icons.settings_brightness_outlined),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeNotifierProvider.notifier).setTheme(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            secondary: const Icon(Icons.light_mode_outlined),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeNotifierProvider.notifier).setTheme(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeNotifierProvider.notifier).setTheme(v!),
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Version'),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.api_outlined),
            title: Text('API'),
            subtitle: Text('dummyjson.com'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
