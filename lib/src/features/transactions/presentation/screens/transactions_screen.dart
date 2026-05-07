import 'package:expenses_tracker/src/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expenses_tracker/src/features/categories/category_icons.dart';
import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';

import '../../../expenses/domain/models/expense_model.dart';

class TransactionsScreen extends HookWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedFilter = useState('This Month');
    final customDateRange = useState<DateTimeRange?>(null);

    return Scaffold(
      appBar: const AppTopBar(
        title: 'Transactions',
        // actions: [
        //   IconButton(
        //     icon: const Icon(FlutterRemix.search_line),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.go(AppRoutes.addExpense),
      //   backgroundColor: colorScheme.primary,
      //   child: const Icon(FlutterRemix.add_line, color: Colors.white),
      // ),
      body: FinanceSurface(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return Skeletonizer(
                enabled: true,
                child: Column(
                  children: [
                    _buildSummaryAndFilters(
                      context,
                      selectedFilter,
                      customDateRange,
                      _placeholderExpenses(),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final expense = _placeholderExpenses()[index];
                          return _TransactionTile(
                            icon: iconForCategory(expense.category),
                            title: expense.title,
                            category: expense.category,
                            amount: '- RM ${expense.amount.toStringAsFixed(2)}',
                            isIncome: expense.isIncome,
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ExpenseError) {
              return Center(child: Text(state.message));
            }

            if (state is ExpenseLoaded) {
              final allExpenses = state.expenses;

              // Apply filtering logic
              final filteredExpenses = allExpenses.where((expense) {
                final now = DateTime.now();
                final date = expense.date;

                if (selectedFilter.value == 'Today') {
                  return date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                } else if (selectedFilter.value == 'This Week') {
                  final weekStart =
                      now.subtract(Duration(days: now.weekday - 1));
                  final startOfDay =
                      DateTime(weekStart.year, weekStart.month, weekStart.day);
                  return date
                      .isAfter(startOfDay.subtract(const Duration(seconds: 1)));
                } else if (selectedFilter.value == 'This Month') {
                  return date.year == now.year && date.month == now.month;
                } else if (selectedFilter.value == 'Custom' &&
                    customDateRange.value != null) {
                  return date.isAfter(customDateRange.value!.start
                          .subtract(const Duration(seconds: 1))) &&
                      date.isBefore(customDateRange.value!.end
                          .add(const Duration(days: 1)));
                }
                return true; // Default to all if custom but no range
              }).toList();

              if (filteredExpenses.isEmpty) {
                return Column(
                  children: [
                    _buildSummaryAndFilters(context, selectedFilter,
                        customDateRange, filteredExpenses),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FlutterRemix.history_line,
                                size: 64.sp,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.5)),
                            SizedBox(height: AppSpacing.md.h),
                            Text('No transactions found',
                                style: textTheme.titleMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  /// Summary Card & Filters
                  _buildSummaryAndFilters(context, selectedFilter,
                      customDateRange, filteredExpenses),

                  SizedBox(height: AppSpacing.md.h),

                  /// Transaction List
                  Expanded(
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense =
                            filteredExpenses.reversed.toList()[index];
                        return _TransactionTile(
                          icon: iconForCategory(expense.category),
                          title: expense.title,
                          category: expense.category,
                          amount:
                              '${expense.isIncome ? '+' : '-'} RM ${expense.amount.toStringAsFixed(2)}',
                          isIncome: expense.isIncome,
                          onTap: () => _showEditTransactionSheet(
                            context,
                            expense,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showEditTransactionSheet(BuildContext context, Expense expense) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseScreen(expense: expense),
    );
  }

  List<Expense> _placeholderExpenses() {
    final now = DateTime.now();
    return List.generate(
      5,
      (index) => Expense(
        id: 'loading-$index',
        title: 'Transaction title',
        amount: 125 + (index * 25),
        date: now,
        category: index.isEven ? 'Food' : 'Salary',
        isIncome: index == 1,
      ),
    );
  }

  Widget _buildSummaryAndFilters(
    BuildContext context,
    ValueNotifier<String> selectedFilter,
    ValueNotifier<DateTimeRange?> customDateRange,
    List<Expense> expenses,
  ) {
    final theme = context.theme;
    final textTheme = theme.textTheme;

    // Calculate totals for the filtered list
    double totalIncome = 0;
    double totalExpense = 0;
    for (var e in expenses) {
      if (e.isIncome) {
        totalIncome += e.amount;
      } else {
        totalExpense += e.amount;
      }
    }
    final balance = totalIncome - totalExpense;

    String filterLabel = selectedFilter.value;
    if (selectedFilter.value == 'Custom' && customDateRange.value != null) {
      final start = customDateRange.value!.start;
      final end = customDateRange.value!.end;
      filterLabel = '${start.day}/${start.month} - ${end.day}/${end.month}';
    }

    return Column(
      children: [
        /// Summary Card
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: FinanceHeroCard(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filterLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  'RM ${balance.toStringAsFixed(2)}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        title: 'Income',
                        value: 'RM ${totalIncome.toStringAsFixed(0)}',
                        isIncome: true,
                      ),
                    ),
                    Expanded(
                      child: _SummaryItem(
                        title: 'Expense',
                        value: 'RM ${totalExpense.toStringAsFixed(0)}',
                        isIncome: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        /// Filter Chips
        SizedBox(
          height: 34.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            children: [
              _FilterChip(
                label: 'Today',
                selected: selectedFilter.value == 'Today',
                onTap: () => selectedFilter.value = 'Today',
              ),
              _FilterChip(
                label: 'This Week',
                selected: selectedFilter.value == 'This Week',
                onTap: () => selectedFilter.value = 'This Week',
              ),
              _FilterChip(
                label: 'This Month',
                selected: selectedFilter.value == 'This Month',
                onTap: () => selectedFilter.value = 'This Month',
              ),
              _FilterChip(
                label: selectedFilter.value == 'Custom' &&
                        customDateRange.value != null
                    ? '${customDateRange.value!.start.day}/${customDateRange.value!.start.month} - ${customDateRange.value!.end.day}/${customDateRange.value!.end.month}'
                    : 'Custom',
                icon: FlutterRemix.calendar_event_line,
                selected: selectedFilter.value == 'Custom',
                showClear: selectedFilter.value == 'Custom' &&
                    customDateRange.value != null,
                onClear: () {
                  customDateRange.value = null;
                  selectedFilter.value = 'This Month';
                },
                onTap: () async {
                  await _showCustomDateRangePicker(
                      context, customDateRange, selectedFilter);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showCustomDateRangePicker(
    BuildContext context,
    ValueNotifier<DateTimeRange?> customDateRange,
    ValueNotifier<String> selectedFilter,
  ) async {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    DateTime startDate = customDateRange.value?.start ??
        DateTime.now().subtract(const Duration(days: 7));
    DateTime endDate = customDateRange.value?.end ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            padding: EdgeInsets.fromLTRB(AppSpacing.lg.w, AppSpacing.md.h,
                AppSpacing.lg.w, AppSpacing.xl.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: AppSpacing.md.h),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date Range',
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(FlutterRemix.close_line),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg.h),
                Row(
                  children: [
                    Expanded(
                      child: _DateSelectorTile(
                        label: 'From',
                        date: startDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2020),
                            lastDate: endDate,
                          );
                          if (picked != null)
                            setState(() => startDate = picked);
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: _DateSelectorTile(
                        label: 'To',
                        date: endDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => endDate = picked);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      customDateRange.value =
                          DateTimeRange(start: startDate, end: endDate);
                      selectedFilter.value = 'Custom';
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r)),
                    ),
                    child: Text(
                      'Apply Range',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isIncome;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final amountColor = isIncome
        ? (isDark ? const Color(0xFF7DFF9A) : const Color(0xFF0B7A34))
        : (isDark ? const Color(0xFFFF8A8A) : const Color(0xFFB3261E));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: amountColor,
            shadows: isDark
                ? [
                    Shadow(
                      color: amountColor.withValues(alpha: 0.28),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool showClear;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.showClear = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16.sp,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: TextStyle(
                  color:
                      selected ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
              if (showClear) ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    FlutterRemix.close_circle_fill,
                    size: 16.sp,
                    color: selected
                        ? colorScheme.onPrimary.withOpacity(0.8)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;

  const _DateHeader(this.date);

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
      child: Text(
        date,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String category;
  final String amount;
  final bool isIncome;
  final VoidCallback onTap;

  const _TransactionTile({
    required this.icon,
    required this.title,
    required this.category,
    required this.amount,
    required this.onTap,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    category,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(
                  FlutterRemix.edit_2_line,
                  size: 16.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateSelectorTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(FlutterRemix.calendar_line,
                    size: 20.sp, color: colorScheme.primary),
                SizedBox(width: AppSpacing.sm.w),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
