import 'package:classipod/features/custom_screen_elements/custom_screen.dart';
import 'package:classipod/features/spotify/models/spotify_album_model.dart';
import 'package:classipod/features/spotify/providers/spotify_data_providers.dart';
import 'package:classipod/features/status_bar/widgets/status_bar.dart';
import 'package:classipod/core/extensions/build_context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpotifyAlbumsScreen extends ConsumerStatefulWidget {
  const SpotifyAlbumsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifyAlbumsScreen> createState() =>
      _SpotifyAlbumsScreenState();
}

class _SpotifyAlbumsScreenState extends ConsumerState<SpotifyAlbumsScreen>
    with CustomScreen {
  @override
  String get routeName => 'spotify_albums';

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(spotifyAlbumsProvider);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: 'Spotify Albums'),
          Flexible(
            child: albumsAsync.when(
              data: (albums) {
                if (albums.isEmpty) {
                  return Center(
                    child: Text(
                      'No saved albums found',
                      style: context.textTheme.bodyMedium,
                    ),
                  );
                }

                return CupertinoScrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return GestureDetector(
                        onTap: () => _handleAlbumTap(album),
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
                              // Album art
                              if (album.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    album.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          width: 50,
                                          height: 50,
                                          color: CupertinoColors.systemGrey,
                                          child: const Icon(
                                            CupertinoIcons.disc,
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
                                    CupertinoIcons.disc,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Album info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      album.artistsString,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Track count
                              Text(
                                '${album.totalTracks ?? 0}',
                                style: context.textTheme.bodySmall,
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

  void _handleAlbumTap(SpotifyAlbum album) {
    // TODO: Navigate to album songs screen or play all songs from album
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${album.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
