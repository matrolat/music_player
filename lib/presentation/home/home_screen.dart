import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import '../../core/models/song_model.dart';
import '../../state/music_bloc/music_bloc.dart';
import '../../state/music_bloc/music_event.dart';
import '../../state/music_bloc/music_state.dart';
import '../../state/player_bloc/player_bloc.dart';
import '../../state/player_bloc/player_state.dart';
import '../common/section_header.dart';
import 'widgets/carousel_section.dart';
import 'see_all_screen.dart';
import '../common/audio_player_controls.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicBloc, MusicState>(
      listener: (context, state) {
        if (state is MusicLoaded && state.refreshed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Music library refreshed')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Home', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<MusicBloc>().add(LoadMusicEvent(forceRefresh: true));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<MusicBloc, MusicState>(
                builder: (context, state) {
                  if (state is MusicLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MusicLoaded) {
                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        SectionHeader(
                          title: 'Recently Played',
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SeeAllScreen<SongModel>(
                                  title: 'Recently Played',
                                  items: state.songs,
                                ),
                              ),
                            );
                          },
                        ),
                        CarouselSection.songs(state.songs),

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
                    );
                  } else if (state is MusicError) {
                    return Center(
                      child: Text(state.message, style: const TextStyle(color: Colors.white)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            // ✅ Only show player controls if music is playing or paused
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                if (state is PlayerPlaying || state is PlayerPaused) {
                  return const AudioPlayerControls();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
