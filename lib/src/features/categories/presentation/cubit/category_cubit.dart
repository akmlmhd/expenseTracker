import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/category_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  void clear() => emit(const CategoryLoaded([]));

  List<String> get currentCategories {
    final current = state;
    if (current is CategoryLoaded) return current.categories;
    return const [];
  }

  Future<void> getCategories() async {
    emit(CategoryLoading());
    final result = await _repository.getCategories();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> addCategory(String category) async {
    final result = await _repository.addCategory(category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => getCategories(),
    );
  }

  Future<void> deleteCategory(String category) async {
    final result = await _repository.deleteCategory(category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => getCategories(),
    );
  }
}
