import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:classipod/features/spotify/models/spotify_auth_credentials.dart';
import 'package:app_links/app_links.dart';

/// Spotify OAuth Configuration
/// IMPORTANT: Replace these with your actual Spotify App credentials
/// Get them from: https://developer.spotify.com/dashboard
const String _clientId = 'YOUR_SPOTIFY_CLIENT_ID';
const String _clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
const String _redirectUrl = 'com.adeeteya.classipod://auth/callback';

class SpotifyOAuthService {
  static const String _authorizationEndpoint = 'https://accounts.spotify.com/authorize';
  static const String _tokenEndpoint = 'https://accounts.spotify.com/api/token';

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _deepLinkSubscription;

  Completer<String>? _authCodeCompleter;

  /// Initialize deep link listener
  void initialize() {
    _setupDeepLinkListener();
  }

  void _setupDeepLinkListener() {
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        _authCodeCompleter?.completeError(err);
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'com.adeeteya.classipod' && uri.host == 'auth') {
      if (uri.path == '/callback') {
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        if (error != null) {
          _authCodeCompleter?.completeError(
            SpotifyOAuthException('Authorization failed: $error'),
          );
        } else if (code != null) {
          _authCodeCompleter?.complete(code);
        }
      }
    }
  }

  /// Start OAuth flow - returns authorization code
  Future<String> requestAuthorizationCode() async {
    _authCodeCompleter = Completer<String>();

    final scopes = [
      'user-read-private',
      'user-read-email',
      'user-library-read',
      'user-library-modify',
      'playlist-read-private',
      'playlist-read-collaborative',
      'playlist-modify-public',
      'playlist-modify-private',
      'user-top-read',
      'user-read-recently-played',
      'streaming',
      'user-read-playback-state',
      'user-modify-playback-state',
    ].join(' ');

    final authUri = Uri.parse(_authorizationEndpoint).replace(
      queryParameters: {
        'client_id': _clientId,
        'response_type': 'code',
        'redirect_uri': _redirectUrl,
        'scope': scopes,
        'show_dialog': 'true',
      },
    );

    // Open the authorization URL in browser
    if (await canLaunchUrl(authUri)) {
      await launchUrl(authUri, mode: LaunchMode.externalApplication);
    } else {
      throw SpotifyOAuthException('Could not launch authorization URL');
    }

    // Wait for the authorization code from deep link
    return await _authCodeCompleter!.future;
  }

  /// Exchange authorization code for access token
  Future<SpotifyAuthCredentials> requestAccessToken(String authorizationCode) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': authorizationCode,
          'redirect_uri': _redirectUrl,
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );

      if (response.statusCode != 200) {
        throw SpotifyOAuthException(
          'Failed to get access token: ${response.statusCode}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // Get user info
      final userProfile = await _getUserProfile(jsonResponse['access_token']);

      return SpotifyAuthCredentials(
        accessToken: jsonResponse['access_token'],
        refreshToken: jsonResponse['refresh_token'],
        expiresAt: DateTime.now().add(
          Duration(seconds: jsonResponse['expires_in'] ?? 3600),
        ),
        userId: userProfile['id'] ?? '',
        userEmail: userProfile['email'],
        userDisplayName: userProfile['display_name'],
      );
    } catch (e) {
      if (e is SpotifyOAuthException) rethrow;
      throw SpotifyOAuthException('Token request failed: $e');
    }
  }

  /// Refresh access token using refresh token
  Future<SpotifyAuthCredentials> refreshAccessToken(
    SpotifyAuthCredentials credentials,
  ) async {
    try {
      if (credentials.refreshToken == null) {
        throw SpotifyOAuthException('No refresh token available');
      }

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': credentials.refreshToken,
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );

      if (response.statusCode != 200) {
        throw SpotifyOAuthException('Failed to refresh token');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      return credentials.copyWith(
        accessToken: jsonResponse['access_token'],
        refreshToken: jsonResponse['refresh_token'] ?? credentials.refreshToken,
        expiresAt: DateTime.now().add(
          Duration(seconds: jsonResponse['expires_in'] ?? 3600),
        ),
      );
    } catch (e) {
      if (e is SpotifyOAuthException) rethrow;
      throw SpotifyOAuthException('Token refresh failed: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Cleanup
  void dispose() {
    _deepLinkSubscription?.cancel();
    _authCodeCompleter = null;
  }
}

class SpotifyOAuthException implements Exception {
  final String message;
  SpotifyOAuthException(this.message);

  @override
  String toString() => message;
}
