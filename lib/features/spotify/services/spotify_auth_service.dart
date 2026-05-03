import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:classipod/features/spotify/models/spotify_auth_credentials.dart';

const String _spotifyCredsKey = 'spotify_auth_credentials';

class SpotifyAuthService {
  final FlutterSecureStorage secureStorage;

  SpotifyAuthService({required this.secureStorage});

  /// Store credentials securely
  Future<void> saveCredentials(SpotifyAuthCredentials credentials) async {
    try {
      final jsonString = jsonEncode(credentials.toJson());
      await secureStorage.write(
        key: _spotifyCredsKey,
        value: jsonString,
      );
    } catch (e) {
      throw SpotifyAuthException('Failed to save credentials: $e');
    }
  }

  /// Retrieve stored credentials
  Future<SpotifyAuthCredentials?> getCredentials() async {
    try {
      final jsonString = await secureStorage.read(key: _spotifyCredsKey);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SpotifyAuthCredentials.fromJson(json);
    } catch (e) {
      throw SpotifyAuthException('Failed to retrieve credentials: $e');
    }
  }

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    try {
      await secureStorage.delete(key: _spotifyCredsKey);
    } catch (e) {
      throw SpotifyAuthException('Failed to clear credentials: $e');
    }
  }

  /// Check if credentials exist
  Future<bool> hasCredentials() async {
    try {
      final creds = await getCredentials();
      return creds != null && creds.isValid;
    } catch (e) {
      return false;
    }
  }
}

class SpotifyAuthException implements Exception {
  final String message;
  SpotifyAuthException(this.message);
  
  @override
  String toString() => message;
}
