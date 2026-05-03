# Spotify Integration Setup Guide

This guide explains how to set up Spotify integration in ClassiPod.

## Prerequisites

1. A Spotify account (free or premium)
2. A Spotify Developer account and application

## Step 1: Create a Spotify Developer Application

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account (create one if needed)
3. Click "Create an App"
4. Accept the terms and create the app
5. You'll receive:
   - **Client ID**
   - **Client Secret**

⚠️ **Important**: Keep your Client Secret private and never commit it to version control!

## Step 2: Set the Redirect URI

1. In your app settings on Spotify Developer Dashboard, go to "Edit Settings"
2. Add the following Redirect URI:
   ```
   com.adeeteya.classipod://auth/callback
   ```
3. Save the settings

## Step 3: Configure Credentials in ClassiPod

1. Open `lib/features/spotify/services/spotify_oauth_service.dart`
2. Replace the placeholder values:
   ```dart
   const String _clientId = 'YOUR_SPOTIFY_CLIENT_ID';
   const String _clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
   ```
   with your actual credentials from the Spotify Developer Dashboard.

3. Save the file

## Step 4: Build and Run

```bash
flutter pub get
flutter run
```

## Step 5: Authenticate with Spotify

1. Open ClassiPod
2. Go to Settings
3. Find "Spotify" in the settings menu
4. Tap "Login with Spotify"
5. A web browser will open showing Spotify's authorization page
6. Approve the app to access your Spotify account
7. You'll be redirected back to ClassiPod with authorization complete

## Step 6: Toggle Spotify Media Source

Once authenticated:
1. Go to Settings > Spotify
2. You'll see options to:
   - View your connected account
   - Logout
   - Toggle between Local Media and Spotify Media

## Features Available

### Browse Your Spotify Library
- **Saved Tracks**: Access all your liked songs
- **Playlists**: View and browse your playlists
- **Albums**: Browse your saved albums
- **Artists**: View your followed artists
- **Search**: Search Spotify's entire database for songs, albums, playlists, and artists

### Playback Control
When using Spotify media, ClassiPod acts as a remote for your Spotify account:
- Play/Pause
- Skip to next track
- Go to previous track
- Seek through tracks
- Volume control
- Add/remove from library
- Rate songs

### Offline Support
- When internet is unavailable, ClassiPod automatically falls back to locally downloaded Spotify songs
- You can manage downloaded songs through your Spotify app on your phone

## Troubleshooting

### "Unauthorized" Error
- Check that your Client ID and Client Secret are correctly configured
- Ensure they haven't expired in the Spotify Developer Dashboard

### OAuth Redirect Not Working
- Verify that `com.adeeteya.classipod://auth/callback` is set as a Redirect URI in your Spotify app settings
- On Android, ensure you have `internet` permission in `AndroidManifest.xml`

### No Playback Devices Available
- Ensure you have at least one Spotify-enabled device logged in with your account
- The device can be your phone, computer, speaker, etc.

### Token Expired
- The app automatically refreshes tokens when needed
- If issues persist, log out and log back in

## Security Notes

1. **Never commit credentials** to version control
2. Consider using environment variables for sensitive data
3. The app securely stores credentials using platform-specific secure storage
4. To revoke app access, go to Spotify Settings > Apps and remove ClassiPod

## Additional Resources

- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api)
- [Spotify Authorization Guide](https://developer.spotify.com/documentation/general/guides/authorization/)
- [Flutter Secure Storage Package](https://pub.dev/packages/flutter_secure_storage)

## Support

If you encounter issues:
1. Check the app logs in Android Studio / Xcode
2. Verify all configuration steps are completed correctly
3. Ensure your Spotify account has permissions for the required scopes
4. Check Spotify's API status page for any ongoing issues

---

**Note**: This implementation uses the Spotify Web API for playback control. Actual audio playback occurs on a Spotify-enabled device you own, with ClassiPod serving as the remote control interface.
