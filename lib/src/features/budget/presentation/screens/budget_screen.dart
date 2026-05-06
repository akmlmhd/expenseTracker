import 'package:fl_chart/fl_chart.dart';
import 'package:expenses_tracker/src/features/categories/category_icons.dart';
import 'package:expenses_tracker/src/features/categories/presentation/cubit/category_cubit.dart';
import 'package:expenses_tracker/src/features/categories/presentation/cubit/category_state.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expenses_tracker/src/features/expenses/domain/models/expense_model.dart';
import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../../domain/models/budget_model.dart';

class BudgetScreen extends HookWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedMonth = useState(DateTime.now());

    void showMonthPicker() async {
      final picked = await showDialog<DateTime>(
        context: context,
        builder: (context) => _MonthYearPickerDialog(
          initialDate: selectedMonth.value,
        ),
      );

      if (picked != null) {
        selectedMonth.value = picked;
      }
    }

    void showAddBudgetDialog(List<String> categories) {
      showDialog<void>(
        context: context,
        builder: (context) => _AddBudgetDialog(
          categories: categories,
          selectedMonth: selectedMonth.value,
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: 'Budget',
        actions: [
          IconButton(
            onPressed: () {
              final categories =
                  context.read<CategoryCubit>().currentCategories;
              if (categories.isEmpty) {
                showToast(context,
                    message: 'Please add a category first', status: 'error');
                return;
              }
              showAddBudgetDialog(categories);
            },
            icon: const Icon(FlutterRemix.add_line),
          ),
        ],
      ),
      body: FinanceSurface(
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, _) {
            return BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, expenseState) {
                return BlocBuilder<BudgetCubit, BudgetState>(
                  builder: (context, budgetState) {
                    if (expenseState is ExpenseLoading ||
                        budgetState is BudgetLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (budgetState is BudgetLoaded &&
                        expenseState is ExpenseLoaded) {
                      final budgets = budgetState.budgets
                          .where((b) =>
                              b.month.month == selectedMonth.value.month &&
                              b.month.year == selectedMonth.value.year)
                          .toList();

                      final expenses = expenseState.expenses
                          .where((e) =>
                              !e.isIncome &&
                              e.date.month == selectedMonth.value.month &&
                              e.date.year == selectedMonth.value.year)
                          .toList();

                      double totalBudget = 0;
                      for (var b in budgets) {
                        totalBudget += b.amount;
                      }

                      double totalSpent = 0;
                      for (var e in expenses) {
                        totalSpent += e.amount;
                      }

                      final remaining = totalBudget - totalSpent;
                      final progress = totalBudget > 0
                          ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                          : 0.0;

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(AppSpacing.lg.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Month selector
                            GestureDetector(
                              onTap: showMonthPicker,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md.w,
                                  vertical: AppSpacing.sm.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      FlutterRemix.calendar_line,
                                      size: 18.sp,
                                      color: colorScheme.primary,
                                    ),
                                    SizedBox(width: AppSpacing.sm.w),
                                    Text(
                                      _formatMonth(selectedMonth.value),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.xs.w),
                                    Icon(
                                      FlutterRemix.arrow_down_s_line,
                                      size: 18.sp,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: AppSpacing.lg.h),

                            /// Main summary card
                            FinanceHeroCard(
                              padding: EdgeInsets.all(AppSpacing.lg.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Monthly Budget',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.sm.h),
                                  Text(
                                    'RM ${totalBudget.toStringAsFixed(2)}',
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.lg.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _BudgetSummaryItem(
                                          label: 'Spent',
                                          value:
                                              'RM ${totalSpent.toStringAsFixed(2)}',
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.md.w),
                                      Expanded(
                                        child: _BudgetSummaryItem(
                                          label: 'Remaining',
                                          value:
                                              'RM ${remaining.toStringAsFixed(2)}',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacing.lg.h),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999.r),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 10.h,
                                      backgroundColor: colorScheme.onPrimary
                                          .withOpacity(0.18),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.sm.h),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}% of your budget has been used',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimary
                                          .withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppSpacing.xl.h),

                            if (expenses.isNotEmpty) ...[
                              Text(
                                'Spending Distribution',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md.h),
                              _SpendingPieChart(expenses: expenses),
                              SizedBox(height: AppSpacing.xl.h),
                            ],

                            Text(
                              'Category Budgets',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md.h),

                            if (budgets.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: Text('No budgets set for this month'),
                                ),
                              )
                            else
                              ...budgets.map((budget) {
                                final categorySpent = expenses
                                    .where((e) => e.category == budget.category)
                                    .fold(0.0, (sum, e) => sum + e.amount);

                                return _BudgetCategoryCard(
                                  icon: iconForCategory(budget.category),
                                  title: budget.category,
                                  spent: categorySpent,
                                  total: budget.amount,
                                  onDelete: () => context
                                      .read<BudgetCubit>()
                                      .deleteBudget(budget.id),
                                );
                              }),

                            SizedBox(height: AppSpacing.xl.h),

                            Text(
                              'Tips',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md.h),

                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppSpacing.md.w),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    FlutterRemix.lightbulb_flash_line,
                                    color: colorScheme.primary,
                                    size: 22.sp,
                                  ),
                                  SizedBox(width: AppSpacing.sm.w),
                                  Expanded(
                                    child: Text(
                                      progress > 0.8
                                          ? 'You have used more than 80% of your total budget. Be careful with your spending!'
                                          : 'You are doing great! Keep tracking your expenses to stay within budget.',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppSpacing.xl.h),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month]} ${date.year}';
  }
}

class _MonthYearPickerDialog extends HookWidget {
  final DateTime initialDate;

  const _MonthYearPickerDialog({required this.initialDate});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedYear = useState(initialDate.year);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Year Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => selectedYear.value--,
                  icon: const Icon(FlutterRemix.arrow_left_s_line),
                ),
                Text(
                  '${selectedYear.value}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => selectedYear.value++,
                  icon: const Icon(FlutterRemix.arrow_right_s_line),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md.h),

            /// Month Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm.h,
                crossAxisSpacing: AppSpacing.sm.w,
                childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = selectedYear.value == initialDate.year &&
                    month == initialDate.month;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, DateTime(selectedYear.value, month));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      months[index],
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: AppSpacing.lg.h),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBudgetDialog extends HookWidget {
  final List<String> categories;
  final DateTime selectedMonth;

  const _AddBudgetDialog({
    required this.categories,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCategory = useState(categories.first);
    final amountController = useTextEditingController();
    final theme = context.theme;

    return AlertDialog(
      title: Text(
        'Add Category Budget',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedCategory.value,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => selectedCategory.value = val!,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget Amount',
              prefixText: 'RM ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text) ?? 0;
            if (amount > 0) {
              final budget = Budget(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                category: selectedCategory.value,
                amount: amount,
                month: selectedMonth,
              );
              context.read<BudgetCubit>().addBudget(budget);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _BudgetSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetSummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double spent;
  final double total;
  final VoidCallback onDelete;

  const _BudgetCategoryCard({
    required this.icon,
    required this.title,
    required this.spent,
    required this.total,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    final progress = (spent / total).clamp(0.0, 1.0);
    final remaining = total - spent;
    final isOverBudget = spent > total;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 22.sp,
                ),
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'RM ${spent.toStringAsFixed(0)} / RM ${total.toStringAsFixed(0)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOverBudget
                        ? 'RM ${(spent - total).toStringAsFixed(0)} over'
                        : 'RM ${remaining.toStringAsFixed(0)} left',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOverBudget
                          ? Colors.red
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(FlutterRemix.delete_bin_line,
                        size: 16.sp, color: Colors.red.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingPieChart extends StatelessWidget {
  final List<Expense> expenses;

  const _SpendingPieChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    // Group expenses by category
    final Map<String, double> categoryMap = {};
    for (var e in expenses) {
      categoryMap[e.category] = (categoryMap[e.category] ?? 0) + e.amount;
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final chartColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40.r,
                sections: sortedCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return PieChartSectionData(
                    color: chartColors[index % chartColors.length],
                    value: category.value,
                    title:
                        '${(category.value / totalSpent * 100).toStringAsFixed(0)}%',
                    radius: 50.r,
                    titleStyle: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Wrap(
            spacing: AppSpacing.md.w,
            runSpacing: AppSpacing.xs.h,
            alignment: WrapAlignment.center,
            children: sortedCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: chartColors[index % chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    category.key,
                    style: textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
