import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';

class OnboardingPage extends HookWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final currentIndex = useState(0);

    final onboardingData = useMemoized(
      () => [
        {
          'title': 'Track every ringgit',
          'subtitle':
              'Log income and expenses quickly so your balance is always clear.',
          'icon': FlutterRemix.wallet_3_line,
        },
        {
          'title': 'Plan smarter budgets',
          'subtitle':
              'Set monthly category limits and see when spending needs attention.',
          'icon': FlutterRemix.pie_chart_2_line,
        },
        {
          'title': 'Understand your habits',
          'subtitle':
              'Review recent transactions, trends, and progress from one dashboard.',
          'icon': FlutterRemix.line_chart_line,
        },
      ],
    );

    Future<void> onGetStarted() async {
      await StorageService.instance.setBool('onboarding_completed', true);
      if (!context.mounted) return;
      context.go(AppConfig.authEnabled ? AppRoutes.login : AppRoutes.home);
    }

    return _OnboardingView(
      pageController: pageController,
      currentIndex: currentIndex.value,
      onboardingData: onboardingData,
      onPageChanged: (index) => currentIndex.value = index,
      onGetStarted: onGetStarted,
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({
    required this.pageController,
    required this.currentIndex,
    required this.onboardingData,
    required this.onPageChanged,
    required this.onGetStarted,
  });

  final PageController pageController;
  final int currentIndex;
  final List<Map<String, Object>> onboardingData;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: FinanceSurface(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.lg.h,
                  AppSpacing.lg.w,
                  AppSpacing.md.h,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        FlutterRemix.funds_box_line,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Text(
                      'Expenses Tracker',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    final item = onboardingData[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: _OnboardingVisual(
                                icon: item['icon'] as IconData,
                                index: index,
                              ),
                            ),
                          ),
                          Text(
                            item['title'] as String,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              fontSize: 28.sp,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md.h),
                          Text(
                            item['subtitle'] as String,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.xl.w),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: pageController,
                      count: onboardingData.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8.r,
                        dotWidth: 8.r,
                        activeDotColor: colorScheme.primary,
                        dotColor: colorScheme.outlineVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl.h),
                    AppButton(
                      label: 'shared.get_started'.tr(),
                      onPressed: onGetStarted,
                      variant: ButtonVariant.primary,
                      width: ButtonSize.large,
                    ),
                    SizedBox(height: AppSpacing.md.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({
    required this.icon,
    required this.index,
  });

  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260.r,
            height: 260.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  const Color(0xFF1D6F64),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.24),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
          ),
          Positioned(
            top: 52.r,
            right: 46.r,
            child: _MiniAmountPill(
              text: index == 0
                  ? '+RM 2,400'
                  : index == 1
                      ? '72% used'
                      : 'RM 318 left',
            ),
          ),
          Container(
            width: 130.r,
            height: 130.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: Colors.white, size: 58.r),
          ),
          Positioned(
            bottom: 48.r,
            left: 42.r,
            right: 42.r,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.sm.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: List.generate(
                  4,
                  (barIndex) => Expanded(
                    child: Container(
                      height: (20 + (barIndex + index) % 4 * 10).h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: barIndex == 2 ? 0.95 : 0.45,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAmountPill extends StatelessWidget {
  const _MiniAmountPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF1D6F64),
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
