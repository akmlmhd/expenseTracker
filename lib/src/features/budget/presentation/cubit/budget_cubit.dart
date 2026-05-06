import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repository;

  BudgetCubit(this._repository) : super(BudgetInitial());

  void clear() => emit(const BudgetLoaded([]));

  Future<void> getBudgets() async {
    emit(BudgetLoading());
    final result = await _repository.getBudgets();
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) => emit(BudgetLoaded(budgets)),
    );
  }

  Future<void> addBudget(Budget budget) async {
    emit(BudgetLoading());
    final result = await _repository.addBudget(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) async {
        emit(BudgetActionSuccess());
        await getBudgets();
      },
    );
  }

  Future<void> updateBudget(Budget budget) async {
    emit(BudgetLoading());
    final result = await _repository.updateBudget(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) async {
        emit(BudgetActionSuccess());
        await getBudgets();
      },
    );
  }

  Future<void> deleteBudget(String id) async {
    emit(BudgetLoading());
    final result = await _repository.deleteBudget(id);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) async {
        emit(BudgetActionSuccess());
        await getBudgets();
      },
    );
  }
}
