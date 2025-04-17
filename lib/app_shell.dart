// lib/app_shell.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/shorts_screen.dart';
import 'package:myapp/screens/tv_series_grid_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/library_screen.dart';
import 'package:myapp/screens/subscriptions_screen.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/widgets/custom_side_drawer.dart';
import 'package:myapp/widgets/top_app_bar.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
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
  int _selectedIndex = 0; // Index for the _screens list

  // Define the index of the special action button in your BottomNavBar
  static const int addButtonIndex = 4; // Assuming 'Add' is the 5th item (index 4)

  // Screens managed by the IndexedStack and BottomNavBar switching
  // NOTE: Exclude ShortsScreen here if it's pushed modally by the Add button
  final List<Widget> _screens = const [
    HomeScreen(),           // Corresponds to BottomNavBar index 0 -> _selectedIndex 0
    TvSeriesGridScreen(),   // Corresponds to BottomNavBar index 1 -> _selectedIndex 1
    AnimeGridScreen(),      // Corresponds to BottomNavBar index 2 -> _selectedIndex 2
    SubscriptionsScreen(),  // Corresponds to BottomNavBar index 3 -> _selectedIndex 3
    LibraryScreen(),        // Corresponds to BottomNavBar index 5 -> _selectedIndex 4
    // Removed ShortsScreen from this list
  ];

  void _onItemTapped(int index) { // index is the tapped index in BottomNavBar
    if (index == addButtonIndex) {
      // Handle the "Add" button action (e.g., show modal or navigate)
      // This doesn't change the main selected tab (_selectedIndex)
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ShortsScreen()));
    } else {
      // Calculate the corresponding index for the _screens list
      int newScreenIndex;
      if (index < addButtonIndex) {
        // Indices before the add button map directly
        newScreenIndex = index;
      } else {
        // Indices after the add button need to be shifted down by 1
        // because the _screens list doesn't have an entry for the add button.
        newScreenIndex = index - 1;
      }

      // Only update state if the index actually changes
      if (newScreenIndex != _selectedIndex) {
          setState(() {
            _selectedIndex = newScreenIndex;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to react to DrawerState changes
    return Consumer<DrawerState>(
      builder: (context, drawerState, child) {
        // Calculate the index to highlight in the BottomNavBar
        int bottomNavHighlightIndex;
        if (_selectedIndex < addButtonIndex) {
           // If current screen index is before the add button gap, it's a direct match
           bottomNavHighlightIndex = _selectedIndex;
        } else {
           // If current screen index is after the add button gap,
           // add 1 to get the corresponding BottomNavBar index.
           bottomNavHighlightIndex = _selectedIndex + 1;
        }

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
                  selectedIndex: _selectedIndex, // You might want to pass the screen index
                ),
                body: IndexedStack(
                  // Keep state of inactive screens
                  index: _selectedIndex, // Use the calculated screen index
                  children: _screens,   // Use the adjusted _screens list
                ),
                bottomNavigationBar: BottomNavBar(
                  currentIndex: bottomNavHighlightIndex, // Use the calculated highlight index
                  onTap: _onItemTapped,
                ),
              ),

              // --- Dark Overlay (Optional but recommended) ---
              if (drawerState.isDragging || drawerState.isDrawerOpen)
                 GestureDetector(
                    onTap: drawerState.closeDrawer, // Tap outside drawer to close
                    // Absorb pointer prevents taps passing through the overlay
                    // while still allowing the drawer's gestures.
                    behavior: HitTestBehavior.translucent,
                     child: Opacity(
                        opacity: (drawerState.slidePercentage * 0.5).clamp(0.0, 0.5), // Control fade
                        child: Container(
                        color: Colors.black,
                         ),
                     ),
                 ),


              // --- Animated Drawer ---
               // Use AnimatedPositioned or Transform.translate based on drag state for smoother interaction
              AnimatedPositioned(
                 duration: drawerState.isDragging
                     ? Duration.zero // No animation during drag
                     : const Duration(milliseconds: 250), // Animate when snapping open/closed
                 curve: Curves.easeInOut,
                 left: drawerState.currentOffsetBasedOnDrag, // Use offset based on drag/state
                 top: 0,
                 bottom: 0,
                 width: DrawerState._drawerWidth, // Ensure width is set
                 child: const CustomSideDrawer(),
               ),
            ],
          ),
        );
      },
    );
  }
}