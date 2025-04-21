import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(album.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Image.asset(album.imagePath, width: 150, height: 150),
          const SizedBox(height: 12),
          Text(album.title, style: const TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: album.songs.length,
              itemBuilder: (context, index) {
                final song = album.songs[index];
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.white),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
                  onTap: () {
                    final path = AppConfig.isDevMode
                        ? 'assets/audio/sample.mp3'
                        : song.path;

                    context.read<PlayerBloc>().add(PlaySong(path));
                  },
                );
              },
            ),
          ),

          const AudioPlayerControls(),
        ],
      ),
    );
  }
}
