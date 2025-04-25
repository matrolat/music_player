import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/presentation/common/player_controls/mini_player.dart';
import '../../../core/models/album_model.dart';
import '../../../config/app_config.dart';
import '../../../state/player_bloc/player_bloc.dart';
import '../../../state/player_bloc/player_event.dart';
import '../../common/audio_player_controls.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final hasValidImage =
        (album.imagePath?.isNotEmpty ?? false) && File(album.imagePath!).existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(album.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Album image or fallback icon
          hasValidImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(album.imagePath!),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.album,
                  size: 150,
                  color: Colors.grey,
                ),

          const SizedBox(height: 12),
          Text(
            album.title,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Song list
          Expanded(
            child: ListView.builder(
              itemCount: album.songs.length,
              itemBuilder: (context, index) {
                final song = album.songs[index];
                final isDev = AppConfig.isDevMode;

                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.white),
                  title: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    final songToPlay = isDev
                        ? song.copyWith(path: 'assets/audio/sample.mp3')
                        : song;

                    context.read<PlayerBloc>().add(PlaySong(songToPlay));
                  },
                );
              },
            ),
          ),

          // const AudioPlayerControls(),
          MiniPlayer(),
        ],
      ),
    );
  }
}
