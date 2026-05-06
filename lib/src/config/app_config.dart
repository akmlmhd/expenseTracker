import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/logger.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;

  static String get baseUrl => _getBaseUrl();
  static bool get authEnabled {
    try {
      return dotenv.get('AUTH_ENABLED', fallback: 'false').toLowerCase() ==
          'true';
    } catch (_) {
      return false;
    }
  }

  static String get firebaseDatabaseUrl => dotenv.get(
        'FIREBASE_DATABASE_URL',
        fallback:
            'https://expensestracker-487f6-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

  static FirebaseOptions get firebaseOptions => FirebaseOptions(
        apiKey: dotenv.get('FIREBASE_API_KEY'),
        appId: dotenv.get('FIREBASE_APP_ID'),
        messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: dotenv.get(
          'FIREBASE_PROJECT_ID',
          fallback: 'expensestracker-487f6',
        ),
        authDomain: dotenv.maybeGet('FIREBASE_AUTH_DOMAIN'),
        databaseURL: firebaseDatabaseUrl,
        storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
      );

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.info(
              '🌐 [DIO] REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info(
              '✅ [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.error(
              '❌ [DIO] ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  static String _getBaseUrl() {
    return dotenv.get('API_BASE_URL', fallback: 'https://rms.oceztra.com/api/');
  }
}
