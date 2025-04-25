import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/audio_player/audio_player_manager.dart';
import 'package:music_player/core/models/song_model.dart';
import 'package:music_player/state/player_bloc/player_bloc.dart';
import 'package:music_player/state/player_bloc/player_event.dart';
import 'package:music_player/state/player_bloc/player_state.dart';
import 'player_controller.dart';

class FullPlayer extends StatefulWidget {
  const FullPlayer({super.key});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  final _controller = PlayerController();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller.positionStream.listen((pos) {
      setState(() => _position = pos);
    });
    _controller.durationStream.listen((dur) {
      setState(() => _duration = dur ?? Duration.zero);
    });
  }

  String _formatTime(Duration d) {
    return d.toString().split('.').first.substring(2, 7);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.98,
      maxChildSize: 1.0,
      minChildSize: 0.7,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, state) {
              SongModel? song;
              final isPlaying = _controller.isPlaying;

              if (state is PlayerPlaying || state is PlayerPaused) {
                song = (state as dynamic).song;
              }

              if (song == null) {
                return const Center(
                  child: Text("No song playing", style: TextStyle(color: Colors.white)),
                );
              }

              final imagePath = File(song.path).parent.listSync().firstWhere(
                    (f) =>
                        f is File &&
                        ['.jpg', '.jpeg', '.png'].any((ext) => f.path.toLowerCase().endsWith(ext)),
                    orElse: () => File(''),
                  );

              final hasImage = imagePath is File && imagePath.existsSync();

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 0),

                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: hasImage
                        ? Image.file(imagePath, height: MediaQuery.of(context).size.height * 0.45, fit: BoxFit.cover)
                        : Image.asset('assets/images/album.png', height: MediaQuery.of(context).size.height * 0.45),
                  ),

                  // Song Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Progress bar
                      Row(
                        children: [
                          Text(_formatTime(_position), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const Spacer(),
                          Text(_formatTime(_duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: Colors.greenAccent,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.greenAccent,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                          max: _duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            _controller.seekTo(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),
                    ],
                  ),

                  // Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () => context.read<PlayerBloc>().add(PlayPrevious()),
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              context.read<PlayerBloc>().add(PauseSong());
                            } else {
                              context.read<PlayerBloc>().add(PlaySong(song!));
                            }
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.read<PlayerBloc>().add(PlayNext()),
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
