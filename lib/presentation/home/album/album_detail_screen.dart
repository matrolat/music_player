import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/album_model.dart';
import '../../../state/player_bloc/player_bloc.dart';
import '../../../state/player_bloc/player_event.dart';
import '../../../state/player_bloc/player_state.dart';
import '../../common/player_controls/mini_player.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  bool _areSongsSame(song1, song2) {
    return song1.id == song2.id && song1.title == song2.title;
  }

  double calculateExpandedHeight(String title) {
    final lines = (title.length / 20).ceil();
    return 280 + (lines * 20);
  }

  @override
  Widget build(BuildContext context) {
    final hasValidImage = (album.imagePath?.isNotEmpty ?? false) &&
        File(album.imagePath!).existsSync();

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
                expandedHeight: calculateExpandedHeight(album.title),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: hasValidImage
                              ? Image.file(
                                  File(album.imagePath!),
                                  width: 220,
                                  height: 220,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.album, size: 160, color: Colors.white24),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          album.title,
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
                    final song = album.songs[index];
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
                              PlaySong(song, queue: album.songs),
                            );
                          },
                        ),
                        const Divider(color: Colors.white12, height: 1),
                      ],
                    );
                  },
                  childCount: album.songs.length,
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
