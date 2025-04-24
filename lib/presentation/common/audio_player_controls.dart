import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/audio_player/audio_player_manager.dart';
import '../../core/models/song_model.dart';
import '../../state/player_bloc/player_bloc.dart';
import '../../state/player_bloc/player_event.dart';
import '../../state/player_bloc/player_state.dart';

class AudioPlayerControls extends StatefulWidget {
  const AudioPlayerControls({super.key});

  @override
  State<AudioPlayerControls> createState() => _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<AudioPlayerControls> {
  final _player = AudioPlayerManager().player;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showThumb = false;

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((pos) {
      setState(() => _currentPosition = pos);
    });

    _player.durationStream.listen((dur) {
      setState(() => _duration = dur ?? Duration.zero);
    });
  }

  void _seekTo(double value) {
    final position = Duration(milliseconds: value.toInt());
    context.read<PlayerBloc>().add(SeekSong(position));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        SongModel? song;
        bool isPlaying = _player.isPlaying;

        if (state is PlayerPlaying || state is PlayerPaused) {
          song = (state as dynamic).song;
        }

        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity > 0) {
              context.read<PlayerBloc>().add(PlayPrevious());
            } else if (velocity < 0) {
              context.read<PlayerBloc>().add(PlayNext());
            }
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.only(top: 13),
                decoration: const BoxDecoration(
                  color: Color(0xFF121212),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        size: 36,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          context.read<PlayerBloc>().add(PauseSong());
                        } else {
                          context.read<PlayerBloc>().add(PlaySong(song!));
                        }
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  alignment: Alignment.center,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: const Color(0xFF1DB954),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF1DB954),
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: _showThumb
                          ? const RoundSliderThumbShape(enabledThumbRadius: 10)
                          : const RoundSliderThumbShape(enabledThumbRadius: 0),
                    ),
                    child: Listener(
                      onPointerDown: (_) => setState(() => _showThumb = true),
                      onPointerUp: (_) => setState(() => _showThumb = false),
                      child: Slider(
                        value: _currentPosition.inMilliseconds
                            .clamp(0, _duration.inMilliseconds)
                            .toDouble(),
                        max: _duration.inMilliseconds.toDouble(),
                        onChanged: _seekTo,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
