class SpotifyArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> genreList;
  final int? followerCount;
  final double? popularity;

  SpotifyArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.genreList = const [],
    this.followerCount,
    this.popularity,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    return SpotifyArtist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['images']?[0]?['url'] as String?,
      genreList: (json['genres'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
      followerCount: json['followers']?['total'] as int?,
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'images': imageUrl != null ? [{'url': imageUrl}] : [],
        'genres': genreList,
        'followers': {'total': followerCount},
        'popularity': popularity,
      };

  String get genreString => genreList.join(', ');

  SpotifyArtist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? genreList,
    int? followerCount,
    double? popularity,
  }) {
    return SpotifyArtist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      genreList: genreList ?? this.genreList,
      followerCount: followerCount ?? this.followerCount,
      popularity: popularity ?? this.popularity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyArtist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
