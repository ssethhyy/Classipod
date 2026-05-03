import 'package:classipod/features/custom_screen_elements/custom_screen.dart';
import 'package:classipod/features/spotify/models/spotify_playlist_model.dart';
import 'package:classipod/features/spotify/providers/spotify_data_providers.dart';
import 'package:classipod/features/status_bar/widgets/status_bar.dart';
import 'package:classipod/core/extensions/build_context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpotifyPlaylistsScreen extends ConsumerStatefulWidget {
  const SpotifyPlaylistsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifyPlaylistsScreen> createState() =>
      _SpotifyPlaylistsScreenState();
}

class _SpotifyPlaylistsScreenState extends ConsumerState<SpotifyPlaylistsScreen>
    with CustomScreen {
  @override
  String get routeName => 'spotify_playlists';

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(spotifyPlaylistsProvider);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: 'Spotify Playlists'),
          Flexible(
            child: playlistsAsync.when(
              data: (playlists) {
                if (playlists.isEmpty) {
                  return Center(
                    child: Text(
                      'No playlists found',
                      style: context.textTheme.bodyMedium,
                    ),
                  );
                }

                return CupertinoScrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return GestureDetector(
                        onTap: () => _handlePlaylistTap(playlist),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.separator,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Playlist image
                              if (playlist.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    playlist.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          width: 50,
                                          height: 50,
                                          color: CupertinoColors.systemGrey,
                                          child: const Icon(
                                            CupertinoIcons.music_note_list,
                                          ),
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.music_note_list,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Playlist info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlist.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${playlist.totalTracks ?? 0} songs',
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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

  void _handlePlaylistTap(SpotifyPlaylist playlist) {
    // TODO: Navigate to playlist songs screen or play all songs from playlist
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${playlist.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
