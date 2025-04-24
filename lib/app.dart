import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/music_service.dart';
import 'state/music_bloc/music_bloc.dart';
import 'state/music_bloc/music_event.dart';
import 'state/player_bloc/player_bloc.dart';
import 'presentation/main/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MusicBloc(MusicService())..add(LoadMusicEvent())),
        BlocProvider(create: (_) => PlayerBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const MainScreen(isSidebarRight: true), // ← updated
      ),
    );
  }
}
