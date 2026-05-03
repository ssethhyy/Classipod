import 'package:classipod/core/models/music_metadata.dart';
import 'package:classipod/features/settings/controller/settings_preferences_controller.dart';
import 'package:classipod/features/spotify/models/spotify_track_model.dart';
import 'package:classipod/features/spotify/providers/spotify_data_providers.dart';
import 'package:classipod/core/providers/filtered_audio_files_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unified music library provider that returns either local or Spotify music
/// based on the useSpotifyMedia setting
final unifiedMusicLibraryProvider = FutureProvider<List<dynamic>>((ref) async {
  final settings = ref.watch(settingsPreferencesControllerProvider);
  
  if (settings.useSpotifyMedia) {
    // Return Spotify tracks
    return await ref.watch(spotifyAllSavedTracksProvider.future);
  } else {
    // Return local music files
    final audioFiles = await ref.watch(filteredAudioFilesProvider.future);
    return audioFiles ?? [];
  }
});

/// Unified playlists provider
final unifiedPlaylistsProvider = FutureProvider<List<dynamic>>((ref) async {
  final settings = ref.watch(settingsPreferencesControllerProvider);
  
  if (settings.useSpotifyMedia) {
    return await ref.watch(spotifyPlaylistsProvider.future);
  } else {
    // Local playlists would go here
    // For now return empty as local playlists are handled differently
    return [];
  }
});

/// Unified search provider
final unifiedSearchProvider = FutureProvider.family<List<dynamic>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    
    final settings = ref.watch(settingsPreferencesControllerProvider);
    
    if (settings.useSpotifyMedia) {
      final results = await ref.watch(spotifySearchProvider(query).future);
      // Flatten search results into a single list
      return [
        ...?results['tracks'] as List<SpotifyTrack>?,
        ...?results['albums'] as List<dynamic>?,
        ...?results['playlists'] as List<dynamic>?,
      ];
    } else {
      // Local search would go here
      return [];
    }
  },
);

/// Check if currently using Spotify media
final isSpotifyMediaEnabledProvider = Provider((ref) {
  final settings = ref.watch(settingsPreferencesControllerProvider);
  return settings.useSpotifyMedia;
});

/// Check if Spotify is authenticated
final isSpotifyAuthenticatedProvider = Provider((ref) {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  return credentialsAsync.maybeWhen(
    data: (credentials) => credentials != null && credentials.isValid,
    orElse: () => false,
  );
});

/// Get current media source label
final mediaSourceLabelProvider = Provider((ref) {
  final isSpotify = ref.watch(isSpotifyMediaEnabledProvider);
  return isSpotify ? 'Spotify' : 'Local';
});
