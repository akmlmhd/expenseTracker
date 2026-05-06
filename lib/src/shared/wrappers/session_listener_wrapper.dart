import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/packages_imports.dart';

import 'package:expenses_tracker/src/features/auth/presentation/providers/session_bloc.dart';

class SessionListenerWrapper extends StatefulWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  State<SessionListenerWrapper> createState() => _SessionListenerWrapperState();
}

class _SessionListenerWrapperState extends State<SessionListenerWrapper> {
  String? _lastRedirect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionBloc, SessionState>(
      listenWhen: (prev, next) =>
          prev.status != next.status || prev.user?.id != next.user?.id,
      listener: _syncRoute,
      builder: (context, state) {
        _scheduleRouteSync(context, state);
        return widget.child;
      },
    );
  }

  void _scheduleRouteSync(BuildContext context, SessionState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncRoute(context, state);
    });
  }

  void _syncRoute(BuildContext context, SessionState state) {
    if (state.status == SessionStatus.unknown) return;

    FlutterNativeSplash.remove();

    final currentPath = appRouter.routerDelegate.currentConfiguration.uri.path;
    final targetPath = _targetPathFor(state, currentPath);
    if (targetPath == null || targetPath == currentPath) return;
    if (_lastRedirect == '$currentPath->$targetPath') return;

    _lastRedirect = '$currentPath->$targetPath';
    context.go(targetPath);
  }

  String? _targetPathFor(SessionState state, String currentPath) {
    final completedOnboarding =
        StorageService.instance.getBool('onboarding_completed') ?? false;
    final authPaths = {
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
    };

    if (!completedOnboarding && currentPath != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    if (state.status == SessionStatus.authenticated) {
      if (currentPath == AppRoutes.onboarding ||
          authPaths.contains(currentPath)) {
        return AppRoutes.home;
      }
      return null;
    }

    if (state.status == SessionStatus.unauthenticated) {
      if (!completedOnboarding) return AppRoutes.onboarding;
      final hasCachedSession =
          StorageService.instance.getBool('firebase_session_active') ?? false;
      if (hasCachedSession) return null;
      if (!authPaths.contains(currentPath)) return AppRoutes.login;
    }

    return null;
  }
}
