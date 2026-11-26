import 'package:flutter/material.dart';
import '../models/cafe_spot.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_spot_screen.dart';
import 'spot_detail_screen.dart';

class VisitedWishlistScreen extends StatefulWidget {
  const VisitedWishlistScreen({super.key});

  @override
  State<VisitedWishlistScreen> createState() => _VisitedWishlistScreenState();
}

class _VisitedWishlistScreenState extends State<VisitedWishlistScreen> {
  final ApiService _apiService = ApiService();

  List<CafeSpot> _allSpots = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showVisited = true; // true = Visited Spots, false = Wishlist Bucket
  String _selectedCityFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadSpots();
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

  Future<void> _markVisited(CafeSpot spot) async {
    try {
      final updated = await _apiService.toggleVisited(spot);
      if (mounted) {
        setState(() {
          final index = _allSpots.indexWhere((s) => s.id == updated.id);
          if (index != -1) {
            _allSpots[index] = updated;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${spot.name} dipindahkan ke Visited Spots! ☕"),
            backgroundColor: AppColors.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
    final visitedCount = _allSpots.where((s) => s.isVisited).length;
    final wishlistCount = _allSpots.where((s) => !s.isVisited).length;

    // Filter by tab
    List<CafeSpot> currentList = _allSpots.where((s) => s.isVisited == _showVisited).toList();

    // Filter by city
    if (_selectedCityFilter != 'All') {
      currentList = currentList.where((s) => s.city.toLowerCase().contains(_selectedCityFilter.toLowerCase())).toList();
    }

    // Cities count
    final cities = _allSpots.map((s) => s.city).toSet().toList();
    final coffeeCount = _allSpots.where((s) => s.category == 'Coffee Shop').length;
    final restoCount = _allSpots.where((s) => s.category == 'Resto / Dining').length;
    final bakeryCount = _allSpots.where((s) => s.category == 'Artisan Bakery').length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadSpots,
          child: CustomScrollView(
            slivers: [
              // Editorial Header Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Coffee Journal",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Curated places & bucket list by Diva Sephira",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
                            onPressed: _loadSpots,
                            tooltip: "Refresh dari MockAPI",
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_vert, color: AppColors.onSurfaceVariant),
                            onPressed: () {
                              setState(() {
                                _allSpots = _allSpots.reversed.toList();
                              });
                            },
                            tooltip: "Balik Urutan",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Segmented Pill Switch (Visited vs Wishlist)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showVisited = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _showVisited ? AppColors.surfaceContainerLowest : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: _showVisited
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryContainer.withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_showVisited) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    "Visited Spots",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _showVisited ? FontWeight.bold : FontWeight.w500,
                                      color: _showVisited ? AppColors.onSurface : AppColors.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      "$visitedCount",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showVisited = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_showVisited ? AppColors.surfaceContainerLowest : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: !_showVisited
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryContainer.withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!_showVisited) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    "Wishlist Bucket",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: !_showVisited ? FontWeight.bold : FontWeight.w500,
                                      color: !_showVisited ? AppColors.onSurface : AppColors.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      "$wishlistCount",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Light Gradient Travel Stat Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.warmBannerGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEAE4)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.06),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("✦", style: TextStyle(color: AppColors.primary, fontSize: 11)),
                              SizedBox(width: 4),
                              Text(
                                "JOURNAL SNAPSHOT 2024",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${_allSpots.length} Spots Logged • ${cities.length} Destinations",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Capturing everyday warmth, roasts & pastry notes",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildStatChip("☕", "$coffeeCount Coffee Bars"),
                            _buildStatChip("🍽️", "$restoCount Restos"),
                            _buildStatChip("🥐", "$bakeryCount Bakeries"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick City Filter Pills
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      _buildCityFilterPill('All', "All (${_allSpots.where((s) => s.isVisited == _showVisited).length})"),
                      _buildCityFilterPill('Bandung', "Bandung (${_allSpots.where((s) => s.city.contains('Bandung') && s.isVisited == _showVisited).length})"),
                      _buildCityFilterPill('Jakarta', "Jakarta (${_allSpots.where((s) => s.city.contains('Jakarta') && s.isVisited == _showVisited).length})"),
                      _buildCityFilterPill('Depok', "Depok (${_allSpots.where((s) => s.city.contains('Depok') && s.isVisited == _showVisited).length})"),
                    ],
                  ),
                ),
              ),

              // Cards List
              _isLoading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    )
                  : currentList.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(child: Text("☕", style: TextStyle(fontSize: 26))),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _showVisited ? "No Visited Spots in this Filter" : "Your Wishlist is Empty",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Ready to add your next hidden gem to this collection?",
                                  style: TextStyle(fontSize: 12, color: AppColors.outline),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _openAddSpot,
                                  child: const Text("+ Add New Spot"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final spot = currentList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSpotListItem(spot),
                                );
                              },
                              childCount: currentList.length,
                            ),
                          ),
                        ),

              // Secret Recommendation Prompt Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEAE4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_note, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Have a secret recommendation?",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Diva loves discovering quiet morning corners",
                                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _openAddSpot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerLowest,
                            foregroundColor: AppColors.primary,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: const Text("Suggest", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilterPill(String cityKey, String label) {
    final isSelected = _selectedCityFilter == cityKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCityFilter = cityKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFEFEAE4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotListItem(CafeSpot spot) {
    return GestureDetector(
      onTap: () => _openDetail(spot),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFEAE4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 72x72 Thumbnail with rating overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    spot.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.secondaryContainer,
                      child: const Icon(Icons.local_cafe, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.inverseSurface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${spot.rating.toStringAsFixed(1)} ★",
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          spot.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: spot.isVisited ? AppColors.visitedBg : AppColors.wishlistBg,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          spot.isVisited ? "✓ Visited" : "♡ Wishlist",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: spot.isVisited ? AppColors.visitedText : AppColors.wishlistText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        "📍 ${spot.city}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (spot.vibeTags.isNotEmpty) ...[
                        const Text(" • ", style: TextStyle(color: AppColors.outline, fontSize: 11)),
                        Expanded(
                          child: Text(
                            spot.vibeTags.join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.outline),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Must-order row + optional Done button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              children: [
                                const TextSpan(
                                  text: "Must: ",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                TextSpan(text: spot.mustOrder),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!spot.isVisited) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _markVisited(spot),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check, size: 12, color: AppColors.onSecondaryFixed),
                                SizedBox(width: 4),
                                Text(
                                  "Done?",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSecondaryFixed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
