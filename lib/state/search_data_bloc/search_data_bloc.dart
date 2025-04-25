import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/song_model.dart';
import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import '../../core/services/music_service.dart';

part 'search_data_event.dart';
part 'search_data_state.dart';

class SearchDataBloc extends Bloc<SearchDataEvent, SearchDataState> {
  final MusicService _musicService;

  SearchDataBloc(this._musicService) : super(SearchDataLoading()) {
    on<LoadSearchData>(_onLoad);
  }

Future<void> _onLoad(LoadSearchData event, Emitter<SearchDataState> emit) async {
  try {
    emit(SearchDataLoaded(event.songs, event.albums, event.artists));
  } catch (e) {
    emit(SearchDataError('Failed to load search data: $e'));
  }
}

}
