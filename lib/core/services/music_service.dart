import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import 'dev_data_loader.dart';
import '../models/song_model.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';

class MusicService {
  final List<String> _audioExtensions = ['.mp3', '.flac', '.wav', '.aac', '.ogg'];
  final List<String> _imageExtensions = ['.jpg', '.jpeg', '.png'];
  static const String _firstRunKey = 'has_scanned_storage';

  final List<SongModel> _recentlyPlayed = [];

  void recordPlayed(SongModel song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 10) {
      _recentlyPlayed.removeLast();
    }
  }

  Future<List<SongModel>> getRecentlyPlayedSongs() async {
    return List.unmodifiable(_recentlyPlayed);
  }

  Future<List<SongModel>> fetchSongs({bool forceRefresh = false}) async {
    if (AppConfig.isDevMode) return DevDataLoader.getSongs();

    final prefs = await SharedPreferences.getInstance();
    final hasScannedBefore = prefs.getBool(_firstRunKey) ?? false;

    if (!hasScannedBefore || forceRefresh) {
      await _requestPermission();
      final directories = await _getRootDirectories();
      final files = await compute(_scanForAudioFiles, directories);

      if (!hasScannedBefore) await prefs.setBool(_firstRunKey, true);

      return files.map((file) {
        final filename = file.uri.pathSegments.last;
        return SongModel(
          id: file.path.hashCode.toString(),
          title: filename,
          artist: 'Unknown Artist',
          path: file.path,
        );
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<AlbumModel>> fetchAlbums({bool forceRefresh = false}) async {
    if (AppConfig.isDevMode) return DevDataLoader.getAlbums();

    final songs = await fetchSongs(forceRefresh: forceRefresh);
    final albums = <String, List<SongModel>>{};

    for (var song in songs) {
      final dir = File(song.path).parent.path;
      albums.putIfAbsent(dir, () => []).add(song);
    }

    return albums.entries.map((entry) {
      final folderName = entry.key.split(Platform.pathSeparator).last;
      final imagePath = _findAlbumArt(entry.key);
      return AlbumModel(
        id: entry.key.hashCode.toString(),
        title: folderName,
        imagePath: imagePath,
        songs: entry.value,
      );
    }).toList();
  }

  Future<List<ArtistModel>> fetchArtists({bool forceRefresh = false}) async {
    if (AppConfig.isDevMode) return DevDataLoader.getArtists();

    final songs = await fetchSongs(forceRefresh: forceRefresh);
    return [
      ArtistModel(
        id: '1',
        name: 'Local Files',
        imagePath: '',
        songs: songs,
      )
    ];
  }

  String _findAlbumArt(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) return '';

    final imageFile = dir
        .listSync()
        .whereType<File>()
        .firstWhere(
          (f) => _imageExtensions.any((ext) => f.path.toLowerCase().endsWith(ext)),
          orElse: () => File(''),
        );

    return imageFile.existsSync() ? imageFile.path : '';
  }

  Future<void> _requestPermission() async {
    final android13Plus = await Permission.audio.status;
    final legacy = await Permission.storage.status;
    final manage = await Permission.manageExternalStorage.status;

    if (!(android13Plus.isGranted || legacy.isGranted || manage.isGranted)) {
      final granted = await Permission.manageExternalStorage.request();
      if (!granted.isGranted) {
        throw Exception("Storage permission denied. Cannot read local music files.");
      }
    }
  }

  Future<List<Directory>> _getRootDirectories() async {
    final roots = <Directory>[];
    final pathsToCheck = [
      '/storage/emulated/0',
      '/storage/self/primary/Music',
      '/storage/self/primary/Download',
    ];

    for (final path in pathsToCheck) {
      final dir = Directory(path);
      if (await dir.exists()) roots.add(dir);
    }

    return roots;
  }
}

Future<List<File>> _scanForAudioFiles(List<Directory> dirs) async {
  final List<File> audioFiles = [];
  final extensions = ['.mp3', '.flac', '.wav', '.aac', '.ogg'];

  for (var dir in dirs) {
    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File &&
            extensions.any((ext) => entity.path.toLowerCase().endsWith(ext))) {
          audioFiles.add(entity);
        }
      }
    } catch (e) {
      continue;
    }
  }

  return audioFiles;
}
