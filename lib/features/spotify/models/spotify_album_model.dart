class SpotifyAlbum {
  final String id;
  final String name;
  final List<String> artistNames;
  final String? imageUrl;
  final int? totalTracks;
  final String? releaseDate;
  final String? albumType;
  final List<String> genreList;

  SpotifyAlbum({
    required this.id,
    required this.name,
    required this.artistNames,
    this.imageUrl,
    this.totalTracks,
    this.releaseDate,
    this.albumType,
    this.genreList = const [],
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbum(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artistNames: (json['artists'] as List<dynamic>?)
              ?.map((e) => e['name'] as String)
              .toList() ??
          [],
      imageUrl: json['images']?[0]?['url'] as String?,
      totalTracks: json['total_tracks'] as int?,
      releaseDate: json['release_date'] as String?,
      albumType: json['album_type'] as String?,
      genreList: (json['genres'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'artists': artistNames.map((e) => {'name': e}).toList(),
        'images': imageUrl != null ? [{'url': imageUrl}] : [],
        'total_tracks': totalTracks,
        'release_date': releaseDate,
        'album_type': albumType,
        'genres': genreList,
      };

  String get artistsString => artistNames.join(', ');

  SpotifyAlbum copyWith({
    String? id,
    String? name,
    List<String>? artistNames,
    String? imageUrl,
    int? totalTracks,
    String? releaseDate,
    String? albumType,
    List<String>? genreList,
  }) {
    return SpotifyAlbum(
      id: id ?? this.id,
      name: name ?? this.name,
      artistNames: artistNames ?? this.artistNames,
      imageUrl: imageUrl ?? this.imageUrl,
      totalTracks: totalTracks ?? this.totalTracks,
      releaseDate: releaseDate ?? this.releaseDate,
      albumType: albumType ?? this.albumType,
      genreList: genreList ?? this.genreList,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyAlbum &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
