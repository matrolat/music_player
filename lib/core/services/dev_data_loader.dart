import '../../config/app_config.dart';
import '../../config/dummy_data/dummy_albums.dart';
import '../../config/dummy_data/dummy_artists.dart';
import '../../config/dummy_data/dummy_songs.dart';

import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/song_model.dart';

class DevDataLoader {
  static List<SongModel> getSongs() => AppConfig.isDevMode ? dummySongs : [];
  static List<AlbumModel> getAlbums() => AppConfig.isDevMode ? dummyAlbums : [];
  static List<ArtistModel> getArtists() => AppConfig.isDevMode ? dummyArtists : [];
}
