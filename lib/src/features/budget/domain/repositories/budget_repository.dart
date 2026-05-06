import 'package:expenses_tracker/src/utils/utils.dart';
import '../models/budget_model.dart';

abstract class BudgetRepository {
  FutureEither<List<Budget>> getBudgets();
  FutureEitherVoid addBudget(Budget budget);
  FutureEitherVoid deleteBudget(String id);
  FutureEitherVoid updateBudget(Budget budget);
}
