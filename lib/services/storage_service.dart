import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/panel_widget_model.dart';
import 'encryption_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _widgetsKey = 'panel_widgets';
  static const String _settingsKey = 'mqtt_settings';
  final _widgetsController = StreamController<List<PanelWidgetModel>>.broadcast();
  final _encryptionService = EncryptionService();
  SharedPreferences? _prefs;
  Timer? _autoSaveTimer;
  List<PanelWidgetModel> _cachedWidgets = [];
  bool _hasUnsavedChanges = false;

  Stream<List<PanelWidgetModel>> get widgetsStream => _widgetsController.stream;

  Future<void> initialize() async {
    await _encryptionService.initialize();
    _prefs = await SharedPreferences.getInstance();
    await loadWidgets();

    // Otomatik kaydetme zamanlayıcısı
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasUnsavedChanges) {
        _saveWidgets(_cachedWidgets);
        _hasUnsavedChanges = false;
      }
    });
  }

  Future<void> saveSettings({
    required String host,
    required int port,
    String? username,
    String? password,
    bool useSSL = true,
  }) async {
    final settings = {
      'host': host,
      'port': port,
      'username': username,
      'password': password != null ? _encryptionService.encryptData(password) : null,
      'useSSL': useSSL,
    };
    await _prefs?.setString(_settingsKey, jsonEncode(settings));
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    final settingsJson = _prefs?.getString(_settingsKey);
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      if (settings['password'] != null) {
        settings['password'] = _encryptionService.decryptData(settings['password'] as String);
      }
      return settings;
    }
    return null;
  }

  Future<List<PanelWidgetModel>> loadWidgets() async {
    final widgetsJson = _prefs?.getStringList(_widgetsKey) ?? [];
    
    _cachedWidgets = widgetsJson
        .map((json) => PanelWidgetModel.fromJson(jsonDecode(json)))
        .toList();
    
    _widgetsController.add(_cachedWidgets);
    return _cachedWidgets;
  }

  Future<void> saveWidget(PanelWidgetModel widget) async {
    _cachedWidgets.add(widget);
    _hasUnsavedChanges = true;
    _widgetsController.add(_cachedWidgets);

    // Eğer çok fazla widget varsa, hemen kaydet
    if (_cachedWidgets.length % 10 == 0) {
      await _saveWidgets(_cachedWidgets);
      _hasUnsavedChanges = false;
    }
  }

  Future<void> updateWidget(PanelWidgetModel widget) async {
    final index = _cachedWidgets.indexWhere((w) => w.id == widget.id);
    if (index != -1) {
      _cachedWidgets[index] = widget;
      _hasUnsavedChanges = true;
      _widgetsController.add(_cachedWidgets);

      // Eğer kritik bir güncelleme ise (örn. durum değişikliği), hemen kaydet
      if (widget.type == PanelWidgetType.slider || 
          widget.isActive != _cachedWidgets[index].isActive) {
        await _saveWidgets(_cachedWidgets);
        _hasUnsavedChanges = false;
      }
    }
  }

  Future<void> deleteWidget(String id) async {
    _cachedWidgets.removeWhere((w) => w.id == id);
    _hasUnsavedChanges = true;
    _widgetsController.add(_cachedWidgets);
    
    // Silme işlemlerini hemen kaydet
    await _saveWidgets(_cachedWidgets);
    _hasUnsavedChanges = false;
  }

  Future<void> _saveWidgets(List<PanelWidgetModel> widgets) async {
    final widgetsJson = widgets
        .map((widget) => jsonEncode(widget.toJson()))
        .toList();
    
    await _prefs?.setStringList(_widgetsKey, widgetsJson);
  }

  Future<void> dispose() async {
    // Kapatmadan önce kaydedilmemiş değişiklikleri kaydet
    if (_hasUnsavedChanges) {
      await _saveWidgets(_cachedWidgets);
    }
    
    _autoSaveTimer?.cancel();
    await _widgetsController.close();
    _cachedWidgets.clear();
    _prefs = null;
  }
} 