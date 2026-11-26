import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cafe_spot.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_spot_screen.dart';
import 'spot_detail_screen.dart';

class HomeDiscoveryScreen extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const HomeDiscoveryScreen({super.key, required this.onNavigateToProfile});

  @override
  State<HomeDiscoveryScreen> createState() => _HomeDiscoveryScreenState();
}

class _HomeDiscoveryScreenState extends State<HomeDiscoveryScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<CafeSpot> _allSpots = [];
  List<CafeSpot> _filteredSpots = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = 'All Spots';

  final List<String> _filters = [
    'All Spots',
    'Bandung',
    'Jakarta',
    'Depok',
    'Visited',
    'Wishlist',
    'Coffee Shop',
    'Artisan Bakery',
    'Resto / Dining',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final spots = await _apiService.getSpots();
      if (mounted) {
        setState(() {
          _allSpots = spots;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    List<CafeSpot> result = List.from(_allSpots);

    // Apply active chip filter
    if (_activeFilter == 'Bandung') {
      result = result.where((s) => s.city.toLowerCase().contains('bandung')).toList();
    } else if (_activeFilter == 'Jakarta') {
      result = result.where((s) => s.city.toLowerCase().contains('jakarta')).toList();
    } else if (_activeFilter == 'Depok') {
      result = result.where((s) => s.city.toLowerCase().contains('depok')).toList();
    } else if (_activeFilter == 'Visited') {
      result = result.where((s) => s.isVisited).toList();
    } else if (_activeFilter == 'Wishlist') {
      result = result.where((s) => !s.isVisited).toList();
    } else if (_activeFilter == 'Coffee Shop') {
      result = result.where((s) => s.category == 'Coffee Shop').toList();
    } else if (_activeFilter == 'Artisan Bakery') {
      result = result.where((s) => s.category == 'Artisan Bakery').toList();
    } else if (_activeFilter == 'Resto / Dining') {
      result = result.where((s) => s.category == 'Resto / Dining').toList();
    }

    // Apply search query
    if (query.isNotEmpty) {
      result = result.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.city.toLowerCase().contains(query) ||
            s.category.toLowerCase().contains(query) ||
            s.mustOrder.toLowerCase().contains(query) ||
            s.vibeTags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    setState(() {
      _filteredSpots = result;
    });
  }

  Future<void> _pickRandomSpot() async {
    if (_allSpots.isEmpty) return;
    final randomSpot = _allSpots[Random().nextInt(_allSpots.length)];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.secondaryFixed, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Today's pick: ${randomSpot.name} (${randomSpot.city})! ✨",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Lihat",
          textColor: AppColors.primaryFixed,
          onPressed: () => _openDetail(randomSpot),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(CafeSpot spot) async {
    try {
      final updated = await _apiService.toggleFavorite(spot);
      setState(() {
        final index = _allSpots.indexWhere((s) => s.id == updated.id);
        if (index != -1) {
          _allSpots[index] = updated;
          _applyFilters();
        }
      });
    } catch (_) {
      _loadSpots();
    }
  }

  Future<void> _openDetail(CafeSpot spot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpotDetailScreen(spot: spot)),
    );
    if (result != null) {
      _loadSpots();
    }
  }

  Future<void> _openAddSpot() async {
    final result = await Navigator.push<CafeSpot>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditSpotScreen()),
    );
    if (result != null) {
      _loadSpots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerLowest,
          onRefresh: _loadSpots,
          child: CustomScrollView(
            slivers: [
              // 1. Editorial Custom Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _buildHeaderBar(),
                      const SizedBox(height: 14),
                      _buildContextSubtitle(),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _buildErrorBanner(),
                      ],
                    ],
                  ),
                ),
              ),

              // 2. Editorial Warm Gradient Hero Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeroBanner(),
                ),
              ),

              // 3. Scrollable Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _buildFilterChips(),
                ),
              ),

              // 4. Feed List of Cafe Cards with loading / empty state
              _isLoading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 14),
                              Text(
                                "Menghubungkan ke MockAPI...",
                                style: TextStyle(color: AppColors.outline, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _filteredSpots.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final spot = _filteredSpots[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildCafeCard(spot),
                                );
                              },
                              childCount: _filteredSpots.length,
                            ),
                          ),
                        ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSpot,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFFBA1A1A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Koneksi lambat/offline. Menampilkan data cache lokal.",
              style: const TextStyle(fontSize: 12, color: Color(0xFF93000A)),
            ),
          ),
          TextButton(
            onPressed: _loadSpots,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text("Coba Lagi", style: TextStyle(color: Color(0xFF93000A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("☕", style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SEPHIWA'S CAFE LOG",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.outline,
                  ),
                ),
                Text(
                  "Discover Feed",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary, size: 22),
              onPressed: _loadSpots,
              tooltip: "Refresh dari MockAPI",
            ),
            GestureDetector(
              onTap: widget.onNavigateToProfile,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContextSubtitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Diva Sephira's Journal",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "Bandung & Out-of-Town Notes",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_done, size: 13, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                "MockAPI Live",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFEFEAE4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilters(),
        decoration: InputDecoration(
          hintText: "Search cafe, resto, or city...",
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.outline),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : Container(
                  margin: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune, color: AppColors.onSurfaceVariant, size: 18),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.signaturePastelGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.15,
              child: Text(
                "✦",
                style: TextStyle(
                  fontSize: 72,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("✦", style: TextStyle(fontSize: 11, color: AppColors.primary)),
                    SizedBox(width: 4),
                    Text(
                      "TODAY'S COFFEE PICK",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Explore Your Next Cozy Spot",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Curated aesthetic corners & work-friendly sanctuaries.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _pickRandomSpot,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text("Pick Random Spot"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _activeFilter = filter);
                _applyFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.signaturePastelGradient : null,
                  color: isSelected ? null : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryContainer : const Color(0xFFEFEAE4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: isSelected ? 0.08 : 0.03),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Text("✦", style: TextStyle(color: AppColors.primary, fontSize: 10)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCafeCard(CafeSpot spot) {
    return GestureDetector(
      onTap: () => _openDetail(spot),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFEAE4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Header with Location & Status Pills
            Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.network(
                    spot.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.secondaryContainer,
                      child: const Center(
                        child: Icon(Icons.local_cafe, size: 48, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                // Location pill
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          spot.city,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Status pill (Visited vs Wishlist)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: spot.isVisited ? AppColors.visitedBg : AppColors.wishlistBg,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          spot.isVisited ? Icons.check : Icons.bookmark,
                          size: 12,
                          color: spot.isVisited ? AppColors.visitedText : AppColors.wishlistText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          spot.isVisited ? "Visited" : "Wishlist",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: spot.isVisited ? AppColors.visitedText : AppColors.wishlistText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vibe tags & Favorite toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          children: spot.vibeTags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          spot.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: spot.isFavorite ? const Color(0xFFBA1A1A) : AppColors.outline,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(spot),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Venue Title & Metrics
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          spot.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.outline),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("•", style: TextStyle(color: AppColors.outline)),
                      const SizedBox(width: 6),
                      Text(
                        spot.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const Icon(Icons.star, size: 13, color: AppColors.primaryContainer),
                      Text(
                        " (${spot.reviewCount})",
                        style: const TextStyle(fontSize: 11, color: AppColors.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Signature Must-Order Highlight Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mustOrderBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text("✦", style: TextStyle(color: AppColors.primary, fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "MUST ORDER",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                spot.mustOrder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text("☕", style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Cafes Found Here",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Try changing your search term or filter category.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.outline),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _activeFilter = 'All Spots');
                _applyFilters();
              },
              child: const Text("Reset Filter"),
            ),
          ],
        ),
      ),
    );
  }
}
