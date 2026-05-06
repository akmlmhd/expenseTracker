import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';
import 'hive_registrar.g.dart';

import 'src/features/auth/domain/repositories/auth_repository.dart';
import 'src/features/auth/data/repositories/auth_repository_impl.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await AppConfig.init();
  if (AppConfig.authEnabled) {
    await Firebase.initializeApp(options: AppConfig.firebaseOptions);
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  }
  await StorageService.instance.init();
  await HiveService.instance.init();
  Hive.registerAdapters();

  runApp(
    LocalizationWrapper(
      child: RepositoryProvider<AuthRepository>(
        create: (_) => AuthRepositoryImpl(),
        child: const StateWrapper(
          child: App(),
        ),
      ),
    ),
  );
}
