import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'add_edit_spot_screen.dart';
import 'home_discovery_screen.dart';
import 'journal_profile_screen.dart';
import 'visited_wishlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<State> _homeKey = GlobalKey();
  final GlobalKey<State> _visitedKey = GlobalKey();

  Future<void> _openAddSpotModal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditSpotScreen()),
    );
    if (result != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDiscoveryScreen(
        key: _homeKey,
        onNavigateToProfile: () => setState(() => _currentIndex = 2),
      ),
      VisitedWishlistScreen(key: _visitedKey),
      const JournalProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFEFEAE4), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Discover Tab
                _buildNavItem(
                  index: 0,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: "Discover",
                ),

                // 2. Wishlist & Visited Tab
                _buildNavItem(
                  index: 1,
                  icon: Icons.bookmark_border,
                  activeIcon: Icons.bookmark,
                  label: "Wishlist",
                ),

                // 3. Center Elevated Quick Log Button
                GestureDetector(
                  onTap: _openAddSpotModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "Log",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Journal / Profile Tab
                _buildNavItem(
                  index: 2,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories,
                  label: "Journal",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondaryContainer.withValues(alpha: 0.6) : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primary : AppColors.outline,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
