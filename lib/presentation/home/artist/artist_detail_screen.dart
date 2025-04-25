import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/audio_player/audio_player_manager.dart';
import 'package:music_player/presentation/common/player_controls/mini_player.dart';
import '../../../core/models/artist_model.dart';
import '../../../config/app_config.dart';
import '../../../state/player_bloc/player_bloc.dart';
import '../../../state/player_bloc/player_event.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(artist.name, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[800],
            backgroundImage: (artist.imagePath?.isNotEmpty ?? false)
                ? FileImage(File(artist.imagePath!))
                : null,
            child: (artist.imagePath?.isEmpty ?? true)
                ? const Icon(Icons.person, color: Colors.white30, size: 60)
                : null,
          ),

          const SizedBox(height: 12),
          Text(artist.name, style: const TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: artist.songs.length,
              itemBuilder: (context, index) {
                final song = artist.songs[index];
                final isDev = AppConfig.isDevMode;

                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.white),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
                             onTap: () async {
  final songs = artist.songs; // or artist.songs
  final clickedIndex = songs.indexOf(song);
  final playerService = AudioPlayerManager().player;

  // 1. Set new queue
  playerService.setQueue(songs, startIndex: clickedIndex);

  // 2. Play selected song
  await playerService.playCurrent();

  // 3. Notify Bloc about current song
  context.read<PlayerBloc>().add(PlaySong(songs[clickedIndex]));
}
                );
              },
            ),
          ),

          const MiniPlayer(),
        ],
      ),
    );
  }
}
