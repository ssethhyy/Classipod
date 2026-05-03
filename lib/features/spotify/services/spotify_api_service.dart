import 'package:classipod/features/spotify/models/spotify_album_model.dart';
import 'package:classipod/features/spotify/models/spotify_artist_model.dart';
import 'package:classipod/features/spotify/models/spotify_auth_credentials.dart';
import 'package:classipod/features/spotify/models/spotify_playlist_model.dart';
import 'package:classipod/features/spotify/models/spotify_track_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _spotifyApiBaseUrl = 'https://api.spotify.com/v1';
const String _spotifyAuthUrl = 'https://accounts.spotify.com';

class SpotifyApiException implements Exception {
  final String message;
  final int? statusCode;

  SpotifyApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SpotifyApiService {
  late SpotifyAuthCredentials _credentials;

  SpotifyApiService(SpotifyAuthCredentials credentials) {
    _credentials = credentials;
  }

  void updateCredentials(SpotifyAuthCredentials credentials) {
    _credentials = credentials;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final url = Uri.parse('$_spotifyApiBaseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final headers = {
        'Authorization': 'Bearer ${_credentials.accessToken}',
        'Content-Type': 'application/json',
      };

      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw SpotifyApiException('Invalid HTTP method: $method');
      }

      if (response.statusCode == 401) {
        throw SpotifyApiException(
          'Unauthorized. Please re-authenticate.',
          statusCode: 401,
        );
      }

      if (response.statusCode >= 400) {
        throw SpotifyApiException(
          'API Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 204) {
        return {}; // No content
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is SpotifyApiException) rethrow;
      throw SpotifyApiException('Network error: $e');
    }
  }

  // User Profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    return await _makeRequest('/me');
  }

  // Saved Tracks
  Future<List<SpotifyTrack>> getSavedTracks({int limit = 50, int offset = 0}) async {
    final response = await _makeRequest(
      '/me/tracks',
      queryParams: {'limit': '$limit', 'offset': '$offset'},
    );

    final items = (response['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map((item) {
      final track = item['track'] as Map<String, dynamic>?;
      return SpotifyTrack.fromJson(track ?? {});
    }).toList();
  }

  // Saved Playlists
  Future<List<SpotifyPlaylist>> getUserPlaylists({int limit = 50, int offset = 0}) async {
    final response = await _makeRequest(
      '/me/playlists',
      queryParams: {'limit': '$limit', 'offset': '$offset'},
    );

    final items = (response['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map((item) => SpotifyPlaylist.fromJson(item)).toList();
  }

  // Playlist Tracks
  Future<List<SpotifyTrack>> getPlaylistTracks(
    String playlistId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _makeRequest(
      '/playlists/$playlistId/tracks',
      queryParams: {'limit': '$limit', 'offset': '$offset'},
    );

    final items = (response['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map((item) {
      final track = item['track'] as Map<String, dynamic>?;
      return SpotifyTrack.fromJson(track ?? {});
    }).toList();
  }

  // Saved Albums
  Future<List<SpotifyAlbum>> getSavedAlbums({int limit = 50, int offset = 0}) async {
    final response = await _makeRequest(
      '/me/albums',
      queryParams: {'limit': '$limit', 'offset': '$offset'},
    );

    final items = (response['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map((item) {
      final album = item['album'] as Map<String, dynamic>?;
      return SpotifyAlbum.fromJson(album ?? {});
    }).toList();
  }

  // Album Tracks
  Future<List<SpotifyTrack>> getAlbumTracks(
    String albumId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _makeRequest(
      '/albums/$albumId/tracks',
      queryParams: {'limit': '$limit', 'offset': '$offset'},
    );

    final items = (response['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map((item) => SpotifyTrack.fromJson(item)).toList();
  }

  // Search
  Future<Map<String, dynamic>> search(
    String query, {
    String type = 'track,album,playlist,artist',
    int limit = 20,
  }) async {
    final response = await _makeRequest(
      '/search',
      queryParams: {
        'q': query,
        'type': type,
        'limit': '$limit',
      },
    );

    final results = {
      'tracks': <SpotifyTrack>[],
      'albums': <SpotifyAlbum>[],
      'playlists': <SpotifyPlaylist>[],
      'artists': <SpotifyArtist>[],
    };

    if (response.containsKey('tracks')) {
      final tracks = (response['tracks']['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      results['tracks'] = tracks.map((t) => SpotifyTrack.fromJson(t)).toList();
    }

    if (response.containsKey('albums')) {
      final albums = (response['albums']['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      results['albums'] = albums.map((a) => SpotifyAlbum.fromJson(a)).toList();
    }

    if (response.containsKey('playlists')) {
      final playlists = (response['playlists']['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      results['playlists'] = playlists.map((p) => SpotifyPlaylist.fromJson(p)).toList();
    }

    if (response.containsKey('artists')) {
      final artists = (response['artists']['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      results['artists'] = artists.map((a) => SpotifyArtist.fromJson(a)).toList();
    }

    return results;
  }

  // Playback - Get Available Devices
  Future<List<Map<String, dynamic>>> getAvailableDevices() async {
    final response = await _makeRequest('/me/player/devices');
    return (response['devices'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
  }

  // Playback - Get Current Playback State
  Future<Map<String, dynamic>?> getCurrentPlayback() async {
    try {
      return await _makeRequest('/me/player');
    } catch (e) {
      return null;
    }
  }

  // Playback - Start/Resume Playing
  Future<void> startPlayback({
    String? deviceId,
    String? contextUri,
    List<String>? uris,
    int? offsetPosition,
  }) async {
    final body = <String, dynamic>{};
    if (contextUri != null) body['context_uri'] = contextUri;
    if (uris != null) body['uris'] = uris;
    if (offsetPosition != null) body['offset'] = {'position': offsetPosition};

    await _makeRequest(
      '/me/player/play',
      method: 'PUT',
      body: body,
      queryParams: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  // Playback - Pause
  Future<void> pausePlayback({String? deviceId}) async {
    await _makeRequest(
      '/me/player/pause',
      method: 'PUT',
      queryParams: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  // Playback - Next Track
  Future<void> nextTrack({String? deviceId}) async {
    await _makeRequest(
      '/me/player/next',
      method: 'POST',
      queryParams: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  // Playback - Previous Track
  Future<void> previousTrack({String? deviceId}) async {
    await _makeRequest(
      '/me/player/previous',
      method: 'POST',
      queryParams: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  // Playback - Seek
  Future<void> seek(int positionMs, {String? deviceId}) async {
    await _makeRequest(
      '/me/player/seek',
      method: 'PUT',
      queryParams: {
        'position_ms': '$positionMs',
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  // Playback - Set Volume
  Future<void> setVolume(int volumePercent, {String? deviceId}) async {
    await _makeRequest(
      '/me/player/volume',
      method: 'PUT',
      queryParams: {
        'volume_percent': '$volumePercent',
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  // Check if Track is Saved
  Future<bool> isTrackSaved(String trackId) async {
    final response = await _makeRequest('/me/tracks/contains', queryParams: {'ids': trackId});
    final contains = (response as List<dynamic>?)?.first as bool? ?? false;
    return contains;
  }

  // Save Track
  Future<void> saveTrack(String trackId) async {
    await _makeRequest(
      '/me/tracks',
      method: 'PUT',
      queryParams: {'ids': trackId},
    );
  }

  // Remove Saved Track
  Future<void> removeTrack(String trackId) async {
    await _makeRequest(
      '/me/tracks',
      method: 'DELETE',
      queryParams: {'ids': trackId},
    );
  }

  // Get Recommendations
  Future<List<SpotifyTrack>> getRecommendations({
    List<String>? seedTracks,
    List<String>? seedArtists,
    List<String>? seedGenres,
    int limit = 20,
  }) async {
    final response = await _makeRequest(
      '/recommendations',
      queryParams: {
        if (seedTracks != null) 'seed_tracks': seedTracks.join(','),
        if (seedArtists != null) 'seed_artists': seedArtists.join(','),
        if (seedGenres != null) 'seed_genres': seedGenres.join(','),
        'limit': '$limit',
      },
    );

    final items = (response['tracks'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map((item) => SpotifyTrack.fromJson(item)).toList();
  }
}
