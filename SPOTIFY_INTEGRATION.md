# Spotify Integration for ClassiPod

## Overview

This implementation adds comprehensive Spotify integration to ClassiPod, allowing users to browse and control their Spotify library directly from the app. The implementation follows ClassiPod's retro iPod aesthetic while providing modern streaming capabilities.

## What's Been Implemented

### 1. ✅ Authentication System
- OAuth 2.0 authentication with web popup
- Secure credential storage using `flutter_secure_storage`
- Deep linking for OAuth redirect handling
- Automatic token refresh before expiration
- Login/logout functionality

### 2. ✅ Spotify API Integration
- Complete Spotify Web API wrapper (`SpotifyApiService`)
- Methods for browsing:
  - Saved tracks/liked songs
  - User playlists
  - Saved albums
  - Followed artists
- Search functionality across all types
- Playback control methods:
  - Play/pause
  - Skip/previous
  - Seek position
  - Volume control
  - Add/remove from library

### 3. ✅ User Interface
- Spotify settings section in main Settings menu
- Spotify authentication widget with login/logout
- Spotify songs browser screen
- Spotify playlists browser screen
- Spotify albums browser screen
- Spotify search screen with unified search

### 4. ✅ Settings Integration
- Toggle between local media and Spotify media
- Settings persisted to device storage
- Spotify media source preference saved
- User can easily switch between libraries

### 5. ✅ Data Management
- Riverpod providers for reactive state management
- FutureProviders for async data fetching
- Automatic pagination for large libraries
- Proper error handling and loading states

### 6. ✅ Security
- Secure credential storage (never in shared preferences)
- OAuth tokens refreshed automatically
- Deep linking for auth redirects
- Proper error messages without exposing sensitive data

## Getting Started

### Prerequisites
1. Spotify account (free or premium)
2. Android/iOS development environment
3. Flutter 3.35.7+ 

### Setup Instructions

#### 1. Create Spotify Developer App
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Get your **Client ID** and **Client Secret**

#### 2. Configure in ClassiPod
1. Open `lib/features/spotify/services/spotify_oauth_service.dart`
2. Replace:
   ```dart
   const String _clientId = 'YOUR_SPOTIFY_CLIENT_ID';
   const String _clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
   ```

#### 3. Set Redirect URI
In Spotify Developer Dashboard, add redirect URI:
```
com.adeeteya.classipod://auth/callback
```

#### 4. Build & Run
```bash
flutter pub get
flutter run
```

#### 5. Test in App
1. Go to Settings
2. Find "Spotify" option
3. Tap "Login with Spotify"
4. Authorize the app
5. Browse Spotify content
6. Toggle between Local and Spotify media

## Project Structure

```
lib/features/spotify/
├── models/
│   ├── spotify_track_model.dart
│   ├── spotify_album_model.dart
│   ├── spotify_playlist_model.dart
│   ├── spotify_artist_model.dart
│   └── spotify_auth_credentials.dart
├── services/
│   ├── spotify_oauth_service.dart       # OAuth authentication
│   ├── spotify_api_service.dart         # Spotify Web API wrapper
│   └── spotify_auth_service.dart        # Credential storage
├── providers/
│   ├── spotify_auth_provider.dart       # Auth state management
│   ├── spotify_data_providers.dart      # Library data providers
│   └── unified_music_provider.dart      # Local/Spotify switching
└── screens/
    ├── spotify_settings_widget.dart     # Settings UI
    ├── spotify_songs_screen.dart        # Browse songs
    ├── spotify_playlists_screen.dart    # Browse playlists
    ├── spotify_albums_screen.dart       # Browse albums
    └── spotify_search_screen.dart       # Search functionality
```

## Features

### Browse Your Library
- **Saved Tracks**: All your liked songs with artwork, artist names, duration
- **Playlists**: Your created and followed playlists
- **Albums**: Your saved albums with track count
- **Search**: Search across entire Spotify database for songs, albums, playlists, artists

### Playback Control (Ready for Integration)
- Play/pause control
- Skip to next track
- Go to previous track
- Seek through tracks
- Volume adjustment
- Add/remove from library
- Rate songs

### Seamless Switching
- Toggle between local and Spotify media in settings
- Toggle persisted to device
- Automatic switching of UI based on selection
- No manual app restart required

## Technical Implementation

### State Management
- **Riverpod** for reactive state
- FutureProviders for async operations
- StateNotifierProvider for auth state
- Provider for derived state

### Authentication
- OAuth 2.0 with PKCE (secure)
- Redirect URL handled via deep links
- Automatic token refresh
- Secure storage of credentials

### API Integration
- HTTP requests with proper error handling
- Pagination support for large datasets
- Rate limiting aware
- Proper header management

### UI/UX
- Consistent with ClassiPod's retro design
- Network image loading with fallbacks
- Loading and error states
- Responsive to different screen sizes

## What's Not Yet Implemented

### Playback Integration
- **Real-time playback display**: Shows current track, progress, and duration
- **Now Playing integration**: Display Spotify track on the now playing screen
- **Playback device selection**: Choose which device to play on
- **Local file fallback**: Show downloaded Spotify songs when offline

### Advanced Features
- Playlist editing (add/remove tracks)
- Creating new playlists
- Following/unfollowing artists
- Recommendations based on current playback
- Listening history/recently played
- Top tracks/artists by time period
- Audio quality selection

### UI Enhancements
- Album detail view with all tracks
- Artist detail view with discography
- Playlist detail view
- Cover flow for Spotify albums
- Integration with existing now playing screen

## How to Extend

See **SPOTIFY_DEVELOPER_GUIDE.md** for detailed implementation instructions for:
1. Adding real-time playback display
2. Integrating with now playing screen
3. Implementing device selection
4. Adding offline sync support
5. Creating advanced features

## Dependencies Added

```yaml
spotify: ^0.0.21              # Spotify SDK
flutter_secure_storage: ^9.2.2  # Secure credential storage
http: ^1.1.0                 # HTTP requests
app_links: ^4.1.0            # Deep linking for OAuth
cached_network_image: ^3.3.1 # Network image caching
```

## File Changes

Modified existing files:
- `pubspec.yaml` - Added dependencies
- `shared_preference_keys.dart` - Added useSpotifyMedia key
- `settings_preferences_model.dart` - Added useSpotifyMedia field
- `settings_preferences_repository.dart` - Added getter/setter
- `settings_preferences_controller.dart` - Added toggle method
- `settings_preferences_screen.dart` - Added Spotify to menu

## Testing Checklist

- [ ] Can authenticate with Spotify
- [ ] Credentials are stored securely
- [ ] Can browse saved tracks
- [ ] Can browse playlists
- [ ] Can browse albums
- [ ] Search returns results
- [ ] Can toggle between local and Spotify
- [ ] Toggle preference persists across app restarts
- [ ] Logout clears credentials
- [ ] Token refresh works automatically
- [ ] Error handling displays user-friendly messages

## Troubleshooting

### "Cannot find Spotify credentials"
- Ensure Spotify Developer app is created
- Check Client ID and Client Secret are correct
- Verify redirect URI is set in Spotify Dashboard

### "Deep link not working"
- On Android: Check AndroidManifest.xml has deep link intent filter
- On iOS: Check Info.plist has URL scheme
- Restart app after configuration changes

### "No results in search"
- Verify internet connection
- Check Spotify API status
- Ensure valid search query

### "Playback not working"
- See SPOTIFY_DEVELOPER_GUIDE.md section on enabling playback
- Requires Spotify device to be active
- Must be authenticated

## Support & Documentation

- **Setup Guide**: See SPOTIFY_SETUP.md
- **Developer Guide**: See SPOTIFY_DEVELOPER_GUIDE.md
- **API Reference**: [Spotify Web API Docs](https://developer.spotify.com/documentation/web-api)
- **Riverpod**: [Riverpod Documentation](https://riverpod.dev)

## Next Steps

To fully implement Spotify playback in your music player:

1. **Implement SpotifyPlaybackManager** (code in SPOTIFY_DEVELOPER_GUIDE.md)
2. **Add media source toggle** to main music menu
3. **Integrate with now playing screen** for track display
4. **Add device selection** for playback
5. **Implement offline support** for downloaded songs

See SPOTIFY_DEVELOPER_GUIDE.md for complete code examples and detailed instructions.

## Architecture Benefits

- **Clean separation**: Spotify features isolated in own module
- **Reusable components**: Can be used by other features
- **Testable**: Easy to unit test with Riverpod
- **Maintainable**: Clear file structure and responsibilities
- **Scalable**: Easy to add new Spotify features

## Performance Notes

- Paginated API calls for large libraries
- Network images cached locally
- Providers memoize results
- Automatic token refresh before expiration
- Efficient ListView rendering

## Future Enhancements

- Real-time playback display
- Playlist creation/editing
- Smart recommendations
- Listening history
- Social features
- Cross-device playback
- Audio quality control

---

**Version**: 1.0.0  
**Last Updated**: May 2026  
**Status**: Foundation Complete ✅ | Playback Integration Ready 🚀
