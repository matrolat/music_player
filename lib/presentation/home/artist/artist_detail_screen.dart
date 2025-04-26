import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/artist_model.dart';
import '../../../state/player_bloc/player_bloc.dart';
import '../../../state/player_bloc/player_event.dart';
import '../../../state/player_bloc/player_state.dart';
import '../../common/player_controls/mini_player.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  bool _areSongsSame(song1, song2) {
    return song1.id == song2.id && song1.title == song2.title;
  }

  double calculateExpandedHeight(String name) {
    final lines = (name.length / 20).ceil();
    return 300 + (lines * 20);
  }

  @override
  Widget build(BuildContext context) {
    final hasValidImage = (artist.imagePath?.isNotEmpty ?? false) &&
        File(artist.imagePath!).existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          var playingSong;
          if (state is PlayerPlaying || state is PlayerPaused) {
            playingSong = (state as dynamic).song;
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                expandedHeight: calculateExpandedHeight(artist.name),
                floating: false,
                pinned: true,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: CircleAvatar(
                          radius: 110,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: hasValidImage
                              ? FileImage(File(artist.imagePath!))
                              : null,
                          child: !hasValidImage
                              ? const Icon(Icons.person, color: Colors.white24, size: 100)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          artist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = artist.songs[index];
                    final isCurrent = playingSong != null && _areSongsSame(song, playingSong);

                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          tileColor: isCurrent ? Colors.white10 : Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Icon(Icons.music_note,
                              color: isCurrent ? Colors.greenAccent : Colors.white),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              color: isCurrent ? Colors.greenAccent : Colors.white,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          onTap: () {
                            context.read<PlayerBloc>().add(
                              PlaySong(song, queue: artist.songs),
                            );
                          },
                        ),
                        const Divider(color: Colors.white12, height: 1),
                      ],
                    );
                  },
                  childCount: artist.songs.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
