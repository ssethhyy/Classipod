import 'package:classipod/features/spotify/models/spotify_auth_credentials.dart';
import 'package:classipod/features/spotify/services/spotify_auth_service.dart';
import 'package:classipod/features/spotify/services/spotify_oauth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Secure storage provider
final secureStorageProvider = Provider((ref) {
  return const FlutterSecureStorage();
});

// Auth service provider
final spotifyAuthServiceProvider = Provider((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SpotifyAuthService(secureStorage: secureStorage);
});

// OAuth service provider
final spotifyOAuthServiceProvider = Provider((ref) {
  return SpotifyOAuthService();
});

// Current auth credentials provider
final spotifyAuthCredentialsProvider = StateNotifierProvider<
    SpotifyAuthCredentialsNotifier,
    AsyncValue<SpotifyAuthCredentials?>>(
  (ref) => SpotifyAuthCredentialsNotifier(ref),
);

class SpotifyAuthCredentialsNotifier
    extends StateNotifier<AsyncValue<SpotifyAuthCredentials?>> {
  final Ref ref;

  SpotifyAuthCredentialsNotifier(this.ref)
      : super(const AsyncValue.loading()) {
    _initializeCredentials();
  }

  Future<void> _initializeCredentials() async {
    try {
      state = const AsyncValue.loading();
      final authService = ref.read(spotifyAuthServiceProvider);
      final credentials = await authService.getCredentials();
      state = AsyncValue.data(credentials);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> authenticate() async {
    try {
      state = const AsyncValue.loading();
      
      final oauthService = ref.read(spotifyOAuthServiceProvider);
      final authService = ref.read(spotifyAuthServiceProvider);

      // Get authorization code
      final authCode = await oauthService.requestAuthorizationCode();

      // Exchange for access token
      final credentials = await oauthService.requestAccessToken(authCode);

      // Store credentials
      await authService.saveCredentials(credentials);

      state = AsyncValue.data(credentials);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      final authService = ref.read(spotifyAuthServiceProvider);
      await authService.clearCredentials();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshTokenIfNeeded() async {
    try {
      final currentState = state;
      if (currentState is AsyncData && currentState.value != null) {
        final credentials = currentState.value!;
        
        if (credentials.isExpired) {
          final oauthService = ref.read(spotifyOAuthServiceProvider);
          final authService = ref.read(spotifyAuthServiceProvider);

          final refreshedCredentials =
              await oauthService.refreshAccessToken(credentials);
          await authService.saveCredentials(refreshedCredentials);

          state = AsyncValue.data(refreshedCredentials);
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
