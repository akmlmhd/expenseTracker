import 'package:expenses_tracker/src/config/app_config.dart';
import 'package:expenses_tracker/src/features/categories/domain/repositories/category_repository.dart';
import 'package:expenses_tracker/src/services/services.dart';
import 'package:expenses_tracker/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  static const String _storageKey = 'expense_categories';

  static const List<String> defaultCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Salary',
    'Other',
  ];

  DatabaseReference get _firebaseRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in before managing categories.');
    }
    return FirebaseDatabase.instance.ref('users/${user.uid}/categories');
  }

  @override
  FutureEither<List<String>> getCategories() async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        final snapshot = await _firebaseRef.get();
        final raw = snapshot.value;
        if (raw is List) {
          final categories = raw.whereType<String>().toList();
          if (categories.isNotEmpty) return categories;
        }
        if (raw is Map) {
          final categories =
              raw.values.map((value) => value.toString()).toList();
          if (categories.isNotEmpty) return categories;
        }

        await _firebaseRef.set(defaultCategories);
        return defaultCategories;
      }

      final stored = StorageService.instance.getStringList(_storageKey);
      if (stored == null || stored.isEmpty) {
        await StorageService.instance
            .setStringList(_storageKey, defaultCategories);
        return defaultCategories;
      }
      return stored;
    });
  }

  @override
  FutureEitherVoid saveCategories(List<String> categories) async {
    return runTask(() async {
      final cleaned = categories
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      if (AppConfig.authEnabled) {
        await _firebaseRef.set(cleaned);
        return;
      }

      await StorageService.instance.setStringList(_storageKey, cleaned);
    });
  }

  @override
  FutureEitherVoid addCategory(String category) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        final result = await getCategories();
        final categories = result.getOrElse((_) => defaultCategories);
        final value = category.trim();
        if (value.isEmpty) return;

        final exists =
            categories.any((item) => item.toLowerCase() == value.toLowerCase());
        if (!exists) {
          await _firebaseRef.set([...categories, value]);
        }
        return;
      }

      final categories = StorageService.instance.getStringList(_storageKey) ??
          defaultCategories;
      final value = category.trim();
      if (value.isEmpty) return;

      final exists =
          categories.any((item) => item.toLowerCase() == value.toLowerCase());
      if (!exists) {
        await StorageService.instance
            .setStringList(_storageKey, [...categories, value]);
      }
    });
  }

  @override
  FutureEitherVoid deleteCategory(String category) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        final result = await getCategories();
        final categories = result.getOrElse((_) => defaultCategories);
        final updated = categories.where((item) => item != category).toList();
        await _firebaseRef.set(updated);
        return;
      }

      final categories = StorageService.instance.getStringList(_storageKey) ??
          defaultCategories;
      final updated = categories.where((item) => item != category).toList();
      await StorageService.instance.setStringList(_storageKey, updated);
    });
  }
}
