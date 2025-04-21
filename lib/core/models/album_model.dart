import 'song_model.dart';

class AlbumModel {
  final String id;
  final String title;
  final String imagePath;
  final List<SongModel> songs;

  AlbumModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.songs,
  });
}
