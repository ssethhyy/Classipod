import 'package:classipod/features/spotify/models/spotify_album_model.dart';
import 'package:classipod/features/spotify/models/spotify_artist_model.dart';
import 'package:classipod/features/spotify/models/spotify_playlist_model.dart';
import 'package:classipod/features/spotify/models/spotify_track_model.dart';
import 'package:classipod/features/spotify/providers/spotify_auth_provider.dart';
import 'package:classipod/features/spotify/services/spotify_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Spotify API service provider
final spotifyApiServiceProvider = Provider((ref) {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.whenData((credentials) {
    if (credentials == null) return null;
    return SpotifyApiService(credentials);
  }).mapToFuture();
});

// Get all saved tracks
final spotifyAllSavedTracksProvider =
    FutureProvider<List<SpotifyTrack>>((ref) async {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.when(
    data: (credentials) async {
      if (credentials == null) return [];
      
      ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
      
      final apiService = SpotifyApiService(credentials);
      final allTracks = <SpotifyTrack>[];
      int offset = 0;
      const int limit = 50;
      bool hasMore = true;

      while (hasMore) {
        final tracks = await apiService.getSavedTracks(limit: limit, offset: offset);
        if (tracks.isEmpty) {
          hasMore = false;
        } else {
          allTracks.addAll(tracks);
          offset += limit;
        }
      }

      return allTracks;
    },
    loading: () async => [],
    error: (e, st) async => throw e,
  );
});

// Get paginated saved tracks
final spotifyPaginatedTracksProvider = FutureProvider.family<List<SpotifyTrack>, int>(
  (ref, page) async {
    final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
    
    return credentialsAsync.when(
      data: (credentials) async {
        if (credentials == null) return [];
        
        ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
        
        final apiService = SpotifyApiService(credentials);
        const int limit = 50;
        final offset = page * limit;

        return await apiService.getSavedTracks(limit: limit, offset: offset);
      },
      loading: () async => [],
      error: (e, st) async => throw e,
    );
  },
);

// Get user playlists
final spotifyPlaylistsProvider = FutureProvider<List<SpotifyPlaylist>>((ref) async {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.when(
    data: (credentials) async {
      if (credentials == null) return [];
      
      ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
      
      final apiService = SpotifyApiService(credentials);
      final allPlaylists = <SpotifyPlaylist>[];
      int offset = 0;
      const int limit = 50;
      bool hasMore = true;

      while (hasMore) {
        final playlists = await apiService.getUserPlaylists(limit: limit, offset: offset);
        if (playlists.isEmpty) {
          hasMore = false;
        } else {
          allPlaylists.addAll(playlists);
          offset += limit;
        }
      }

      return allPlaylists;
    },
    loading: () async => [],
    error: (e, st) async => throw e,
  );
});

// Get playlist tracks
final spotifyPlaylistTracksProvider = FutureProvider.family<List<SpotifyTrack>, String>(
  (ref, playlistId) async {
    final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
    
    return credentialsAsync.when(
      data: (credentials) async {
        if (credentials == null) return [];
        
        ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
        
        final apiService = SpotifyApiService(credentials);
        final allTracks = <SpotifyTrack>[];
        int offset = 0;
        const int limit = 50;
        bool hasMore = true;

        while (hasMore) {
          final tracks = await apiService.getPlaylistTracks(
            playlistId,
            limit: limit,
            offset: offset,
          );
          if (tracks.isEmpty) {
            hasMore = false;
          } else {
            allTracks.addAll(tracks);
            offset += limit;
          }
        }

        return allTracks;
      },
      loading: () async => [],
      error: (e, st) async => throw e,
    );
  },
);

// Get saved albums
final spotifyAlbumsProvider = FutureProvider<List<SpotifyAlbum>>((ref) async {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.when(
    data: (credentials) async {
      if (credentials == null) return [];
      
      ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
      
      final apiService = SpotifyApiService(credentials);
      final allAlbums = <SpotifyAlbum>[];
      int offset = 0;
      const int limit = 50;
      bool hasMore = true;

      while (hasMore) {
        final albums = await apiService.getSavedAlbums(limit: limit, offset: offset);
        if (albums.isEmpty) {
          hasMore = false;
        } else {
          allAlbums.addAll(albums);
          offset += limit;
        }
      }

      return allAlbums;
    },
    loading: () async => [],
    error: (e, st) async => throw e,
  );
});

// Get album tracks
final spotifyAlbumTracksProvider = FutureProvider.family<List<SpotifyTrack>, String>(
  (ref, albumId) async {
    final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
    
    return credentialsAsync.when(
      data: (credentials) async {
        if (credentials == null) return [];
        
        ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
        
        final apiService = SpotifyApiService(credentials);
        return await apiService.getAlbumTracks(albumId);
      },
      loading: () async => [],
      error: (e, st) async => throw e,
    );
  },
);

// Search provider
final spotifySearchProvider = FutureProvider.family<
    Map<String, dynamic>,
    String>((ref, query) async {
  if (query.isEmpty) return {'tracks': [], 'albums': [], 'playlists': [], 'artists': []};

  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.when(
    data: (credentials) async {
      if (credentials == null) {
        return {'tracks': [], 'albums': [], 'playlists': [], 'artists': []};
      }
      
      ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
      
      final apiService = SpotifyApiService(credentials);
      return await apiService.search(query);
    },
    loading: () async => {'tracks': [], 'albums': [], 'playlists': [], 'artists': []},
    error: (e, st) async => {'tracks': [], 'albums': [], 'playlists': [], 'artists': []},
  );
});

// Available devices provider
final spotifyDevicesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.when(
    data: (credentials) async {
      if (credentials == null) return [];
      
      ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
      
      final apiService = SpotifyApiService(credentials);
      return await apiService.getAvailableDevices();
    },
    loading: () async => [],
    error: (e, st) async => [],
  );
});

// Current playback provider
final spotifyCurrentPlaybackProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
  
  return credentialsAsync.when(
    data: (credentials) async {
      if (credentials == null) return null;
      
      ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
      
      final apiService = SpotifyApiService(credentials);
      return await apiService.getCurrentPlayback();
    },
    loading: () async => null,
    error: (e, st) async => null,
  );
});

// Is track saved provider
final spotifyIsTrackSavedProvider = FutureProvider.family<bool, String>(
  (ref, trackId) async {
    final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);
    
    return credentialsAsync.when(
      data: (credentials) async {
        if (credentials == null) return false;
        
        ref.read(spotifyAuthCredentialsProvider.notifier).refreshTokenIfNeeded();
        
        final apiService = SpotifyApiService(credentials);
        return await apiService.isTrackSaved(trackId);
      },
      loading: () async => false,
      error: (e, st) async => false,
    );
  },
);
