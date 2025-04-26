import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/state/player_bloc/player_bloc.dart';
import 'package:music_player/state/player_bloc/player_event.dart';
import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import '../../core/models/song_model.dart';
import 'album/album_detail_screen.dart';
import 'artist/artist_detail_screen.dart';
import '../common/player_controls/mini_player.dart'; // Make sure import path is correct

class SeeAllScreen<T> extends StatelessWidget {
  final String title;
  final List<T> items;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.items,
  });

  bool _areSongsSame(song1, song2) {
    return song1.id == song2.id && song1.title == song2.title;
  }

  @override
  Widget build(BuildContext context) {
    final isSongList = T == SongModel;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text("No items found", style: TextStyle(color: Colors.white54)),
                  )
                : isSongList
                    ? _buildSongList(context)
                    : _buildGrid(context),
          ),

          // 👇 MiniPlayer at bottom
          const MiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildSongList(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 12),
      itemBuilder: (context, index) {
        final song = items[index] as SongModel;
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const Icon(Icons.music_note, color: Colors.white),
          title: Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
          onTap: () {
            context.read<PlayerBloc>().add(
              PlaySong(song, queue: items.cast<SongModel>()),
            );
          },
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        String label = '';
        String imagePath = '';
        int songCount = 0;
        Widget? destination;

        if (item is AlbumModel) {
          label = item.title;
          imagePath = item.imagePath;
          songCount = item.songs.length;
          destination = AlbumDetailScreen(album: item);
        } else if (item is ArtistModel) {
          label = item.name;
          imagePath = item.imagePath;
          songCount = item.songs.length;
          destination = ArtistDetailScreen(artist: item);
        }

        final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();
        final imageProvider = hasImage
            ? FileImage(File(imagePath))
            : AssetImage(item is AlbumModel
                ? 'assets/images/album.png'
                : 'assets/images/artist.png') as ImageProvider;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (destination != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => destination!));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(image: imageProvider, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$songCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
