import 'package:expenses_tracker/src/features/auth/domain/repositories/auth_repository.dart';

import '../../imports/imports.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/providers/session_bloc.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/presentation/cubit/budget_cubit.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/presentation/cubit/category_cubit.dart';
import '../cubit/theme_cubit.dart';

/// A wrapper to initialize the chosen State Management library.
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shouldLoadLocalData = !AppConfig.authEnabled;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        RepositoryProvider<ExpenseRepository>(
            create: (_) => ExpenseRepositoryImpl()),
        RepositoryProvider<BudgetRepository>(
            create: (_) => BudgetRepositoryImpl()),
        RepositoryProvider<CategoryRepository>(
            create: (_) => CategoryRepositoryImpl()),
      ],
      child: MultiBlocProvider(
        providers: [
          if (AppConfig.authEnabled)
            BlocProvider(
              create: (context) => SessionBloc(
                repository: context.read<AuthRepository>(),
              ),
            ),
          BlocProvider(
            create: (context) => ExpenseCubit(
              context.read<ExpenseRepository>(),
            )..getExpensesIf(shouldLoadLocalData),
          ),
          BlocProvider(
            create: (context) => BudgetCubit(
              context.read<BudgetRepository>(),
            )..getBudgetsIf(shouldLoadLocalData),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(
              context.read<CategoryRepository>(),
            )..getCategoriesIf(shouldLoadLocalData),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
        ],
        child: AppConfig.authEnabled
            ? BlocListener<SessionBloc, SessionState>(
                listenWhen: (previous, current) =>
                    previous.user?.id != current.user?.id ||
                    previous.status != current.status,
                listener: (context, state) {
                  if (state.status == SessionStatus.authenticated) {
                    context.read<ExpenseCubit>().getExpenses();
                    context.read<BudgetCubit>().getBudgets();
                    context.read<CategoryCubit>().getCategories();
                  } else if (state.status == SessionStatus.unauthenticated) {
                    context.read<ExpenseCubit>().clear();
                    context.read<BudgetCubit>().clear();
                    context.read<CategoryCubit>().clear();
                  }
                },
                child: child,
              )
            : child,
      ),
    );
  }
}

extension on ExpenseCubit {
  ExpenseCubit getExpensesIf(bool shouldLoad) {
    if (shouldLoad) getExpenses();
    return this;
  }
}

extension on BudgetCubit {
  BudgetCubit getBudgetsIf(bool shouldLoad) {
    if (shouldLoad) getBudgets();
    return this;
  }
}

extension on CategoryCubit {
  CategoryCubit getCategoriesIf(bool shouldLoad) {
    if (shouldLoad) getCategories();
    return this;
  }
}
