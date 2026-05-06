import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseCubit(this._repository) : super(ExpenseInitial());

  void clear() => emit(const ExpenseLoaded([]));

  Future<void> getExpenses() async {
    emit(ExpenseLoading());
    final result = await _repository.getExpenses();
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  Future<void> addExpense(Expense expense) async {
    emit(ExpenseLoading());
    final result = await _repository.addExpense(expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) async {
        emit(ExpenseActionSuccess());
        await getExpenses();
      },
    );
  }

  Future<void> updateExpense(Expense expense) async {
    emit(ExpenseLoading());
    final result = await _repository.updateExpense(expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) async {
        emit(ExpenseActionSuccess());
        await getExpenses();
      },
    );
  }

  Future<void> deleteExpense(String id) async {
    emit(ExpenseLoading());
    final result = await _repository.deleteExpense(id);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) async {
        emit(ExpenseActionSuccess());
        await getExpenses();
      },
    );
  }
}
