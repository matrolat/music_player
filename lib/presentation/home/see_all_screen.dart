import 'package:flutter/material.dart';
import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import '../../core/models/song_model.dart';

class SeeAllScreen<T> extends StatelessWidget {
  final String title;
  final List<T> items;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item is SongModel) {
            return ListTile(
              title: Text(item.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(item.artist, style: const TextStyle(color: Colors.grey)),
              onTap: () {}, // play song
            );
          }

          if (item is AlbumModel) {
            return ListTile(
              leading: Image.asset(item.imagePath, width: 40, height: 40),
              title: Text(item.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text('${item.songs.length} songs', style: const TextStyle(color: Colors.grey)),
            );
          }

          if (item is ArtistModel) {
            return ListTile(
              leading: Image.asset(item.imagePath, width: 40, height: 40),
              title: Text(item.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text('${item.songs.length} songs', style: const TextStyle(color: Colors.grey)),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
