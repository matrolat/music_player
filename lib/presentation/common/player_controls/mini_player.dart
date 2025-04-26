import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/models/song_model.dart';
import 'package:music_player/state/player_bloc/player_bloc.dart';
import 'package:music_player/state/player_bloc/player_event.dart';
import 'package:music_player/state/player_bloc/player_state.dart';
import 'full_player.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showThumb = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PlayerBloc>();

    bloc.player.positionStream.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);

        final dur = bloc.player.duration ?? Duration.zero;
        if (bloc.player.isPlaying &&
            dur.inMilliseconds > 0 &&
            (dur.inMilliseconds - pos.inMilliseconds).abs() <= 500) {
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

  void _seekTo(double value) {
    context.read<PlayerBloc>().add(
      SeekSong(Duration(milliseconds: value.toInt())),
    );
  }

  void _openFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const FullPlayer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        SongModel? song;
        bool isPlaying = false;

        if (state is PlayerPlaying) {
          song = state.song;
          isPlaying = true;
        } else if (state is PlayerPaused) {
          song = state.song;
          isPlaying = false;
        }

        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _openFullPlayer(context),
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -10) _openFullPlayer(context);
          },
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
                          ? const RoundSliderThumbShape(enabledThumbRadius: 8)
                          : const RoundSliderThumbShape(enabledThumbRadius: 0),
                    ),
                    child: Listener(
                      onPointerDown: (_) => setState(() => _showThumb = true),
                      onPointerUp: (_) => setState(() => _showThumb = false),
                      child: Slider(
                        value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
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
