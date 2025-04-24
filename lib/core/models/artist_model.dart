import 'song_model.dart';

class ArtistModel {
  final String id;
  final String name;
  final String imagePath;
  final List<SongModel> songs;

  ArtistModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.songs,
  });
}
