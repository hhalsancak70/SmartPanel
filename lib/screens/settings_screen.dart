import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../services/storage_service.dart';

// MQTT Ayarları için sabit renkler ve stiller
class MqttStyles {
  static const Color primaryBlue = Color(0xFF2B7CD3);
  static const Color darkGrey = Color(0xFF333333);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFF999999);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
  static const Color dividerGrey = Color(0xFFE0E0E0);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  static const double borderRadius = 8.0;
  static const double maxWidth = 600.0;

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: dividerGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorRed),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brokerController = TextEditingController(text: 'test.mosquitto.org');
  final _portController = TextEditingController(text: '8883');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _mqttService = MqttService();
  final _storageService = StorageService();
  SmartPanelMqttState _connectionState = SmartPanelMqttState.disconnected;
  bool _isConnecting = false;
  bool _useSSL = true;
  bool _obscurePassword = true;
  bool _allowSelfSigned = false;

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MqttStyles.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: MqttStyles.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: MqttStyles.darkGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _mqttService.connectionState.listen((state) {
      if (mounted) {
        setState(() => _connectionState = state);
      }
    });
  }

  Future<void> _loadSettings() async {
    await _storageService.initialize();
    final settings = await _storageService.loadSettings();
    if (settings != null && mounted) {
      setState(() {
        _brokerController.text = settings['host'] as String;
        _portController.text = (settings['port'] as int).toString();
        if (settings['username'] != null) {
          _usernameController.text = settings['username'] as String;
        }
        if (settings['password'] != null) {
          _passwordController.text = settings['password'] as String;
        }
        _useSSL = settings['useSSL'] as bool? ?? true;
      });
    }
  }

  @override
  void dispose() {
    _brokerController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnecting = true);

    await _storageService.saveSettings(
      host: _brokerController.text,
      port: int.parse(_portController.text),
      username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      useSSL: _useSSL,
    );

    await _mqttService.initialize(
      host: _brokerController.text,
      port: int.parse(_portController.text),
      username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      useSSL: _useSSL,
    );

    final success = await _mqttService.connect();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bağlantı hatası! Lütfen ayarlarınızı kontrol edin.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MqttStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Row(
          children: [
            Icon(Icons.waves, color: MqttStyles.primaryBlue),
            SizedBox(width: 8),
            Text(
              'MQTT Ayarları',
              style: TextStyle(
                color: MqttStyles.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _connectionState == SmartPanelMqttState.connected
                    ? MqttStyles.successGreen.withOpacity(0.1)
                    : MqttStyles.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MqttStyles.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _connectionState == SmartPanelMqttState.connected
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    key: ValueKey(_connectionState),
                    color: _connectionState == SmartPanelMqttState.connected
                        ? MqttStyles.successGreen
                        : MqttStyles.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _connectionState == SmartPanelMqttState.connected
                        ? 'Bağlı'
                        : 'Bağlı Değil',
                    style: TextStyle(
                      color: _connectionState == SmartPanelMqttState.connected
                          ? MqttStyles.successGreen
                          : MqttStyles.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: MqttStyles.maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    title: 'Broker Bilgileri',
                    icon: Icons.dns_outlined,
                    children: [
                      TextFormField(
                        controller: _brokerController,
                        decoration: MqttStyles.inputDecoration(
                          labelText: 'Broker URL',
                          hintText: 'mqtt://broker.example.com',
                          prefixIcon: const Icon(Icons.dns_outlined, color: MqttStyles.primaryBlue),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen broker URL giriniz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _portController,
                        decoration: MqttStyles.inputDecoration(
                          labelText: 'Port',
                          hintText: '1883',
                          prefixIcon: const Icon(Icons.numbers, color: MqttStyles.primaryBlue),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen port numarası giriniz';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port <= 0 || port > 65535) {
                            return 'Geçerli bir port numarası giriniz (1-65535)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Varsayılan: 1883 (güvenli olmayan), 8883 (SSL)',
                        style: TextStyle(
                          color: MqttStyles.lightGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Kimlik Doğrulama',
                    icon: Icons.security,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: MqttStyles.inputDecoration(
                          labelText: 'Kullanıcı Adı (Opsiyonel)',
                          prefixIcon: const Icon(Icons.person_outline, color: MqttStyles.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: MqttStyles.inputDecoration(
                          labelText: 'Parola (Opsiyonel)',
                          prefixIcon: const Icon(Icons.lock_outline, color: MqttStyles.primaryBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: MqttStyles.mediumGrey,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Güvenlik',
                    icon: Icons.shield,
                    children: [
                      SwitchListTile(
                        title: const Text('SSL/TLS Kullan'),
                        subtitle: const Text('Güvenli bağlantı için önerilir'),
                        secondary: Icon(
                          _useSSL ? Icons.security : Icons.security_outlined,
                          color: _useSSL ? MqttStyles.primaryBlue : MqttStyles.mediumGrey,
                        ),
                        value: _useSSL,
                        activeColor: MqttStyles.primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            _useSSL = value;
                            _portController.text = value ? '8883' : '1883';
                          });
                        },
                      ),
                      if (_useSSL) ...[
                        const Divider(),
                        CheckboxListTile(
                          title: const Text('Kendinden imzalı sertifikalara izin ver'),
                          value: _allowSelfSigned,
                          activeColor: MqttStyles.primaryBlue,
                          onChanged: (value) {
                            setState(() => _allowSelfSigned = value ?? false);
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isConnecting ? null : _connect,
                    style: MqttStyles.elevatedButtonStyle(),
                    child: _isConnecting
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Bağlanıyor...'),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_connectionState == SmartPanelMqttState.connected
                            ? Icons.link_off
                            : Icons.link),
                        const SizedBox(width: 8),
                        Text(
                          _connectionState == SmartPanelMqttState.connected
                              ? 'Yeniden Bağlan'
                              : 'Bağlan',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
