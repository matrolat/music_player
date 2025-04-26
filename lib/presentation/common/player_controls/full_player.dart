import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/models/song_model.dart';
import 'package:music_player/state/player_bloc/player_bloc.dart';
import 'package:music_player/state/player_bloc/player_event.dart';
import 'package:music_player/state/player_bloc/player_state.dart';

class FullPlayer extends StatefulWidget {
  const FullPlayer({super.key});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

@override
void initState() {
  super.initState();
  final bloc = context.read<PlayerBloc>();

  bloc.player.positionStream.listen((pos) {
    if (mounted) {
      setState(() => _position = pos);

      final dur = bloc.player.duration ?? Duration.zero;
      if (dur.inMilliseconds > 0 &&
          (dur.inMilliseconds - pos.inMilliseconds).abs() <= 500) { // 500ms margin
        // 🔥 Song is about to end naturally
        context.read<PlayerBloc>().add(PlayNext());
      }
    }
  });

  bloc.player.durationStream.listen((dur) {
    if (mounted) {
      setState(() => _duration = dur ?? Duration.zero);
    }
  });
}

  String _formatTime(Duration d) {
    return d.toString().split('.').first.substring(2, 7);
  }

  bool _areSongsSame(SongModel a, SongModel b) {
    return a.id == b.id && a.title == b.title && a.artist == b.artist && a.path == b.path;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      maxChildSize: 1.0,
      minChildSize: 0.7,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, state) {
              SongModel? currentSong;
              bool isPlaying = false;
              final bloc = context.read<PlayerBloc>();

              if (state is PlayerPlaying) {
                currentSong = state.song;
                isPlaying = true;
              } else if (state is PlayerPaused) {
                currentSong = state.song;
                isPlaying = false;
              }

              if (currentSong == null) {
                return const Center(
                  child: Text("No song playing", style: TextStyle(color: Colors.white)),
                );
              }

              final queue = bloc.player.queue;
              final imagePath = File(currentSong.path).parent.listSync().firstWhere(
                (f) => f is File && ['.jpg', '.jpeg', '.png'].any((ext) => f.path.toLowerCase().endsWith(ext)),
                orElse: () => File(''),
              );
              final hasImage = imagePath is File && imagePath.existsSync();

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 30),

                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasImage
                      ? Image.file(imagePath, height: MediaQuery.of(context).size.height * 0.42, fit: BoxFit.cover)
                      : Image.asset('assets/images/album.png', height: MediaQuery.of(context).size.height * 0.42),
                  ),
                  const SizedBox(height: 36),

                  // Song Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          currentSong.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentSong.artist,
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Progress Bar
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(_formatTime(_position), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          const Spacer(),
                          Text(_formatTime(_duration), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: Colors.greenAccent,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.greenAccent,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                          max: _duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            context.read<PlayerBloc>().add(
                              SeekSong(Duration(milliseconds: value.toInt())),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<PlayerBloc>().add(PlayPrevious());
                        },
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                      ),
                      _isLoading
                          ? const SizedBox(
                              height: 56,
                              width: 56,
                              child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
                            )
                          : IconButton(
                              onPressed: () {
                                if (isPlaying) {
                                  context.read<PlayerBloc>().add(PauseSong());
                                } else {
                                  context.read<PlayerBloc>().add(PlaySong(currentSong!));
                                }
                              },
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                      IconButton(
                        onPressed: () {
                          context.read<PlayerBloc>().add(PlayNext());
                        },
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Up Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.keyboard_arrow_up, color: Colors.white54, size: 24),
                      SizedBox(width: 8),
                      Text("Up Next", style: TextStyle(color: Colors.white54, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Queue
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 12),
                    itemBuilder: (context, index) {
                      final qSong = queue[index];
                      final isCurrent = _areSongsSame(qSong, currentSong!);

                      return ListTile(
                        tileColor: isCurrent ? Colors.white10 : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        dense: true,
                        title: Text(
                          qSong.title,
                          style: TextStyle(
                            color: isCurrent ? Colors.greenAccent : Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          qSong.artist,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          context.read<PlayerBloc>().add(PlaySong(qSong));
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
