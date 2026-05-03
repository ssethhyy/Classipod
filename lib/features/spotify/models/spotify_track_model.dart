class SpotifyTrack {
  final String id;
  final String name;
  final List<String> artistNames;
  final String? albumName;
  final String? imageUrl;
  final int durationMs;
  final bool isExplicit;
  final bool isLocal;
  final String? previewUrl;
  final double? popularity;
  final String? releaseDate;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistNames,
    this.albumName,
    this.imageUrl,
    required this.durationMs,
    this.isExplicit = false,
    this.isLocal = false,
    this.previewUrl,
    this.popularity,
    this.releaseDate,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artistNames: (json['artists'] as List<dynamic>?)
              ?.map((e) => e['name'] as String)
              .toList() ??
          [],
      albumName: json['album']?['name'] as String?,
      imageUrl: json['album']?['images']?[0]?['url'] as String?,
      durationMs: json['duration_ms'] ?? 0,
      isExplicit: json['explicit'] ?? false,
      isLocal: json['is_local'] ?? false,
      previewUrl: json['preview_url'] as String?,
      popularity: (json['popularity'] ?? 0).toDouble(),
      releaseDate: json['album']?['release_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'artists': artistNames.map((e) => {'name': e}).toList(),
        'album': {
          'name': albumName,
          'images': imageUrl != null ? [{'url': imageUrl}] : [],
          'release_date': releaseDate,
        },
        'duration_ms': durationMs,
        'explicit': isExplicit,
        'is_local': isLocal,
        'preview_url': previewUrl,
        'popularity': popularity,
      };

  String get artistsString => artistNames.join(', ');

  String get durationString {
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SpotifyTrack copyWith({
    String? id,
    String? name,
    List<String>? artistNames,
    String? albumName,
    String? imageUrl,
    int? durationMs,
    bool? isExplicit,
    bool? isLocal,
    String? previewUrl,
    double? popularity,
    String? releaseDate,
  }) {
    return SpotifyTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      artistNames: artistNames ?? this.artistNames,
      albumName: albumName ?? this.albumName,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMs: durationMs ?? this.durationMs,
      isExplicit: isExplicit ?? this.isExplicit,
      isLocal: isLocal ?? this.isLocal,
      previewUrl: previewUrl ?? this.previewUrl,
      popularity: popularity ?? this.popularity,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyTrack &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
