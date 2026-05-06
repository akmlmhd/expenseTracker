import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';
import 'package:expenses_tracker/src/features/auth/domain/entities/user.dart';
import 'package:expenses_tracker/src/features/auth/presentation/providers/session_bloc.dart';
import 'package:expenses_tracker/src/features/categories/category_icons.dart';
import 'package:expenses_tracker/src/features/expenses/domain/models/expense_model.dart';
import 'package:expenses_tracker/src/features/budget/domain/models/budget_model.dart';
import '../../../budget/presentation/cubit/budget_cubit.dart';
import '../../../budget/presentation/cubit/budget_state.dart';
import '../../../expenses/presentation/cubit/expense_cubit.dart';
import '../../../expenses/presentation/cubit/expense_state.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final user =
        AppConfig.authEnabled ? context.watch<SessionBloc>().state.user : null;

    return Scaffold(
      body: FinanceSurface(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            return BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, budgetState) {
                final isLoading = expenseState is ExpenseLoading ||
                    budgetState is BudgetLoading;

                // Extract data if loaded, otherwise use dummy for skeleton
                final allExpenses = expenseState is ExpenseLoaded
                    ? expenseState.expenses
                    : <Expense>[];
                final allBudgets = budgetState is BudgetLoaded
                    ? budgetState.budgets
                    : <Budget>[];

                final now = DateTime.now();

                // Calculate Totals
                double totalIncome = 0;
                double totalExpense = 0;
                for (var e in allExpenses) {
                  if (e.isIncome)
                    totalIncome += e.amount;
                  else
                    totalExpense += e.amount;
                }
                final balance = totalIncome - totalExpense;

                // Monthly Stats
                final thisMonthExpenses = allExpenses
                    .where((e) =>
                        e.date.month == now.month && e.date.year == now.year)
                    .toList();
                double monthlyIncome = 0;
                double monthlyExpense = 0;
                for (var e in thisMonthExpenses) {
                  if (e.isIncome) {
                    monthlyIncome += e.amount;
                  } else {
                    monthlyExpense += e.amount;
                  }
                }

                // Today's Stats
                final todayExpenses = allExpenses
                    .where((e) =>
                        e.date.year == now.year &&
                        e.date.month == now.month &&
                        e.date.day == now.day)
                    .toList();
                double todayIncome = 0;
                double todayExpense = 0;
                for (var e in todayExpenses) {
                  if (e.isIncome) {
                    todayIncome += e.amount;
                  } else {
                    todayExpense += e.amount;
                  }
                }
                final todayChange = todayIncome - todayExpense;

                // Budget Stats
                final thisMonthBudgets = allBudgets
                    .where((b) =>
                        b.month.month == now.month && b.month.year == now.year)
                    .toList();
                double totalBudget = 0;
                for (var b in thisMonthBudgets) totalBudget += b.amount;

                final budgetProgress = totalBudget > 0
                    ? (monthlyExpense / totalBudget).clamp(0.0, 1.0)
                    : 0.0;
                final isOverBudget =
                    monthlyExpense > totalBudget && totalBudget > 0;

                // Recent Transactions
                final recentTransactions =
                    allExpenses.reversed.take(5).toList();

                return Skeletonizer(
                  enabled: isLoading,
                  child: CustomScrollView(
                    slivers: [
                      /// Header & Welcome
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(AppSpacing.lg.w, 30.h,
                              AppSpacing.lg.w, AppSpacing.md.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant),
                                  ),
                                  Text(
                                    _displayName(user),
                                    style: textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                              _NotificationButton(colorScheme: colorScheme),
                            ],
                          ),
                        ),
                      ),

                      /// Total Balance Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                          child: FinanceHeroCard(
                            padding: EdgeInsets.symmetric(
                              vertical: 24.h,
                              horizontal: 18.w,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.14),
                                        borderRadius:
                                            BorderRadius.circular(999.r),
                                      ),
                                      child: Text(
                                        'Current wallet',
                                        style: textTheme.labelMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FlutterRemix.wallet_3_line,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 18.h),
                                Text(
                                  'Total Balance',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'RM ${balance.toStringAsFixed(2)}',
                                  style: textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        todayChange >= 0
                                            ? FlutterRemix.arrow_right_up_line
                                            : FlutterRemix
                                                .arrow_right_down_line,
                                        size: 14.sp,
                                        color: todayChange >= 0
                                            ? const Color(0xFF00FFAA)
                                            : const Color(0xFFFF5252),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${todayChange >= 0 ? '+' : ''}RM ${todayChange.abs().toStringAsFixed(0)} (Today)',
                                        style: textTheme.labelMedium?.copyWith(
                                          color: todayChange >= 0
                                              ? const Color(0xFF00FFAA)
                                              : const Color(0xFFFF5252),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Spacing
                      SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.md.h)),

                      /// Income & Expense Cards
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Income',
                                  amount: totalIncome,
                                  isIncome: true,
                                  icon: FlutterRemix.arrow_down_line,
                                  iconColor: Colors.white,
                                  iconBgColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  backgroundColor: const Color(0xFF1D6F64),
                                ),
                              ),
                              SizedBox(width: AppSpacing.md.w),
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Expenses',
                                  amount: totalExpense,
                                  isIncome: false,
                                  icon: FlutterRemix.arrow_up_line,
                                  iconColor: Colors.white,
                                  iconBgColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  backgroundColor: const Color(0xFF9A3D3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Spacing
                      SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.lg.h)),

                      /// Monthly Budget Health
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget Limit',
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: AppSpacing.md.h),
                              Container(
                                padding: EdgeInsets.all(AppSpacing.md.w),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: AppShadows.subtle,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isOverBudget
                                              ? 'Exceeded Budget'
                                              : 'Keep it up!',
                                          style: textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isOverBudget
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'RM ${monthlyExpense.toStringAsFixed(0)} / RM ${totalBudget.toStringAsFixed(0)}',
                                          style: textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSpacing.sm.h),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: LinearProgressIndicator(
                                        value: budgetProgress,
                                        minHeight: 12.h,
                                        backgroundColor:
                                            colorScheme.surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          isOverBudget
                                              ? Colors.red
                                              : colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Recent Transactions Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              AppSpacing.lg.w,
                              AppSpacing.lg.h,
                              AppSpacing.lg.w,
                              AppSpacing.sm.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Transactions',
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.transactions),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Transactions List
                      recentTransactions.isEmpty && !isLoading
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FlutterRemix.history_line,
                                        size: 48.sp,
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.3)),
                                    SizedBox(height: AppSpacing.sm.h),
                                    const Text('No transactions found'),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg.w),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final tx = isLoading
                                        ? _dummyExpense
                                        : recentTransactions[index];
                                    return _HomeTransactionTile(
                                      icon: iconForCategory(tx.category),
                                      title: tx.title,
                                      date: _formatDate(tx.date),
                                      amount: tx.amount,
                                      isIncome: tx.isIncome,
                                    );
                                  },
                                  childCount:
                                      isLoading ? 5 : recentTransactions.length,
                                ),
                              ),
                            ),
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _displayName(AppUser? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user?.email.trim();
    if (email != null && email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }

    return 'User';
  }

  static final _dummyExpense = Expense(
    id: '1',
    title: 'Grocery Store',
    amount: 50.0,
    date: DateTime.now(),
    category: 'Food',
    isIncome: false,
  );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day)
      return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) return 'Yesterday';
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month]}';
  }
}

class _NotificationButton extends StatelessWidget {
  final ColorScheme colorScheme;
  const _NotificationButton({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(FlutterRemix.notification_3_line,
              size: 20.sp, color: colorScheme.onSurface),
        ),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            width: 8.r,
            height: 8.r,
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color backgroundColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'RM ${amount.toStringAsFixed(0)}',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final double amount;
  final bool isIncome;

  const _HomeTransactionTile({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  date,
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} RM ${amount.toStringAsFixed(2)}',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
