import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brokerController = TextEditingController(text: 'test.mosquitto.org');
  final _portController = TextEditingController(text: '8883'); // SSL için varsayılan port
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _mqttService = MqttService();
  final _storageService = StorageService();
  SmartPanelMqttState _connectionState = SmartPanelMqttState.disconnected;
  bool _isConnecting = false;
  bool _useSSL = true;

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

    // Ayarları kaydet
    await _storageService.saveSettings(
      host: _brokerController.text,
      port: int.parse(_portController.text),
      username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      useSSL: _useSSL,
    );

    // MQTT bağlantısını başlat
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
      appBar: AppBar(
        title: const Text('MQTT Ayarları'),
        actions: [
          Icon(
            _connectionState == SmartPanelMqttState.connected
                ? Icons.cloud_done
                : Icons.cloud_off,
            color: _connectionState == SmartPanelMqttState.connected
                ? Colors.green
                : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _brokerController,
                decoration: const InputDecoration(
                  labelText: 'Broker URL',
                  hintText: 'örn: test.mosquitto.org',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: 'örn: 8883',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Parola (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Güvenlik Ayarları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('SSL/TLS Kullan'),
                subtitle: const Text('Güvenli bağlantı için önerilir'),
                value: _useSSL,
                onChanged: (value) {
                  setState(() {
                    _useSSL = value;
                    if (value) {
                      _portController.text = '8883';
                    } else {
                      _portController.text = '1883';
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isConnecting ? null : _connect,
                child: _isConnecting
                    ? const CircularProgressIndicator()
                    : const Text('Bağlan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 