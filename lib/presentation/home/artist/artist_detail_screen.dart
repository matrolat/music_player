import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/artist_model.dart';
import '../../../state/player_bloc/player_bloc.dart';
import '../../../state/player_bloc/player_event.dart';
import '../../common/player_controls/mini_player.dart'; // Make sure path is correct

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
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.white),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
                  onTap: () {
                    context.read<PlayerBloc>().add(
                      PlaySong(song, queue: artist.songs, startIndex: index),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ MiniPlayer here to show
          const MiniPlayer(),
        ],
      ),
    );
  }
}
