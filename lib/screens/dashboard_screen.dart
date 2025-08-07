import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/panel_widget_model.dart';
import '../services/storage_service.dart';
import '../services/mqtt_service.dart';

import '../widgets/panel_widget_card.dart';
import 'add_widget_screen.dart';
import 'panel_widget_details_screen.dart';

import 'dart:async';

// Renk ve stil sabitleri
const kPrimaryColor = Color(0xFF2B7CD3);
const kBackgroundColor = Color(0xFFFAFAFA);
const kCardBackgroundColor = Color(0xFFF9F9FC);
const kTextDarkColor = Color(0xFF333333);
const kTextMediumColor = Color(0xFF666666);
const kButtonLabelColor = Color(0xFFB0BEC5);
const kSuccessColor = Color(0xFF43A047);
const kErrorColor = Color(0xFFE53935);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<PanelWidgetModel> _items = [];
  final _storageService = StorageService();
  final _mqttService = MqttService();
  SmartPanelMqttState _connectionState = SmartPanelMqttState.disconnected;
  bool _isLoading = true;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _loadWidgets();

    _storageService.widgetsStream.listen((widgets) {
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(widgets);
        });
        _subscribeToTopics();
      }
    });

    // Bağlantı durumu dinleyicisini ayrı bir değişkende tutuyoruz
    _connectionSubscription = _mqttService.connectionState.listen((state) {
      print('MQTT Bağlantı durumu değişti: $state'); // Debug log
      if (mounted) {
        setState(() {
          _connectionState = state;
          print('Yeni bağlantı durumu: $_connectionState'); // Debug log
        });
        if (state == SmartPanelMqttState.disconnected) {
          _showReconnectDialog();
        } else if (state == SmartPanelMqttState.connected) {
          _subscribeToTopics();
        }
      }
    });

    _messageSubscription = _mqttService.messageStream.listen(_handleMqttMessage);

    // Mevcut bağlantı durumunu kontrol et
    if (_mqttService.isConnected) {
      setState(() => _connectionState = SmartPanelMqttState.connected);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWidgets() async {
    try {
      final widgets = await _storageService.loadWidgets();
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(widgets);
        });
      }
    } catch (e) {
      print('Widget yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget\'lar yüklenirken bir hata oluştu!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _subscribeToTopics() {
    if (!_mqttService.isConnected) return;

    for (var widget in _items) {
      if (widget.subscribeTopic != null) {
        _mqttService.subscribe(widget.subscribeTopic!);
      }
    }
  }

  void _handleMqttMessage(ReceivedMessage message) {
    if (!mounted) return;

    for (var widget in _items) {
      if (widget.subscribeTopic == message.topic) {
        setState(() {
          switch (widget.type) {
            case PanelWidgetType.button:
            case PanelWidgetType.switch_:
              widget.isActive = _parseOnOffMessage(message.message, widget);
              break;
            case PanelWidgetType.slider:
              final value = double.tryParse(message.message);
              if (value != null) {
                widget.currentValue = value;
                widget.isActive = value > (widget.minValue ?? 0);
              }
              break;
          }
        });
        _storageService.updateWidget(widget);
      }
    }
  }

  bool _parseOnOffMessage(String message, PanelWidgetModel widget) {
    final normalizedMessage = message.trim().toUpperCase();
    if (widget.onMessage != null && widget.offMessage != null) {
      return normalizedMessage == widget.onMessage!.toUpperCase();
    }
    return normalizedMessage == 'ON' || normalizedMessage == '1' || normalizedMessage == 'TRUE';
  }

  void _showReconnectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ReconnectDialog(),
    );
  }

  Future<void> _addNewWidget() async {
    final result = await Navigator.push<PanelWidgetModel>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddWidgetScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    if (result != null) {
      await _storageService.saveWidget(result);
    }
  }

  Future<void> _deleteWidget(String id) async {
    await _storageService.deleteWidget(id);
  }

  Future<void> _toggleWidget(PanelWidgetModel widget, bool value) async {
    if (!_mqttService.isConnected) {
      _showMqttError('MQTT bağlantısı yok! Lütfen ayarları kontrol edin.');
      return;
    }

    String message;
    switch (widget.type) {
      case PanelWidgetType.button:
      case PanelWidgetType.switch_:
        message = value ? 'ON' : 'OFF';
        break;
      case PanelWidgetType.slider:
        message = widget.currentValue?.toString() ?? '0';
        break;
    }

    final success = _mqttService.publishMessage(widget.topic, message);

    if (success) {
      widget.isActive = value;
      await _storageService.updateWidget(widget);
    } else {
      _showMqttError('Mesaj gönderilemedi! Lütfen bağlantıyı kontrol edin.');
    }
  }

  Future<void> _updateSliderValue(PanelWidgetModel widget, double value) async {
    if (!_mqttService.isConnected) {
      _showMqttError('MQTT bağlantısı yok! Lütfen ayarları kontrol edin.');
      return;
    }

    final success = _mqttService.publishMessage(widget.topic, value.toString());

    if (success) {
      widget.currentValue = value;
      widget.isActive = value > widget.minValue!;
      await _storageService.updateWidget(widget);
    } else {
      _showMqttError('Mesaj gönderilemedi! Lütfen bağlantıyı kontrol edin.');
    }
  }

  void _showMqttError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showWidgetDetails(PanelWidgetModel widget) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PanelWidgetDetailsScreen(widget: widget),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: FloatingActionButton(
          onPressed: _addNewWidget,
          backgroundColor: const Color(0xFFEEF1FF),
          foregroundColor: kPrimaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Smart Panel',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        _ConnectionStatusIcon(connectionState: _connectionState),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/settings'),
        ),
        IconButton(
          icon: const Icon(Icons.build, color: Colors.white),
          onPressed: () {
            // Yapılandırma işlemleri
          },
        ),
        const SizedBox(width: 8),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize,
              size: 64,
              color: kPrimaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz panel bileşeni eklenmedi',
              style: TextStyle(
                fontSize: 16,
                color: kTextMediumColor,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addNewWidget,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Bileşen Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 900 ? 3 : 4;

    return Container(
      color: kBackgroundColor,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kToolbarHeight + 32),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: width < 600 ? 0.75 : 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final widget = _items[index];
          return AnimatedOpacity(
            duration: Duration(milliseconds: 300 + (index * 100)),
            opacity: 1.0,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0.0,
                0.0,
                0.0,
              )..translate(
                  0.0,
                  20.0 * (1.0 - 1.0),
                  0.0,
                ),
              child: PanelWidgetCard(
                key: ValueKey(widget.id),
                widget: widget,
                onTap: () => _showWidgetDetails(widget),
                onLongPress: () => _showDeleteDialog(context, widget),
                onToggle: (value) => _toggleWidget(widget, value),
                onSliderChanged: widget.type == PanelWidgetType.slider
                    ? (value) {
                        setState(() {
                          widget.currentValue = value;
                        });
                      }
                    : null,
                onSliderChangeEnd: widget.type == PanelWidgetType.slider
                    ? (value) => _updateSliderValue(widget, value)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PanelWidgetModel widget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bileşeni Sil'),
        content: Text(
          '${widget.title} bileşenini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWidget(widget.id);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionStatusIcon extends StatelessWidget {
  final SmartPanelMqttState connectionState;

  const _ConnectionStatusIcon({
    required this.connectionState,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (connectionState) {
      case SmartPanelMqttState.connected:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case SmartPanelMqttState.connecting:
        icon = Icons.cloud_upload;
        color = Colors.orange;
        break;
      case SmartPanelMqttState.disconnecting:
        icon = Icons.cloud_download;
        color = Colors.orange;
        break;
      case SmartPanelMqttState.error:
        icon = Icons.cloud_off;
        color = Colors.red;
        break;
      case SmartPanelMqttState.disconnected:
        icon = Icons.cloud_off;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color);
  }
}



class _ReconnectDialog extends StatelessWidget {
  const _ReconnectDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bağlantı Kesildi'),
      content: const Text(
        'MQTT bağlantısı kesildi. Ayarlar sayfasına dönüp yeniden bağlanmak ister misiniz?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/settings');
          },
          child: const Text('Evet'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hayır'),
        ),
      ],
    );
  }
} 