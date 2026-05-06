import 'package:expenses_tracker/src/config/app_config.dart';
import 'package:expenses_tracker/src/features/expenses/domain/models/expense_model.dart';
import 'package:expenses_tracker/src/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expenses_tracker/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  static const String _boxName = 'expenses_box';

  Future<Box<Expense>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Expense>(_boxName);
    }
    return Hive.box<Expense>(_boxName);
  }

  DatabaseReference get _firebaseRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in before managing expenses.');
    }
    return FirebaseDatabase.instance.ref('users/${user.uid}/expenses');
  }

  @override
  FutureEither<List<Expense>> getExpenses() async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        final snapshot = await _firebaseRef.get();
        final raw = snapshot.value;
        if (raw is! Map) return <Expense>[];

        final expenses = raw.entries.map((entry) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          map['id'] ??= entry.key.toString();
          return Expense.fromMap(map);
        }).toList();
        expenses.sort((a, b) => a.date.compareTo(b.date));
        return expenses;
      }

      final box = await _getBox();
      return box.values.toList();
    });
  }

  @override
  FutureEitherVoid addExpense(Expense expense) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        await _firebaseRef.child(expense.id).set(expense.toMap());
        return;
      }

      final box = await _getBox();
      await box.put(expense.id, expense);
    });
  }

  @override
  FutureEitherVoid deleteExpense(String id) async {
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
  FutureEitherVoid updateExpense(Expense expense) async {
    return runTask(() async {
      if (AppConfig.authEnabled) {
        await _firebaseRef.child(expense.id).set(expense.toMap());
        return;
      }

      final box = await _getBox();
      await box.put(expense.id, expense);
    });
  }
}
