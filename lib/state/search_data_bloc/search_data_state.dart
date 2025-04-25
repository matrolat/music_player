part of 'search_data_bloc.dart';

abstract class SearchDataState {}

class SearchDataLoading extends SearchDataState {}

class SearchDataLoaded extends SearchDataState {
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;

  SearchDataLoaded(this.songs, this.albums, this.artists);
}

class SearchDataError extends SearchDataState {
  final String message;
  SearchDataError(this.message);
}
