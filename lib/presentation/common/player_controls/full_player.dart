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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final player = AudioPlayerManager().player;

    player.onSongChanged = (newSong) {
      context.read<PlayerBloc>().add(PlaySong(newSong));
    };

    _controller.positionStream.listen((pos) {
      setState(() => _position = pos);
    });
    _controller.durationStream.listen((dur) {
      setState(() => _duration = dur ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    AudioPlayerManager().player.onSongChanged = null;
    super.dispose();
  }

  String _formatTime(Duration d) {
    return d.toString().split('.').first.substring(2, 7);
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
              final isPlaying = _controller.isPlaying;

              if (state is PlayerPlaying || state is PlayerPaused) {
                currentSong = (state as dynamic).song;
              }

              if (currentSong == null) {
                return const Center(child: Text("No song playing", style: TextStyle(color: Colors.white)));
              }

              final imagePath = File(currentSong.path).parent.listSync().firstWhere(
                (f) => f is File && ['.jpg', '.jpeg', '.png'].any((ext) => f.path.toLowerCase().endsWith(ext)),
                orElse: () => File(''),
              );
              final hasImage = imagePath is File && imagePath.existsSync();
              final queue = AudioPlayerManager().player.queue;

              // 🔥 Find the correct current index by matching song path
              final currentIndex = queue.indexWhere((s) => s.path == currentSong!.path);

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
                        Text(currentSong.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        Text(currentSong.artist, style: const TextStyle(fontSize: 18, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Progress bar
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
                            _controller.seekTo(Duration(milliseconds: value.toInt()));
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
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await AudioPlayerManager().player.previous();
                          setState(() => _isLoading = false);
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
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await AudioPlayerManager().player.next();
                          setState(() => _isLoading = false);
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

                  // Queue list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 12),
                    itemBuilder: (context, index) {
                      final qSong = queue[index];
                      final isCurrent = index == currentIndex;

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
                        onTap: () async {
                          setState(() => _isLoading = true);
                          final service = AudioPlayerManager().player;
                          service.setQueue(queue, startIndex: index);
                          await service.playCurrent();
                          context.read<PlayerBloc>().add(PlaySong(qSong));
                          setState(() => _isLoading = false);
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
