import 'package:get_it/get_it.dart';
import 'mqtt_service.dart';
import 'storage_service.dart';
import 'theme_service.dart';
import 'logger_service.dart';
import 'error_handler.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> initialize() async {
    // Singleton servisler
    getIt.registerLazySingleton(() => LoggerService());
    getIt.registerLazySingleton(() => ErrorHandler());
    getIt.registerLazySingleton(() => ThemeService());
    getIt.registerLazySingleton(() => StorageService());
    getIt.registerLazySingleton(() => MqttService());

    // Servisleri başlat
    final logger = getIt<LoggerService>();
    final errorHandler = getIt<ErrorHandler>();
    final themeService = getIt<ThemeService>();
    final storageService = getIt<StorageService>();

    try {
      logger.info('Uygulama servisleri başlatılıyor...');
      
      errorHandler.initialize();
      await themeService.initialize();
      await storageService.initialize();

      logger.info('Tüm servisler başarıyla başlatıldı.');
    } catch (e, stackTrace) {
      logger.error(
        'Servis başlatma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> dispose() async {
    final logger = getIt<LoggerService>();
    final storageService = getIt<StorageService>();
    final mqttService = getIt<MqttService>();

    logger.info('Servisler kapatılıyor...');

    try {
      // MqttService'i önce kapat
      mqttService.disconnect();
      mqttService.dispose();

      // Sonra StorageService'i kapat
      await storageService.dispose();
      
      logger.info('Tüm servisler başarıyla kapatıldı.');
    } catch (e, stackTrace) {
      logger.error(
        'Servis kapatma hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
} 