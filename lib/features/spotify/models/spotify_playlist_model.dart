class SpotifyPlaylist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? totalTracks;
  final bool isPublic;
  final String? ownerName;
  final bool isCollaborative;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.totalTracks,
    this.isPublic = true,
    this.ownerName,
    this.isCollaborative = false,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] as String?,
      imageUrl: json['images']?[0]?['url'] as String?,
      totalTracks: json['tracks']?['total'] as int?,
      isPublic: json['public'] ?? true,
      ownerName: json['owner']?['display_name'] as String?,
      isCollaborative: json['collaborative'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'images': imageUrl != null ? [{'url': imageUrl}] : [],
        'tracks': {'total': totalTracks},
        'public': isPublic,
        'owner': {'display_name': ownerName},
        'collaborative': isCollaborative,
      };

  SpotifyPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? totalTracks,
    bool? isPublic,
    String? ownerName,
    bool? isCollaborative,
  }) {
    return SpotifyPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      totalTracks: totalTracks ?? this.totalTracks,
      isPublic: isPublic ?? this.isPublic,
      ownerName: ownerName ?? this.ownerName,
      isCollaborative: isCollaborative ?? this.isCollaborative,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyPlaylist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
