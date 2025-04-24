import 'package:equatable/equatable.dart';

abstract class MusicEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMusicEvent extends MusicEvent {
  final bool forceRefresh;

  LoadMusicEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshRecentlyPlayedEvent extends MusicEvent {} // ✅ NEW

