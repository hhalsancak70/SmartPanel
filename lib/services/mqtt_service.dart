import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Kendi bağlantı durumu enum'ımızı SmartPanel prefix'i ile tanımlayalım
enum SmartPanelMqttState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error
}

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;
  final _connectionStateController = StreamController<SmartPanelMqttState>.broadcast();
  final _messageController = StreamController<ReceivedMessage>.broadcast();

  Stream<SmartPanelMqttState> get connectionState => _connectionStateController.stream;
  Stream<ReceivedMessage> get messageStream => _messageController.stream;
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> initialize({
    required String host,
    required int port,
    String? username,
    String? password,
    bool useSSL = false,
    String? certificatePath,
  }) async {
    _client?.disconnect();
    
    final clientId = 'smart_panel_${DateTime.now().millisecondsSinceEpoch}';
    print('MQTT Bağlantısı başlatılıyor - Host: $host, Port: $port, ClientId: $clientId');
    
    _client = MqttServerClient.withPort(host, clientId, port);
    
    _client!
      ..keepAlivePeriod = 20
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..onUnsubscribed = _onUnsubscribed
      ..secure = useSSL
      ..logging(on: true);

    // SSL yapılandırması
    if (useSSL) {
      _client!.securityContext = SecurityContext.defaultContext;
      if (certificatePath != null) {
        _client!.securityContext.setTrustedCertificates(certificatePath);
      }
    }

    final connMessage = MqttConnectMessage()
      ..withClientIdentifier(clientId)
      ..withWillTopic('smart_panel/status')
      ..withWillMessage('offline')
      ..withWillQos(MqttQos.atLeastOnce)
      ..withWillRetain()
      ..startClean()
      ..keepAliveFor(20);

    _client!.connectionMessage = connMessage;

    if (username != null && password != null) {
      print('Kimlik bilgileri ekleniyor: $username');
      _client!.connectionMessage!.authenticateAs(username, password);
    }

    // Mesaj alıcıyı ayarla
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      _handleMessage(messages);
    });

    print('MQTT Client yapılandırması:');
    print('- Broker: $host:$port');
    print('- Client ID: $clientId');
    print('- Keep Alive: ${_client!.keepAlivePeriod} saniye');
    print('- Clean Session: ${_client!.connectionMessage!.startClean}');
    print('- SSL: ${_client!.secure}');
  }

  Future<bool> connect() async {
    if (_client == null) {
      print('MQTT Client başlatılmamış');
      return false;
    }
    
    _connectionStateController.add(SmartPanelMqttState.connecting);
    print('MQTT Bağlantısı başlatılıyor...');

    try {
      await _client!.connect();
      // Bağlantı başarılı olduysa connected durumuna geç
      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        _onConnected();
      }
      return true;
    } on NoConnectionException catch (e) {
      print('MQTT Bağlantı hatası (NoConnection): $e');
      _logConnectionError();
      _connectionStateController.add(SmartPanelMqttState.error);
      return false;
    } on SocketException catch (e) {
      print('MQTT Bağlantı hatası (Socket): $e');
      _logSocketError(e);
      _connectionStateController.add(SmartPanelMqttState.error);
      return false;
    } catch (e) {
      print('MQTT Bağlantı hatası (Diğer): $e');
      _logConnectionError();
      _connectionStateController.add(SmartPanelMqttState.error);
      return false;
    }
  }

  void _logConnectionError() {
    if (_client?.connectionStatus != null) {
      print('Bağlantı durumu: ${_client?.connectionStatus?.state}');
      print('Dönüş kodu: ${_client?.connectionStatus?.returnCode}');
    }
  }

  void _logSocketError(SocketException e) {
    print('Socket detayları:');
    print('- Adres: ${e.address}');
    print('- Port: ${e.port}');
    print('- OS Hatası: ${e.osError}');
  }

  bool publishMessage(String topic, String message, {bool retain = false}) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT Broker\'a bağlı değil - mesaj gönderilemedi');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      print('MQTT Mesaj gönderiliyor - Topic: $topic, Mesaj: $message');
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: retain);
      print('MQTT Mesaj başarıyla gönderildi');
      return true;
    } catch (e) {
      print('MQTT Mesaj gönderme hatası: $e');
      return false;
    }
  }

  Future<bool> subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT Broker\'a bağlı değil - abone olunamadı');
      return false;
    }

    try {
      print('MQTT Topic\'e abone olunuyor: $topic');
      _client!.subscribe(topic, qos);
      return true;
    } catch (e) {
      print('MQTT Abone olma hatası: $e');
      return false;
    }
  }

  Future<bool> unsubscribe(String topic) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT Broker\'a bağlı değil - abonelik kaldırılamadı');
      return false;
    }

    try {
      print('MQTT Topic aboneliği kaldırılıyor: $topic');
      _client!.unsubscribe(topic);
      return true;
    } catch (e) {
      print('MQTT Abonelik kaldırma hatası: $e');
      return false;
    }
  }

  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (var message in messages) {
      final recMess = message.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      _messageController.add(ReceivedMessage(
        topic: message.topic,
        message: payload,
      ));
      
      print('MQTT Mesaj alındı - Topic: ${message.topic}, Mesaj: $payload');
    }
  }

  void _onConnected() {
    print('MQTT Broker bağlantısı başarılı');
    _connectionStateController.add(SmartPanelMqttState.connected);
    publishMessage('smart_panel/status', 'online', retain: true);
  }

  void _onDisconnected() {
    print('MQTT Broker bağlantısı kesildi');
    _connectionStateController.add(SmartPanelMqttState.disconnected);
  }

  void _onSubscribed(String topic) {
    print('MQTT Topic abone olundu: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('MQTT Topic abonelik hatası: $topic');
  }

  void _onUnsubscribed(String? topic) {
    print('MQTT Topic aboneliği kaldırıldı: $topic');
  }

  Future<void> disconnect() async {
    try {
      _connectionStateController.add(SmartPanelMqttState.disconnecting);
      print('MQTT Bağlantısı kapatılıyor...');
      await publishMessage('smart_panel/status', 'offline', retain: true);
      _client?.disconnect();
      print('MQTT Bağlantısı başarıyla kapatıldı');
    } catch (e) {
      print('MQTT Bağlantısı kapatılırken hata: $e');
    } finally {
      _connectionStateController.add(SmartPanelMqttState.disconnected);
    }
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _messageController.close();
  }
}

class ReceivedMessage {
  final String topic;
  final String message;

  ReceivedMessage({required this.topic, required this.message});
} 