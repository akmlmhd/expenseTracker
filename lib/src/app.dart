import 'package:expenses_tracker/src/imports/core_imports.dart';
import 'package:expenses_tracker/src/imports/imports.dart';
import 'package:expenses_tracker/src/shared/cubit/theme_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Widget current = _buildMaterialApp(context);

    current = ScreenUtilWrapper(child: current);

    return current;
  }

  Widget _buildMaterialApp(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;

    return MaterialApp.router(
      title: 'Expenses Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#1568a8'),
      darkTheme: buildDarkTheme(primaryColorHex: '#1568a8'),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        if (AppConfig.authEnabled) {
          current = SessionListenerWrapper(child: current);
        } else {
          FlutterNativeSplash.remove();
        }
        return current;
      },
    );
  }
}
