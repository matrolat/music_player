import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/artist_model.dart';

class ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final hasImage = artist.imagePath.isNotEmpty && File(artist.imagePath).existsSync();
    final imageWidget = hasImage
        ? Image.file(File(artist.imagePath), width: 80, height: 80, fit: BoxFit.cover)
        : Image.asset('assets/images/artist.png', width: 80, height: 80, fit: BoxFit.cover);

    return Card(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageWidget,
          const SizedBox(height: 8),
          Text(artist.name, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
