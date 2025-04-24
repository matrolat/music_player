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
        ? Image.file(
            File(album.imagePath),
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          )
        : Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[850],
            child: const Center(
              child: Icon(
                Icons.album,
                size: 40,
                color: Colors.white30,
              ),
            ),
          );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumDetailScreen(album: album),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Card(
              margin: EdgeInsets.zero,
              color: const Color.fromARGB(62, 33, 33, 33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: imageWidget,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              album.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
