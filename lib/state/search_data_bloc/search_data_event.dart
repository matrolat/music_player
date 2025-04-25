part of 'search_data_bloc.dart';

abstract class SearchDataEvent {}

class LoadSearchData extends SearchDataEvent {
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;

  LoadSearchData(this.songs, this.albums, this.artists);
}
