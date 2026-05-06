import 'package:expenses_tracker/src/utils/utils.dart';

abstract class CategoryRepository {
  FutureEither<List<String>> getCategories();
  FutureEitherVoid saveCategories(List<String> categories);
  FutureEitherVoid addCategory(String category);
  FutureEitherVoid deleteCategory(String category);
}
