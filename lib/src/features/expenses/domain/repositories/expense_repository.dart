import 'package:expenses_tracker/src/utils/utils.dart';
import '../models/expense_model.dart';

abstract class ExpenseRepository {
  FutureEither<List<Expense>> getExpenses();
  FutureEitherVoid addExpense(Expense expense);
  FutureEitherVoid deleteExpense(String id);
  FutureEitherVoid updateExpense(Expense expense);
}
