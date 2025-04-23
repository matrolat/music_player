import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool _showSidebar = false;
  late AnimationController _animationController;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  }

  void _toggleSidebar([bool? forceOpen]) {
    setState(() {
      _showSidebar = forceOpen ?? !_showSidebar;
      _showSidebar ? _animationController.forward() : _animationController.reverse();
    });
  }

  void _onIconTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
    _toggleSidebar(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: _screens,
          ),

          // 👇 Swipe gesture area (only on the left edge)
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 5 && !_showSidebar) {
                  _toggleSidebar(true);
                }
              },
            ),
          ),

          // 👇 Visual cue for swipe (grab handle)
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 0,
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

          // 👇 Sidebar container
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            left: _showSidebar ? 0 : -70,
            top: MediaQuery.of(context).padding.top + 20,
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: const BorderRadius.only(
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
                  return IconButton(
                    icon: Icon(
                      _icons[index],
                      color: isSelected ? Colors.greenAccent : Colors.white54,
                    ),
                    onPressed: () => _onIconTap(index),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
