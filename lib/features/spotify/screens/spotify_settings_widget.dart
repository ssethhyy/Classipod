import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classipod/features/spotify/providers/spotify_auth_provider.dart';
import 'package:classipod/core/extensions/build_context_extensions.dart';

class SpotifySettingsWidget extends ConsumerWidget {
  const SpotifySettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialsAsync = ref.watch(spotifyAuthCredentialsProvider);

    return credentialsAsync.when(
      data: (credentials) {
        final isLoggedIn = credentials != null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Spotify Integration',
                style: context.textTheme.headlineSmall,
              ),
            ),

            // Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isLoggedIn
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.inactiveGray,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLoggedIn
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.inactiveGray,
                      ),
                    ),
                    if (isLoggedIn && credentials.userDisplayName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          credentials.userDisplayName!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Authenticate Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: isLoggedIn
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemBlue,
                  onPressed: () async {
                    if (isLoggedIn) {
                      await ref
                          .read(spotifyAuthCredentialsProvider.notifier)
                          .logout();
                    } else {
                      await ref
                          .read(spotifyAuthCredentialsProvider.notifier)
                          .authenticate();
                    }
                  },
                  child: Text(
                    isLoggedIn ? 'Logout' : 'Login with Spotify',
                  ),
                ),
              ),
            ),

            // Info text
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Tap "Login with Spotify" to authorize Classipod with your Spotify account. You can then toggle between local and Spotify media.',
                  style: const TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
      loading: () {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: CupertinoActivityIndicator(),
        );
      },
      error: (error, st) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: $error',
            style: const TextStyle(color: CupertinoColors.systemRed),
          ),
        );
      },
    );
  }
}
