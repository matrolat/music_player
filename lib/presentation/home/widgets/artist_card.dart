import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/presentation/home/artist/artist_detail_screen.dart';
import '../../../core/models/artist_model.dart';
class ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final hasImage = artist.imagePath.isNotEmpty && File(artist.imagePath).existsSync();

    final imageWidget = hasImage
        ? Image.file(
            File(artist.imagePath),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          )
        : Image.asset(
            'assets/images/artist.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistDetailScreen(artist: artist),
          ),
        );
      },
      child: Card(
        color: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: imageWidget,
              ),
              const SizedBox(height: 8),
              Text(
                artist.name,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
