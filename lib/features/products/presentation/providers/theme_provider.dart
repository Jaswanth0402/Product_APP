// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_app/core/constants/hive_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  Box<String> get _box => Hive.box<String>(HiveConstants.settingsBox);

  @override
  ThemeMode build() {
    final stored = _box.get(HiveConstants.themeKey);
    return switch (stored) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _box.put(
      HiveConstants.themeKey,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      },
    );
  }
}

// Convenience alias
final themeModeProvider = themeModeNotifierProvider;
