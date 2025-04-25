import '../../core/models/song_model.dart';
import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import 'music_service.dart';

class SearchDataProvider {
  final MusicService _musicService;

  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];

  SearchDataProvider(this._musicService);

  List<SongModel> get songs => _songs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;

  Future<void> loadAll() async {
    _songs = await _musicService.fetchSongs(forceRefresh: false);
    _albums = await _musicService.fetchAlbums(forceRefresh: false);
    _artists = await _musicService.fetchArtists(forceRefresh: false);
  }
}
