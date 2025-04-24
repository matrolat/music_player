import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/album_model.dart';
import '../album/album_detail_screen.dart';

class AlbumCard extends StatelessWidget {
  final AlbumModel album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final hasImage = album.imagePath.isNotEmpty && File(album.imagePath).existsSync();
    final imageWidget = hasImage
        ? Image.file(File(album.imagePath), width: 80, height: 80, fit: BoxFit.cover)
        : Image.asset('assets/images/album.png', width: 80, height: 80, fit: BoxFit.cover);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumDetailScreen(album: album),
          ),
        );
      },
      child: Card(
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageWidget,
            const SizedBox(height: 8),
            Text(album.title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
