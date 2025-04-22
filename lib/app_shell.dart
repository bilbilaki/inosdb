// lib/app_shell.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:myapp/router.dart'; // Import your route definitions
import 'package:provider/provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/widgets/custom_side_drawer.dart';
import 'package:myapp/widgets/top_app_bar.dart';

// --- DrawerState Provider Remains the Same ---
class DrawerState extends ChangeNotifier {
  // ... (Keep your existing DrawerState code) ...
  bool isDrawerOpen = false; 
  bool isDragging = false;
  double _dragStartPosition = 0.0;
  double _dragUpdatePosition = 0.0;
  bool get _isDrawerOpen => isDrawerOpen;
  bool get _isDragging => isDragging;
  double get drawerOffset => _isDrawerOpen ? 0.0 : -_drawerWidth;

  double get slidePercentage {
    if (!_isDragging) return _isDrawerOpen ? 1.0 : 0.0;
    // ... (rest of the slidePercentage calculation) ...
    if (!_isDrawerOpen && _dragUpdatePosition > _dragStartPosition) {
      double delta = _dragUpdatePosition - _dragStartPosition;
      return (delta / _drawerWidth).clamp(0.0, 1.0);
    } else if (_isDrawerOpen && _dragUpdatePosition < _dragStartPosition) {
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
    isDrawerOpen = true;
    _resetDrag();
    notifyListeners();
  }

  void closeDrawer() {
    isDrawerOpen = false;
    _resetDrag();
    notifyListeners();
  }

  Future<void> toggleDrawer() async {
    _isDrawerOpen ? closeDrawer() : openDrawer();
  }

  void handleDragStart(DragStartDetails details) {
      if (!_isDrawerOpen && details.globalPosition.dx > 50) return;
      isDragging = true;
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
        if (dragDistance > _drawerWidth * 0.4 || velocity > 300) shouldOpen = true;
      } else {
        if (dragDistance < -_drawerWidth * 0.4 || velocity < -300) shouldOpen = false;
      }
      shouldOpen ? openDrawer() : closeDrawer();
  }

  void _resetDrag() {
      isDragging = false;
      _dragStartPosition = 0.0;
      _dragUpdatePosition = 0.0;
  }
}
// --- End of DrawerState ---


class AppShell extends StatelessWidget {
  final Widget child; // The screen content passed by GoRouter's ShellRoute

  const AppShell({required this.child, super.key});

  // --- Helper function to map current route to BottomNavBar index ---
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString(); // Use uri for full path
    // Alternative: GoRouterState.of(context).matchedLocation might be safer if using sub-routes often
    // final String location = GoRouterState.of(context).matchedLocation;

    // Define the mapping from route path to bottom nav index.
    // IMPORTANT: Use the indices your BottomNavBar expects (0, 1, 2, 3, 5 for display).
    if (location == AppRoutes.home) {
      return 0; // Home
    } else if (location == AppRoutes.tvSeries) {
      return 1; // TV Series
    } else if (location == AppRoutes.anime) {
      return 2; // Anime
    } else if (location == AppRoutes.genres) {
      return 3; // Genres
    }
    // Note: Index 4 is the 'Add/Shorts' button, it doesn't correspond to a shell route path.
    else if (location == AppRoutes.library) {
      return 5; // Library (maps to the 6th item in BottomNavBar, index 5)
    }
    return 0; // Default to Home if no match (or handle appropriately)
  }

  // --- Function to handle navigation triggered by BottomNavBar ---
  void _onItemTapped(int index, BuildContext context) {
    const int addButtonIndex = 4; // The index of the 'Add/Shorts' button

    switch (index) {
      case 0:
        context.go(AppRoutes.home); // Use context.go for ShellRoute navigation
        break;
      case 1:
        context.go(AppRoutes.tvSeries);
        break;
      case 2:
        context.go(AppRoutes.anime);
        break;
      case 3:
        context.go(AppRoutes.genres);
        break;
      case addButtonIndex: // Special case: Push the Shorts screen
        context.push(AppRoutes.shorts); // Use context.push to add to stack
        break;
      case 5:
        context.go(AppRoutes.library);
        break;
      default:
      // Optional: handle unexpected index
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer, GestureDetector and Stack structure remain the same
    return Consumer<DrawerState>(
      builder: (context, drawerState, _) { // Use '_' for unused child param
        final int currentIndex = _calculateSelectedIndex(context);

        return GestureDetector(
          onHorizontalDragStart: drawerState.handleDragStart,
          onHorizontalDragUpdate: drawerState.handleDragUpdate,
          onHorizontalDragEnd: drawerState.handleDragEnd,
          // Prevents GestureDetector from interfering with vertical scrolling inside child
          behavior: HitTestBehavior.translucent,
           // Ensure drag only works horizontally
          dragStartBehavior: DragStartBehavior.start,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.primaryBackground,
                appBar: TopAppBar(
                  onMenuPressed: drawerState.toggleDrawer, selectedIndex: 0,
                  // You might pass route info if needed: GoRouterState.of(context)
                ),
                // *** Use the 'child' passed from GoRouter instead of IndexedStack ***
                body: child,
                bottomNavigationBar: BottomNavBar(
                  currentIndex: currentIndex,
                  // Pass a closure that calls _onItemTapped with context
                  onTap: (index) => _onItemTapped(index, context),
                ),
              ),

              // --- Dark Overlay (No changes needed) ---
              if (drawerState.isDragging || drawerState.isDrawerOpen)
                GestureDetector(
                  onTap: drawerState.closeDrawer,
                  behavior: HitTestBehavior.translucent,
                  child: Opacity(
                    opacity: (drawerState.slidePercentage * 0.5).clamp(0.0, 0.5),
                    child: Container(color: Colors.black),
                  ),
                ),

              // --- Animated Drawer (No changes needed) ---
              AnimatedPositioned(
                duration: drawerState.isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: drawerState.currentOffsetBasedOnDrag,
                top: 0,
                bottom: 0,
                width: DrawerState._drawerWidth,
                child:  CustomSideDrawer(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper for DragStartBehavior if you don't have Flutter 3.x yet
// (Keep `import 'package:flutter/gestures.dart';` at the top)
// If you have Flutter 3.x or later, you can remove this and the
// `dragStartBehavior` property from GestureDetector above.
// Make sure to import: import 'package:flutter/gestures.dart';
// enum DragStartBehavior {
//   down,
//   start,
// }