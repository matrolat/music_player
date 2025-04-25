import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/state/search_data_bloc/search_data_bloc.dart';

import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import '../../core/models/song_model.dart';
import '../../state/music_bloc/music_bloc.dart';
import '../../state/music_bloc/music_event.dart';
import '../../state/music_bloc/music_state.dart';
import '../common/section_header.dart';
import 'widgets/carousel_section.dart';
import 'see_all_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicBloc, MusicState>(
      listener: (context, state) {
        if (state is MusicLoaded && state.refreshed) {
          context.read<SearchDataBloc>().add(
                LoadSearchData(state.songs, state.albums, state.artists),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Music library refreshed')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('Home', style: TextStyle(color: Colors.white)),
        ),
        body: BlocBuilder<MusicBloc, MusicState>(
          builder: (context, state) {
            if (state is MusicLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MusicLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<MusicBloc>()
                      .add(LoadMusicEvent(forceRefresh: true));
                },
                color: Colors.white,
                backgroundColor: Colors.grey[850],
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (state.recentlyPlayed.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Recently Played',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeeAllScreen<SongModel>(
                                title: 'Recently Played',
                                items: state.recentlyPlayed,
                              ),
                            ),
                          );
                        },
                      ),
                      CarouselSection.songs(state.recentlyPlayed),
                    ],
                    if (state.albums.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Albums',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeeAllScreen<AlbumModel>(
                                title: 'Albums',
                                items: state.albums,
                              ),
                            ),
                          );
                        },
                      ),
                      CarouselSection.albums(state.albums),
                    ],
                    if (state.artists.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Artists',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeeAllScreen<ArtistModel>(
                                title: 'Artists',
                                items: state.artists,
                              ),
                            ),
                          );
                        },
                      ),
                      CarouselSection.artists(state.artists),
                    ],
                  ],
                ),
              );
            } else if (state is MusicError) {
              return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.white)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
