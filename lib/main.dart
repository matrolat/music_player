import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/music_service.dart';
import 'presentation/home/home_screen.dart';
import 'state/music_bloc/music_bloc.dart';
import 'state/music_bloc/music_event.dart';
import 'state/player_bloc/player_bloc.dart';
import 'app.dart';

void main() {
  runApp(const MyApp());
}
