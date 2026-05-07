import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // The Navigation Bar Container
          Container(
            height: 70.h,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppBorders.full,
              boxShadow: AppShadows.card,
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavBarItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: FlutterRemix.home_5_line,
                  activeIcon: FlutterRemix.home_5_fill,
                  label: 'Home',
                  onTap: onTap,
                ),
                _NavBarItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: FlutterRemix.file_list_3_line,
                  activeIcon: FlutterRemix.file_list_3_fill,
                  label: 'History',
                  onTap: onTap,
                ),
                // Middle gap for the FAB
                SizedBox(width: 60.w),
                _NavBarItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: FlutterRemix.pie_chart_2_line,
                  activeIcon: FlutterRemix.pie_chart_2_fill,
                  label: 'Budget',
                  onTap: onTap,
                ),
                _NavBarItem(
                  index: 4,
                  currentIndex: currentIndex,
                  icon: FlutterRemix.user_3_line,
                  activeIcon: FlutterRemix.user_3_fill,
                  label: 'Profile',
                  onTap: onTap,
                ),
              ],
            ),
          ),

          // The Floating Bold Add Button
          Positioned(
            bottom: 20.h, // Lift it slightly
            child: _AddButton(
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AddButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 0.94 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.elevated,
            border: Border.all(
              color: colorScheme.surface,
              width: 4.r,
            ),
          ),
          child: Icon(
            FlutterRemix.add_line,
            color: colorScheme.onPrimary,
            size: 32.r,
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final colorScheme = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final baseLabelStyle = tt.labelSmall ?? DefaultTextStyle.of(context).style;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: AppBorders.full,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey('${label}_$isSelected'),
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 24.r,
                ),
              ),
            ),
            if (label.isNotEmpty) ...[
              SizedBox(height: 2.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                style: baseLabelStyle.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10.sp,
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
