import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/presentation/home/album/album_detail_screen.dart';
import 'package:music_player/presentation/home/artist/artist_detail_screen.dart';
import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';
import '../../core/models/song_model.dart';
import '../../state/player_bloc/player_bloc.dart';
import '../../state/player_bloc/player_event.dart';
import '../../state/search_data_bloc/search_data_bloc.dart';


enum SearchFilter { all, songs, albums, artists }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchFilter _activeFilter = SearchFilter.all;
  String _searchQuery = '';

  final Map<SearchFilter, String> _filterLabels = {
    SearchFilter.all: 'All',
    SearchFilter.songs: 'Songs',
    SearchFilter.albums: 'Albums',
    SearchFilter.artists: 'Artists',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: BlocBuilder<SearchDataBloc, SearchDataState>(
        builder: (context, state) {
          if (state is SearchDataLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchDataError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (state is SearchDataLoaded) {
            return _buildSearchUI(context, state.songs, state.albums, state.artists);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchUI(
    BuildContext context,
    List<SongModel> songs,
    List<AlbumModel> albums,
    List<ArtistModel> artists,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    final filteredSongs = songs.where((song) {
      final title = song.title.trim().toLowerCase();
      final artist = song.artist.trim().toLowerCase();
      return title.contains(query) || artist.contains(query);
    }).toList();

    final filteredAlbums = albums.where((album) {
      final title = album.title.trim().toLowerCase();
      return title.contains(query);
    }).toList();

    final filteredArtists = artists.where((artist) {
      final name = artist.name.trim().toLowerCase();
      return name.contains(query);
    }).toList();

    final List<dynamic> results = switch (_activeFilter) {
      SearchFilter.songs => filteredSongs,
      SearchFilter.albums => filteredAlbums,
      SearchFilter.artists => filteredArtists,
      SearchFilter.all => [...filteredSongs, ...filteredAlbums, ...filteredArtists],
    };

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search songs, albums, artists...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[900],
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filterLabels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final filter = _filterLabels.keys.elementAt(index);
              final label = _filterLabels[filter]!;
              final isSelected = _activeFilter == filter;

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => setState(() => _activeFilter = filter),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                selectedColor: const Color(0xFF1DB954),
                backgroundColor: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Results
        Expanded(
          child: _searchQuery.isEmpty
              ? const Center(
                  child: Text('Start typing to search...',
                      style: TextStyle(color: Colors.white38)),
                )
              : results.isEmpty
                  ? const Center(
                      child: Text('No results found',
                          style: TextStyle(color: Colors.white38)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = results[index];

                        if (item is SongModel) {
                          return ListTile(
                            tileColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: const Icon(Icons.music_note, color: Colors.white),
                            title: Text(item.title,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(item.artist,
                                style: const TextStyle(color: Colors.white54)),
                            onTap: () {
                              context.read<PlayerBloc>().add(PlaySong(item));
                            },
                          );
                        }

                        if (item is AlbumModel) {
                          final hasImage = item.imagePath.isNotEmpty &&
                              File(item.imagePath).existsSync();
                          final imageProvider = hasImage
                              ? FileImage(File(item.imagePath))
                              : const AssetImage('assets/images/album.png');

                          return ListTile(
                            tileColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image(
                                image: imageProvider as ImageProvider,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(item.title,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text('${item.songs.length} songs',
                                style: const TextStyle(color: Colors.white54)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlbumDetailScreen(album: item),
                                ),
                              );
                            },
                          );
                        }

                        if (item is ArtistModel) {
                          final hasImage = item.imagePath.isNotEmpty &&
                              File(item.imagePath).existsSync();
                          final imageProvider = hasImage
                              ? FileImage(File(item.imagePath))
                              : const AssetImage('assets/images/artist.png');

                          return ListTile(
                            tileColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: imageProvider as ImageProvider,
                              radius: 24,
                            ),
                            title: Text(item.name,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text('${item.songs.length} songs',
                                style: const TextStyle(color: Colors.white54)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArtistDetailScreen(artist: item),
                                ),
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
        ),
      ],
    );
  }
}
