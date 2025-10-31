import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final _secureStorage = const FlutterSecureStorage();

  // Hash sensitive data
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Store sensitive data securely
  Future<void> storeSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to store secure data: $e');
    }
  }

  // Retrieve sensitive data
  Future<String?> retrieveSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw Exception('Failed to retrieve secure data: $e');
    }
  }

  // Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete secure data: $e');
    }
  }

  // Clear all secure data
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear secure data: $e');
    }
  }

  String sanitizeInput(String input) {
  return input
      .replaceAll(RegExp(r"[<>\""\/\\;:]"), '')
      .trim();
}


}