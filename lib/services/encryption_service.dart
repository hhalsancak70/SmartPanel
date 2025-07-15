import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' show Encrypter, IV, Key, AES, AESMode;

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  static const _keyStorageKey = 'encryption_key';
  static const _ivStorageKey = 'encryption_iv';
  final _secureStorage = const FlutterSecureStorage();

  late Encrypter _encrypter;
  late IV _iv;

  Future<void> initialize() async {
    // Şifreleme anahtarını al veya oluştur
    String? keyString = await _secureStorage.read(key: _keyStorageKey);
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = base64Encode(key.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: keyString);
    }

    // IV'yi al veya oluştur
    String? ivString = await _secureStorage.read(key: _ivStorageKey);
    if (ivString == null) {
      _iv = IV.fromSecureRandom(16);
      ivString = base64Encode(_iv.bytes);
      await _secureStorage.write(key: _ivStorageKey, value: ivString);
    } else {
      _iv = IV.fromBase64(ivString);
    }

    final key = Key.fromBase64(keyString);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }

  String encryptData(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  String decryptData(String encryptedData) {
    try {
      return _encrypter.decrypt64(encryptedData, iv: _iv);
    } catch (e) {
      print('Şifre çözme hatası: $e');
      return '';
    }
  }

  Future<void> resetEncryption() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    await initialize();
  }
} 