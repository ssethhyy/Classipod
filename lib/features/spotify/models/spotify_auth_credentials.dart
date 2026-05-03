class SpotifyAuthCredentials {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String userId;
  final String? userEmail;
  final String? userDisplayName;

  SpotifyAuthCredentials({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.userId,
    this.userEmail,
    this.userDisplayName,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isExpired && accessToken.isNotEmpty;

  factory SpotifyAuthCredentials.fromJson(Map<String, dynamic> json) {
    return SpotifyAuthCredentials(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'],
      userDisplayName: json['userDisplayName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'userId': userId,
        'userEmail': userEmail,
        'userDisplayName': userDisplayName,
      };

  SpotifyAuthCredentials copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? userId,
    String? userEmail,
    String? userDisplayName,
  }) {
    return SpotifyAuthCredentials(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userDisplayName: userDisplayName ?? this.userDisplayName,
    );
  }
}
