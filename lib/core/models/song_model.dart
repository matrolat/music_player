class SongModel {
  final String id;
  final String title;
  final String artist;
  final String path;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.path,
  });

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? path,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      path: path ?? this.path,
    );
  }
}
