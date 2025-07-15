import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  LogLevel _minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  void setMinimumLogLevel(LogLevel level) {
    _minimumLevel = level;
  }

  void log(String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minimumLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final prefix = '[${level.name.toUpperCase()}]';
    
    if (kDebugMode) {
      developer.log(
        '[$timestamp] $prefix $message',
        time: DateTime.now(),
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Hata raporlama servisine gönder
    if (level == LogLevel.error) {
      _reportError(message, error, stackTrace);
    }
  }

  void debug(String message) {
    log(message, level: LogLevel.debug);
  }

  void info(String message) {
    log(message, level: LogLevel.info);
  }

  void warning(String message, {Object? error}) {
    log(message, level: LogLevel.warning, error: error);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.error,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _reportError(String message, Object? error, StackTrace? stackTrace) {
    // TODO: Crashlytics veya benzeri bir hata raporlama servisine gönder
  }
} 