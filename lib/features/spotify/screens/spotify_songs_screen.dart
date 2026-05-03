import 'package:classipod/features/custom_screen_elements/custom_screen.dart';
import 'package:classipod/features/spotify/models/spotify_track_model.dart';
import 'package:classipod/features/spotify/providers/spotify_data_providers.dart';
import 'package:classipod/features/status_bar/widgets/status_bar.dart';
import 'package:classipod/core/navigation/routes.dart';
import 'package:classipod/core/extensions/build_context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpotifySongsScreen extends ConsumerStatefulWidget {
  const SpotifySongsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifySongsScreen> createState() => _SpotifySongsScreenState();
}

class _SpotifySongsScreenState extends ConsumerState<SpotifySongsScreen>
    with CustomScreen {
  @override
  String get routeName => 'spotify_songs';

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(spotifyAllSavedTracksProvider);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: 'Spotify Songs'),
          Flexible(
            child: songsAsync.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return Center(
                    child: Text(
                      'No saved songs found',
                      style: context.textTheme.bodyMedium,
                    ),
                  );
                }

                return CupertinoScrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return GestureDetector(
                        onTap: () => _handleSongTap(song),
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
                              if (song.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    song.imageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          width: 40,
                                          height: 40,
                                          color: CupertinoColors.systemGrey,
                                          child: const Icon(
                                            CupertinoIcons.music_note,
                                          ),
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.music_note,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Song info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      song.artistsString,
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
                              // Duration
                              Text(
                                song.durationString,
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

  void _handleSongTap(SpotifyTrack song) {
    // TODO: Integrate with audio player to play this track
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${song.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
