import 'package:flutter/material.dart';
import 'dart:async';
import 'logger_service.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final _logger = LoggerService();

  void initialize() {
    // FlutterError.onError artık main.dart'tan ayarlanıyor
  }

  void handleFlutterError(FlutterErrorDetails details) {
    _logger.error(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  void handleZoneError(Object error, StackTrace stack) {
    _logger.error(
      'Zone Error',
      error: error,
      stackTrace: stack,
    );
  }

  String getUserFriendlyMessage(Object error) {
    if (error is FormatException) {
      return 'Veri biçimi hatası oluştu. Lütfen girdiğiniz bilgileri kontrol edin.';
    } else if (error is TimeoutException) {
      return 'İşlem zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
    } else if (error is MqttConnectionException) {
      return 'MQTT sunucusuna bağlanırken bir hata oluştu. Lütfen ayarlarınızı kontrol edin.';
    } else if (error is StorageException) {
      return 'Veri kaydetme/okuma hatası. Lütfen uygulamayı yeniden başlatın.';
    }
    
    return 'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
  }

  void showErrorDialog(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(getUserFriendlyMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getUserFriendlyMessage(error)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class MqttConnectionException implements Exception {
  final String message;
  MqttConnectionException(this.message);
  
  @override
  String toString() => message;
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  
  @override
  String toString() => message;
} 