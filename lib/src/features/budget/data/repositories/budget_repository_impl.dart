import 'package:expenses_tracker/src/config/app_config.dart';
import 'package:expenses_tracker/src/features/budget/domain/models/budget_model.dart';
import 'package:expenses_tracker/src/features/budget/domain/repositories/budget_repository.dart';
import 'package:expenses_tracker/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  static const String _boxName = 'budgets_box';

  Future<Box<Budget>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Budget>(_boxName);
    }
    return Hive.box<Budget>(_boxName);
  }

  DatabaseReference get _firebaseRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in before managing budgets.');
    }
    return FirebaseDatabase.instance.ref('users/${user.uid}/budgets');
  }

  @override
  FutureEither<List<Budget>> getBudgets() async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        final snapshot = await _firebaseRef.get();
        final raw = snapshot.value;
        if (raw is! Map) return <Budget>[];

        final budgets = raw.entries.map((entry) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          map['id'] ??= entry.key.toString();
          return Budget.fromMap(map);
        }).toList();
        budgets.sort((a, b) => a.month.compareTo(b.month));
        return budgets;
      }

      final box = await _getBox();
      return box.values.toList();
    });
  }

  @override
  FutureEitherVoid addBudget(Budget budget) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        await _firebaseRef.child(budget.id).set(budget.toMap());
        return;
      }

      final box = await _getBox();
      await box.put(budget.id, budget);
    });
  }

  @override
  FutureEitherVoid deleteBudget(String id) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        await _firebaseRef.child(id).remove();
        return;
      }

      final box = await _getBox();
      await box.delete(id);
    });
  }

  @override
  FutureEitherVoid updateBudget(Budget budget) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        await _firebaseRef.child(budget.id).set(budget.toMap());
        return;
      }

      final box = await _getBox();
      await box.put(budget.id, budget);
    });
  }
}
