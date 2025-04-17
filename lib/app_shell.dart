// lib/app_shell.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/tv_series_grid_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/screens/create_post_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/library_screen.dart';
import 'package:myapp/screens/shorts_screen.dart';
import 'package:myapp/screens/subscriptions_screen.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/widgets/custom_side_drawer.dart';
import 'package:myapp/widgets/top_app_bar.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
import 'package:myapp/screens/yt-dlp_screen.dart';
// Use MovieCard
// Use TvSeriesCard
// Use StatusBar
// Use ChipBar
// Use VideoCard
// For dynamic background

// Provider state for drawer
class DrawerState extends ChangeNotifier {
  bool _isDrawerOpen = false;
  bool _isDragging = false;
  double _dragStartPosition = 0.0;
  double _dragUpdatePosition = 0.0;

  bool get isDrawerOpen => _isDrawerOpen;
  bool get isDragging => _isDragging;

  double get drawerOffset => _isDrawerOpen ? 0.0 : -_drawerWidth;

  double get slidePercentage {
    if (!_isDragging) return _isDrawerOpen ? 1.0 : 0.0;

    if (!_isDrawerOpen && _dragUpdatePosition > _dragStartPosition) {
      // Opening
      double delta = _dragUpdatePosition - _dragStartPosition;
      return (delta / _drawerWidth).clamp(0.0, 1.0);
    } else if (_isDrawerOpen && _dragUpdatePosition < _dragStartPosition) {
      // Closing
      double delta = _dragStartPosition - _dragUpdatePosition;
      return (1.0 - (delta / _drawerWidth)).clamp(0.0, 1.0);
    }
    return _isDrawerOpen ? 1.0 : 0.0;
  }

  double get currentOffsetBasedOnDrag {
    if (!_isDragging) return drawerOffset;
    return -_drawerWidth * (1.0 - slidePercentage);
  }

  static const double _drawerWidth = 280.0;

  void openDrawer() {
    _isDrawerOpen = true;
    _resetDrag();
    notifyListeners();
  }

  void closeDrawer() {
    _isDrawerOpen = false;
    _resetDrag();
    notifyListeners();
  }

  void toggleDrawer() {
    _isDrawerOpen ? closeDrawer() : openDrawer();
  }

  void handleDragStart(DragStartDetails details) {
    // Allow drag from edge when closed or anywhere when open
    if (!_isDrawerOpen && details.globalPosition.dx > 50) {
      return;
    }

    _isDragging = true;
    _dragStartPosition = details.globalPosition.dx;
    _dragUpdatePosition = _dragStartPosition;
    notifyListeners();
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    _dragUpdatePosition = details.globalPosition.dx;
    notifyListeners();
  }

  void handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final dragDistance = _dragUpdatePosition - _dragStartPosition;
    final velocity = details.primaryVelocity ?? 0.0;

    bool shouldOpen = _isDrawerOpen;

    if (!_isDrawerOpen) {
      if (dragDistance > _drawerWidth * 0.4 || velocity > 300) {
        shouldOpen = true;
      }
    } else {
      if (dragDistance < -_drawerWidth * 0.4 || velocity < -300) {
        shouldOpen = false;
      }
    }

    if (shouldOpen) {
      openDrawer();
    } else {
      closeDrawer();
    }
  }

  void _resetDrag() {
    _isDragging = false;
    _dragStartPosition = 0.0;
    _dragUpdatePosition = 0.0;
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TvSeriesGridScreen(),
    AnimeGridScreen(),
  //  ShortsScreen(),
  //  SizedBox.shrink(), // Placeholder for Add button action
//YtdlpConfigScreen(),
    SubscriptionsScreen(),
    LibraryScreen(),
  ];

  void _onItemTapped(int index) {
  //  if (index == 3) {
      // Handle the "Add" button action (e.g., show modal or navigate)
    //  Navigator.push(
      //    context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
    // } else {
      setState(() {
        // Adjust index for screen list if middle button is tapped
        _selectedIndex = index > 2 ? index - 1 : index;
      });
    //}
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to react to DrawerState changes
    return Consumer<DrawerState>(
      builder: (context, drawerState, child) {
        return GestureDetector(
          // *** Add Gesture Detection for Custom Drawer ***
          onHorizontalDragStart: drawerState.handleDragStart,
          onHorizontalDragUpdate: drawerState.handleDragUpdate,
          onHorizontalDragEnd: drawerState.handleDragEnd,
          child: Stack(
            children: [
              // --- Main Content ---
              Scaffold(
                backgroundColor: AppColors.primaryBackground,
                appBar: TopAppBar(
                  // Pass the toggle function to the AppBar button
                  onMenuPressed: drawerState.toggleDrawer,
                ),
                body: IndexedStack(
                  // Keep state of inactive screens
                  index: _selectedIndex,
                  children: _screens
                      .where((s) => s is! SizedBox)
                      .toList(), // Exclude placeholder
                ),
                bottomNavigationBar: BottomNavBar(
                  currentIndex: _selectedIndex > 1
                      ? _selectedIndex + 1
                      : _selectedIndex, // Map screen index back to nav bar index
                  onTap: _onItemTapped,
                ),
              ),

              /*    // --- Dark Overlay when Drawer is Open ---
              if (drawerState.isDrawerOpen || drawerState.slidePercentage > 0)
                GestureDetector(
                  onTap: drawerState.closeDrawer, // Tap outside drawer to close
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.5 * drawerState.slidePercentage),
                  ),
                ),
*/
              // --- Animated Drawer ---
              AnimatedPositioned(
                duration: drawerState._dragStartPosition >= 0
                    ? Duration.zero // No animation during drag
                    : const Duration(
                        milliseconds: 250), // Animate when snapping open/closed
                curve: Curves.easeInOut,
                left: drawerState.isDrawerOpen
                    ? 0
                    : -DrawerState._drawerWidth, // Use isDrawerOpen state
                top: 0,
                bottom: 0,
                child: const CustomSideDrawer(),
              ),
            ],
          ),
        );
      },
    );
  }
}
