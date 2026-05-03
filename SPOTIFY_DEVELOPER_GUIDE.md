# Spotify Integration - Developer Guide

This guide explains how to further extend the Spotify integration with playback control and advanced features.

## Architecture Overview

### Authentication Flow
1. User taps "Login with Spotify" in settings
2. App launches web browser to Spotify OAuth endpoint
3. User authorizes the app
4. Browser redirects to `com.adeeteya.classipod://auth/callback` with authorization code
5. Deep link handler captures code and exchanges it for access token
6. Credentials securely stored using `flutter_secure_storage`

### Data Fetching
- Uses Riverpod FutureProviders for async data management
- Providers automatically refresh when dependencies change
- Paginated fetching for large libraries
- Search supports all Spotify content types

### Playback Control
Currently implemented through `SpotifyApiService` methods:
- `startPlayback()` - Start playing on a device
- `pausePlayback()` - Pause playback
- `nextTrack()` / `previousTrack()` - Navigation
- `seek()` - Seek to position
- `setVolume()` - Control volume
- `addToLibrary()` / `removeFromLibrary()` - Library management

## How to Enable Spotify Playback

### Step 1: Create a Unified Playback Manager

Create `lib/features/spotify/services/spotify_playback_manager.dart`:

```dart
import 'package:classipod/features/spotify/models/spotify_track_model.dart';
import 'package:classipod/features/spotify/providers/spotify_data_providers.dart';
import 'package:classipod/features/spotify/providers/spotify_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpotifyPlaybackManager {
  final Ref ref;
  
  SpotifyPlaybackManager(this.ref);

  Future<void> playTrack(SpotifyTrack track) async {
    try {
      // Get available Spotify devices
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      final devices = await apiService.getAvailableDevices();
      
      if (devices.isEmpty) {
        throw Exception('No Spotify device available');
      }
      
      // Play on the first available device
      final deviceId = devices.first['id'] as String?;
      await apiService.startPlayback(
        deviceId: deviceId,
        uris: ['spotify:track:${track.id}'],
      );
    } catch (e) {
      print('Error playing track: $e');
    }
  }

  Future<void> playPlaylist(String playlistId) async {
    try {
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      final devices = await apiService.getAvailableDevices();
      
      if (devices.isEmpty) {
        throw Exception('No Spotify device available');
      }
      
      final deviceId = devices.first['id'] as String?;
      await apiService.startPlayback(
        deviceId: deviceId,
        contextUri: 'spotify:playlist:$playlistId',
      );
    } catch (e) {
      print('Error playing playlist: $e');
    }
  }

  Future<void> pause() async {
    try {
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      await apiService.pausePlayback();
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  Future<void> resume() async {
    try {
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      await apiService.startPlayback();
    } catch (e) {
      print('Error resuming: $e');
    }
  }

  Future<void> next() async {
    try {
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      await apiService.nextTrack();
    } catch (e) {
      print('Error skipping: $e');
    }
  }

  Future<void> previous() async {
    try {
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      await apiService.previousTrack();
    } catch (e) {
      print('Error going to previous: $e');
    }
  }

  Future<void> seek(int positionMs) async {
    try {
      final credentials = ref.read(spotifyAuthCredentialsProvider).maybeWhen(
        data: (creds) => creds,
        orElse: () => null,
      );
      
      if (credentials == null) return;
      
      final apiService = SpotifyApiService(credentials);
      await apiService.seek(positionMs);
    } catch (e) {
      print('Error seeking: $e');
    }
  }
}

final spotifyPlaybackManagerProvider = Provider((ref) {
  return SpotifyPlaybackManager(ref);
});
```

### Step 2: Integrate with Spotify Screens

In `spotify_songs_screen.dart`, update the tap handler:

```dart
void _handleSongTap(SpotifyTrack song) async {
  final playbackManager = ref.read(spotifyPlaybackManagerProvider);
  await playbackManager.playTrack(song);
  
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Now Playing: ${song.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

### Step 3: Create Media Source Toggle

Create a widget in the main menu to toggle between local and Spotify:

```dart
class MediaSourceToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpotify = ref.watch(isSpotifyMediaEnabledProvider);
    final isAuthenticated = ref.watch(isSpotifyAuthenticatedProvider);
    
    return CupertinoSegmentedControl<bool>(
      children: {
        false: Text(isSpotify ? 'Local' : 'Local'),
        true: Text(isSpotify ? 'Spotify' : 'Spotify'),
      },
      groupValue: isSpotify,
      onValueChanged: (value) async {
        if (value && !isAuthenticated) {
          // Show error or redirect to settings
          return;
        }
        
        await ref.read(settingsPreferencesControllerProvider.notifier)
            .toggleUseSpotifyMedia();
      },
    );
  }
}
```

## Advanced Features to Implement

### 1. Queue Management
```dart
// Fetch user's queue
Future<List<SpotifyTrack>> getUserQueue() async {
  // Use SpotifyApiService to get current queue
}
```

### 2. Device Selection
```dart
// Allow user to select which device to play on
Future<void> selectDevice(String deviceId) async {
  // Start playback on specific device
}
```

### 3. Playlist Editing
```dart
// Add/remove tracks from playlists
Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
  // Use Spotify API
}
```

### 4. Offline Sync
```dart
// For downloaded Spotify songs, show them when offline
Future<List<SpotifyTrack>> getOfflineSpotifySongs() async {
  // Query device storage for Spotify offline files
}
```

### 5. Real-time Playback Updates
```dart
// Periodically fetch current playback state
final spotifyPlaybackStateProvider = StreamProvider((ref) {
  return Stream.periodic(Duration(seconds: 5), (_) {
    return ref.read(spotifyCurrentPlaybackProvider);
  });
});
```

## Troubleshooting Playback Issues

### No Device Available
- Ensure you have Spotify app open on a device
- The device must be on the same network as ClassiPod
- Go to Spotify settings and check active devices

### Playback Not Starting
- Verify account is authenticated
- Check device ID is valid
- Ensure URI format is correct: `spotify:track:<id>`

### Seek/Skip Not Working
- Token might be expired - app will auto-refresh
- Device must support seeking
- Some playlist types don't allow seeking

## Testing

To test Spotify playback:

1. Authenticate in Settings > Spotify
2. Open Spotify app on another device
3. Return to ClassiPod and browse Spotify songs
4. Tap a song to play
5. Verify playback starts on your Spotify device

## Performance Considerations

- Cache search results for 5 minutes
- Limit API calls per second (Spotify rate limiting)
- Use pagination for large lists
- Refresh tokens before they expire
- Clean up subscriptions when screens close

## Security

- Never log access tokens
- Use HTTPS for all API calls (enforced by Spotify)
- Validate webhook signatures if using events
- Refresh tokens securely
- Handle errors gracefully without exposing details

## References

- [Spotify Web API Reference](https://developer.spotify.com/documentation/web-api/reference)
- [Flutter Riverpod Docs](https://riverpod.dev)
- [Just Audio Package](https://pub.dev/packages/just_audio)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

For questions or issues, check the Spotify API status page or review the app logs in Android Studio/Xcode.
