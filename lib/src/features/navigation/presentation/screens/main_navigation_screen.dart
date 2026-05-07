import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';

import 'package:expenses_tracker/src/features/home/presentation/screens/home_page.dart';
import 'package:expenses_tracker/src/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expenses_tracker/src/features/budget/presentation/screens/budget_screen.dart';
import 'package:expenses_tracker/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:expenses_tracker/src/shared/widgets/app_bottom_navbar.dart';

class MainNavigationScreen extends StatelessWidget {
  final int currentIndex;

  const MainNavigationScreen({
    super.key,
    required this.currentIndex,
  });

  static const List<Widget> _screens = [
    HomePage(),
    TransactionsScreen(),
    BudgetScreen(),
    ProfileScreen(),
  ];

  static const List<String> _routes = [
    AppRoutes.home,
    AppRoutes.transactions,
    AppRoutes.budget,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final pageIndex = currentIndex > 2 ? currentIndex - 1 : currentIndex;

    return Scaffold(
      body: _AnimatedTabStack(
        index: pageIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showAddExpenseSheet(context);
            return;
          }
          if (index != currentIndex) {
            context.go(_routes[index > 2 ? index - 1 : index]);
          }
        },
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseScreen(),
    );
  }
}

class _AnimatedTabStack extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const _AnimatedTabStack({
    required this.index,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (childIndex) {
        final isActive = childIndex == index;
        final slideOffset = childIndex < index
            ? const Offset(-0.04, 0)
            : childIndex > index
                ? const Offset(0.04, 0)
                : Offset.zero;

        return IgnorePointer(
          ignoring: !isActive,
          child: TickerMode(
            enabled: isActive,
            child: AnimatedOpacity(
              opacity: isActive ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedSlide(
                offset: isActive ? Offset.zero : slideOffset,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: children[childIndex],
              ),
            ),
          ),
        );
      }),
    );
  }
}
