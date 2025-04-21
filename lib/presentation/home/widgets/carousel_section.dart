import 'package:flutter/material.dart';

import '../../../core/models/song_model.dart';
import '../../../core/models/album_model.dart';
import '../../../core/models/artist_model.dart';
import 'album_card.dart';
import 'artist_card.dart';

class CarouselSection {
  static Widget songs(List<SongModel> songs) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final song = songs[index];
          return SizedBox(
            width: 140,
            child: Card(
              color: Colors.grey[900],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget albums(List<AlbumModel> albums) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: albums.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final album = albums[index];
          return SizedBox(
            width: 100,
            child: AlbumCard(album: album),
          );
        },
      ),
    );
  }

  static Widget artists(List<ArtistModel> artists) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: artists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return SizedBox(
            width: 100,
            child: ArtistCard(artist: artist),
          );
        },
      ),
    );
  }
}
