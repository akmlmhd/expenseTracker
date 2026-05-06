import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/services.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _storageKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = StorageService.instance.getString(_storageKey);
    if (savedTheme != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
      emit(mode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.instance.setString(_storageKey, mode.toString());
    emit(mode);
  }
}
