import 'package:expenses_tracker/src/features/categories/presentation/cubit/category_cubit.dart';
import 'package:expenses_tracker/src/features/categories/presentation/cubit/category_state.dart';
import 'package:expenses_tracker/src/features/auth/domain/entities/user.dart';
import 'package:expenses_tracker/src/features/auth/presentation/providers/session_bloc.dart';
import 'package:expenses_tracker/src/features/budget/domain/models/budget_model.dart';
import 'package:expenses_tracker/src/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:expenses_tracker/src/features/budget/presentation/cubit/budget_state.dart';
import 'package:expenses_tracker/src/features/expenses/domain/models/expense_model.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expenses_tracker/src/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expenses_tracker/src/shared/cubit/theme_cubit.dart';

import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = theme.textTheme;
    final user = AppConfig.authEnabled ? context.watch<SessionBloc>().state.user : null;
    final expenseState = context.watch<ExpenseCubit>().state;
    final budgetState = context.watch<BudgetCubit>().state;
    final isStatsLoading = expenseState is ExpenseLoading || budgetState is BudgetLoading;
    final expenses = expenseState is ExpenseLoaded ? expenseState.expenses : const <Expense>[];
    final budgets = budgetState is BudgetLoaded ? budgetState.budgets : const <Budget>[];
    final totalIncome = expenses.where((expense) => expense.isIncome).fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalExpense = expenses.where((expense) => !expense.isIncome).fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalBudget = budgets.fold<double>(0, (sum, budget) => sum + budget.amount);
    final savings = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppTopBar(
        title: 'profile.profile_title'.tr(),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(FlutterRemix.settings_3_line),
          // ),
        ],
      ),
      body: FinanceSurface(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile header
              FinanceHeroCard(
                padding: EdgeInsets.all(AppSpacing.lg.w),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36.r,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: Icon(
                        FlutterRemix.user_3_line,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    Text(
                      _displayName(user),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user?.email ?? 'Local account',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                    Skeletonizer(
                      enabled: isStatsLoading,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProfileStatCard(
                              label: 'Transaction',
                              value: isStatsLoading ? 'RM 1200.00' : 'RM ${totalExpense.toStringAsFixed(2)}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileStatCard(
                              label: 'Budgets',
                              value: isStatsLoading ? 'RM 2400.00' : 'RM ${totalBudget.toStringAsFixed(2)}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileStatCard(
                              label: 'Savings',
                              value: isStatsLoading ? 'RM 900.00' : 'RM ${savings.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xl.h),

              Text(
                'profile.preferences'.tr(),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorSurface(context),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),

              // _ProfileMenuTile(
              //   icon: FlutterRemix.notification_3_line,
              //   title: 'Notifications',
              //   subtitle: 'Manage reminders and alerts',
              //   onTap: () {},
              // ),
              _ProfileMenuTile(
                icon: FlutterRemix.price_tag_3_line,
                title: 'Categories',
                subtitle: 'Manage transaction and budget categories',
                onTap: () => _showCategoryManager(context),
              ),
              _ProfileMenuTile(
                icon: FlutterRemix.translate_2,
                title: 'profile.language'.tr(),
                subtitle: 'profile.change_language'.tr(),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    ),
                    builder: (context) {
                      final currentLocale = context.locale;
                      return Padding(
                        padding: EdgeInsets.all(AppSpacing.lg.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'profile.select_language'.tr(),
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: AppSpacing.lg.h),
                            _SelectionOption(
                              title: 'English',
                              isSelected: currentLocale.languageCode == 'en',
                              onTap: () {
                                context.setLocale(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _SelectionOption(
                              title: '中文 (Chinese)',
                              isSelected: currentLocale.languageCode == 'zh',
                              onTap: () {
                                context.setLocale(const Locale('zh'));
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(height: AppSpacing.xl.h),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              _ProfileMenuTile(
                icon: FlutterRemix.moon_clear_line,
                title: 'profile.appearance'.tr(),
                subtitle: 'profile.change_appearance'.tr(),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    ),
                    builder: (context) {
                      final currentTheme = context.watch<ThemeCubit>().state;
                      return Padding(
                        padding: EdgeInsets.all(AppSpacing.lg.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'profile.select_appearance'.tr(),
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: AppSpacing.lg.h),
                            _SelectionOption(
                              title: 'profile.light'.tr(),
                              isSelected: currentTheme == ThemeMode.light,
                              onTap: () {
                                context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _SelectionOption(
                              title: 'profile.dark'.tr(),
                              isSelected: currentTheme == ThemeMode.dark,
                              onTap: () {
                                context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _SelectionOption(
                              title: 'profile.system'.tr(),
                              isSelected: currentTheme == ThemeMode.system,
                              onTap: () {
                                context.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(height: AppSpacing.xl.h),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: AppSpacing.xl.h),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (AppConfig.authEnabled) {
                      context.read<SessionBloc>().add(const SessionLogoutRequested());
                      context.go(AppRoutes.login);
                    }
                  },
                  icon: const Icon(FlutterRemix.logout_box_r_line),
                  label: Text('profile.logout'.tr()),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.xl.h),
            ],
          ),
        ),
      ),
    );
  }

  Color colorSurface(BuildContext context) => context.theme.colorScheme.onSurface;

  String _displayName(AppUser? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user?.email.trim();
    if (email != null && email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }

    return 'User';
  }

  void _showCategoryManager(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (sheetContext) => const _CategoryManagerSheet(),
    );
  }
}

class _CategoryManagerSheet extends HookWidget {
  const _CategoryManagerSheet();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg.w,
        right: AppSpacing.lg.w,
        top: AppSpacing.md.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl.h,
      ),
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
                'Categories',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(FlutterRemix.close_line),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Add category',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addCategory(context, controller),
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              FilledButton(
                onPressed: () => _addCategory(context, controller),
                child: const Icon(FlutterRemix.add_line),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return Skeletonizer(
                  enabled: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 360.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            index.isEven ? 'Category name' : 'Another category',
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(FlutterRemix.delete_bin_line),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              final categories = state is CategoryLoaded ? state.categories : <String>[];
              if (categories.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
                  child: Center(
                    child: Text(
                      'No categories yet',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 360.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(category, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        onPressed: categories.length == 1 ? null : () => context.read<CategoryCubit>().deleteCategory(category),
                        icon: const Icon(FlutterRemix.delete_bin_line),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addCategory(BuildContext context, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    context.read<CategoryCubit>().addCategory(value);
    controller.clear();
  }
}

class _SelectionOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            if (isSelected)
              Icon(
                FlutterRemix.checkbox_circle_fill,
                color: colorScheme.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return SizedBox(
      height: 76.h,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 24.h,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  value,
                  maxLines: 1,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              height: 18.h,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  label,
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: 4.h,
        ),
        leading: Container(
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
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          FlutterRemix.arrow_right_s_line,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
