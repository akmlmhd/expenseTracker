import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';
import 'package:expenses_tracker/src/features/categories/presentation/cubit/category_cubit.dart';
import 'package:expenses_tracker/src/features/categories/presentation/cubit/category_state.dart';
import '../../domain/models/expense_model.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class AddExpenseScreen extends HookWidget {
  final Expense? expense;

  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isEditing = expense != null;
    final selectedType =
        useState(expense?.isIncome == true ? 'Income' : 'Expense');
    final selectedCategory = useState<String?>(expense?.category);
    final selectedDate = useState(expense?.date ?? DateTime.now());

    final amountController = useTextEditingController(
      text: expense == null ? '' : expense!.amount.toStringAsFixed(2),
    );
    final noteController = useTextEditingController(text: expense?.note ?? '');

    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseActionSuccess) {
          showToast(context,
              message: isEditing
                  ? 'Transaction updated successfully!'
                  : 'Transaction saved successfully!',
              status: 'success');
          Navigator.pop(context);
        } else if (state is ExpenseError) {
          showToast(context, message: state.message, status: 'error');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
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
                  Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          FlutterRemix.add_circle_line,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Text(
                        isEditing ? 'Edit Transaction' : 'Add Transaction',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(FlutterRemix.close_line),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),

              /// Type selector
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Expense',
                        selected: selectedType.value == 'Expense',
                        onTap: () => selectedType.value = 'Expense',
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: _TypeButton(
                        label: 'Income',
                        selected: selectedType.value == 'Income',
                        onTap: () => selectedType.value = 'Income',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.lg.h),

              /// Amount
              Text(
                'Amount',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'RM ',
                  prefixStyle: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.md.h),

              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, categoryState) {
                  final categories = categoryState is CategoryLoaded
                      ? categoryState.categories
                      : <String>[];
                  final activeCategory = selectedCategory.value ??
                      (categories.isNotEmpty ? categories.first : null);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      if (categories.isEmpty)
                        Text(
                          'No categories available',
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.error),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((category) {
                              final isSelected = activeCategory == category;
                              return Padding(
                                padding:
                                    EdgeInsets.only(right: AppSpacing.sm.w),
                                child: _CategoryChip(
                                  label: category,
                                  selected: isSelected,
                                  onTap: () =>
                                      selectedCategory.value = category,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: AppSpacing.md.h),

              /// Date & Note Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate.value,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null)
                              selectedDate.value = pickedDate;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md.w,
                                vertical: AppSpacing.md.h),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Row(
                              children: [
                                Icon(FlutterRemix.calendar_line,
                                    size: 18.sp, color: colorScheme.primary),
                                SizedBox(width: AppSpacing.sm.w),
                                Text(_formatDate(selectedDate.value),
                                    style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md.h),

              Text(
                'Note',
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: AppSpacing.xs.h),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Add a short note...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: AppSpacing.lg.h),

              /// Save button
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    final isLoading = state is ExpenseLoading;
                    return FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final amount =
                                  double.tryParse(amountController.text) ?? 0;
                              if (amount <= 0) {
                                showToast(context,
                                    message: 'Please enter a valid amount',
                                    status: 'error');
                                return;
                              }
                              final categories = context
                                  .read<CategoryCubit>()
                                  .currentCategories;
                              final category = selectedCategory.value ??
                                  (categories.isNotEmpty
                                      ? categories.first
                                      : null);
                              if (category == null) {
                                showToast(context,
                                    message: 'Please add a category first',
                                    status: 'error');
                                return;
                              }
                              final updatedExpense = Expense(
                                id: expense?.id ??
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                title: category,
                                amount: amount,
                                date: selectedDate.value,
                                category: category,
                                note: noteController.text,
                                isIncome: selectedType.value == 'Income',
                              );
                              if (isEditing) {
                                context
                                    .read<ExpenseCubit>()
                                    .updateExpense(updatedExpense);
                              } else {
                                context
                                    .read<ExpenseCubit>()
                                    .addExpense(updatedExpense);
                              }
                            },
                      style: FilledButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing
                                  ? 'Update Transaction'
                                  : 'Save Transaction',
                              style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimary)),
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
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
    return months[month];
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
