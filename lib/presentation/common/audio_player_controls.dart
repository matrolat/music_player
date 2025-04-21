// 📁 presentation/common/audio_player_controls.dart (Improved UI + fix default song)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as audio;
import '../../state/player_bloc/player_bloc.dart';
import '../../state/player_bloc/player_event.dart';
import '../../state/player_bloc/player_state.dart';
import '../../core/audio_player/audio_player_manager.dart';

class AudioPlayerControls extends StatefulWidget {
  const AudioPlayerControls({super.key});

  @override
  State<AudioPlayerControls> createState() => _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<AudioPlayerControls> {
  final _player = AudioPlayerManager().player;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final isPlaying = state is PlayerPlaying;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: _duration.inMilliseconds > 0
                          ? _currentPosition.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble()
                          : 0.0,
                      max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                      onChanged: (value) {
                        final pos = Duration(milliseconds: value.toInt());
                        context.read<PlayerBloc>().add(SeekSong(pos));
                      },
                      activeColor: Colors.greenAccent,
                      inactiveColor: Colors.white30,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: () {
                      context.read<PlayerBloc>().add(PlayPrevious());
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      size: 48,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        context.read<PlayerBloc>().add(PauseSong());
                      } else {
                        // Do not play hardcoded file here; state should hold the song
                        // You may want to handle "resume" differently if desired
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () {
                      context.read<PlayerBloc>().add(PlayNext());
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}