import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';
import '../common/audio_player_controls.dart';
import '../../state/player_bloc/player_bloc.dart';
import '../../state/player_bloc/player_state.dart';

class MainScreen extends StatefulWidget {
  final bool isSidebarRight;

  const MainScreen({super.key, this.isSidebarRight = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool _showSidebar = false;
  bool _isSwipe = false;
  late AnimationController _animationController;
  Timer? _sidebarTimer;

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.library_music,
    Icons.person_outline,
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  bool get _isRight => widget.isSidebarRight;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _toggleSidebar([bool? forceOpen]) {
    setState(() {
      _showSidebar = forceOpen ?? !_showSidebar;

      if (_showSidebar) {
        _animationController.forward();
        _startSidebarAutoCloseTimer();
      } else {
        _animationController.reverse();
        _cancelSidebarAutoCloseTimer();
      }
    });
  }

  void _startSidebarAutoCloseTimer() {
    _cancelSidebarAutoCloseTimer();
    _sidebarTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _showSidebar) {
        _toggleSidebar(false);
      }
    });
  }

  void _cancelSidebarAutoCloseTimer() {
    _sidebarTimer?.cancel();
    _sidebarTimer = null;
  }

  void _onIconTap(int index) {
    _isSwipe = false;
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
    _toggleSidebar(false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _cancelSidebarAutoCloseTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isSwipe = true;
              }
              return false;
            },
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
                if (_isSwipe) {
                  _toggleSidebar(true);
                  _startSidebarAutoCloseTimer();
                }
              },
              children: _screens,
            ),
          ),

          // Sidebar gesture area
          Positioned(
            top: 0,
            bottom: 0,
            width: 20,
            left: _isRight ? null : 0,
            right: _isRight ? 0 : null,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                final dx = details.delta.dx;
                final swipeToOpen = _isRight ? dx < -5 : dx > 5;
                if (swipeToOpen && !_showSidebar) {
                  _toggleSidebar(true);
                }
              },
            ),
          ),

          // Grab handle
          Positioned(
            top: screenPadding + 40,
            left: _isRight ? null : 0,
            right: _isRight ? 0 : null,
            child: AnimatedOpacity(
              opacity: _showSidebar ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 10,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            left: _isRight ? null : (_showSidebar ? 0 : -70),
            right: _isRight ? (_showSidebar ? 0 : -70) : null,
            top: screenPadding + 20,
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: _isRight
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                boxShadow: _showSidebar
                    ? [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(2, 2))]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_icons.length, (index) {
                  final isSelected = index == _selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.greenAccent.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _icons[index],
                        color: isSelected ? Colors.greenAccent : Colors.white54,
                        size: isSelected ? 28 : 24,
                      ),
                      onPressed: () => _onIconTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Original: player only shown when state is PlayerPlaying or PlayerPaused
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                if (state is PlayerPlaying || state is PlayerPaused) {
                  return const AudioPlayerControls();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
