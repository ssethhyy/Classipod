import 'package:classipod/features/custom_screen_elements/custom_screen.dart';
import 'package:classipod/features/spotify/models/spotify_album_model.dart';
import 'package:classipod/features/spotify/models/spotify_artist_model.dart';
import 'package:classipod/features/spotify/models/spotify_playlist_model.dart';
import 'package:classipod/features/spotify/models/spotify_track_model.dart';
import 'package:classipod/features/spotify/providers/spotify_data_providers.dart';
import 'package:classipod/features/status_bar/widgets/status_bar.dart';
import 'package:classipod/core/extensions/build_context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpotifySearchScreen extends ConsumerStatefulWidget {
  const SpotifySearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifySearchScreen> createState() =>
      _SpotifySearchScreenState();
}

class _SpotifySearchScreenState extends ConsumerState<SpotifySearchScreen>
    with CustomScreen {
  String _searchQuery = '';

  @override
  String get routeName => 'spotify_search';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(spotifySearchProvider(_searchQuery));

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: 'Search Spotify'),
          // Search input
          Container(
            padding: const EdgeInsets.all(12),
            child: CupertinoTextField(
              placeholder: 'Search songs, artists, albums...',
              placeholderStyle: const TextStyle(
                color: CupertinoColors.placeholderText,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.search),
              ),
              suffix: _searchQuery.isNotEmpty
                  ? CupertinoButton(
                      padding: const EdgeInsets.only(right: 8),
                      child: const Icon(CupertinoIcons.clear_thick_circle),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
          ),
          // Search results
          Flexible(
            child: _searchQuery.isEmpty
                ? Center(
                    child: Text(
                      'Enter search term',
                      style: context.textTheme.bodyMedium,
                    ),
                  )
                : searchResults.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Text(
                            'No results found',
                            style: context.textTheme.bodyMedium,
                          ),
                        );
                      }

                      return CupertinoScrollbar(
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final item = results[index];
                            if (item is SpotifyTrack) {
                              return _buildTrackTile(item);
                            } else if (item is SpotifyAlbum) {
                              return _buildAlbumTile(item);
                            } else if (item is SpotifyPlaylist) {
                              return _buildPlaylistTile(item);
                            } else if (item is SpotifyArtist) {
                              return _buildArtistTile(item);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                    error: (error, st) => Center(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(SpotifyTrack track) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator),
        ),
      ),
      child: Row(
        children: [
          if (track.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                track.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(
                  CupertinoIcons.music_note,
                ),
              ),
            )
          else
            _buildPlaceholderIcon(CupertinoIcons.music_note),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  track.artistsString,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumTile(SpotifyAlbum album) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator),
        ),
      ),
      child: Row(
        children: [
          if (album.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                album.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(
                  CupertinoIcons.disc,
                ),
              ),
            )
          else
            _buildPlaceholderIcon(CupertinoIcons.disc),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  'Album • ${album.artistsString}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistTile(SpotifyPlaylist playlist) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator),
        ),
      ),
      child: Row(
        children: [
          if (playlist.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                playlist.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(
                  CupertinoIcons.music_note_list,
                ),
              ),
            )
          else
            _buildPlaceholderIcon(CupertinoIcons.music_note_list),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  'Playlist • ${playlist.totalTracks ?? 0} songs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistTile(SpotifyArtist artist) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator),
        ),
      ),
      child: Row(
        children: [
          if (artist.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                artist.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(
                  CupertinoIcons.person,
                ),
              ),
            )
          else
            _buildPlaceholderIcon(CupertinoIcons.person),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  'Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon),
    );
  }
}
