import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/theme_service.dart';
import 'services/service_locator.dart';
import 'services/error_handler.dart';
import 'services/logger_service.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Servisleri başlat
    await ServiceLocator.initialize();

    // Uygulama kapanırken servisleri temizle
    WidgetsBinding.instance.addObserver(
      _AppLifecycleObserver(
        onDetached: ServiceLocator.dispose,
      ),
    );

    final themeService = getIt<ThemeService>();
    final errorHandler = getIt<ErrorHandler>();
    final logger = getIt<LoggerService>();

    // Flutter hata yakalayıcıyı ayarla
    FlutterError.onError = errorHandler.handleFlutterError;

    logger.info('Uygulama başlatılıyor...');

    runApp(MyApp(themeService: themeService));
  }, (error, stack) {
    // Zone seviyesinde hata yakalama
    final errorHandler = getIt<ErrorHandler>();
    final logger = getIt<LoggerService>();

    logger.error(
      'Kritik uygulama hatası',
      error: error,
      stackTrace: stack,
    );

    // Kullanıcıya genel bir hata mesajı göster
    errorHandler.handleZoneError(error, stack);
  });
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) => MaterialApp(
          title: 'Smart Panel',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return _buildPageRoute(
                  const SettingsScreen(),
                  settings,
                );
              case '/dashboard':
                return _buildPageRoute(
                  const DashboardScreen(),
                  settings,
                );
              case '/settings':
                return _buildPageRoute(
                  const SettingsScreen(),
                  settings,
                );
              default:
                return null;
            }
          },
        ),
      ),
    );
  }

  PageRouteBuilder<dynamic> _buildPageRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onDetached;

  _AppLifecycleObserver({required this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onDetached();
    }
  }
}
