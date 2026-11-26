import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cafe_spot.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_spot_screen.dart';

class SpotDetailScreen extends StatefulWidget {
  final CafeSpot spot;

  const SpotDetailScreen({super.key, required this.spot});

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  late CafeSpot _spot;
  final ApiService _apiService = ApiService();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _spot = widget.spot;
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.secondaryFixed, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.inverseOnSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isActionLoading = true);
    try {
      final updated = await _apiService.toggleFavorite(_spot);
      if (mounted) {
        setState(() {
          _spot = updated;
          _isActionLoading = false;
        });
        _showToast(
          _spot.isFavorite
              ? "Disimpan ke Favorit Sephiwa! ✨"
              : "Dihapus dari daftar favorit",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionLoading = false);
        _showToast("Gagal memperbarui favorit: $e");
      }
    }
  }

  Future<void> _toggleVisited() async {
    setState(() => _isActionLoading = true);
    try {
      final updated = await _apiService.toggleVisited(_spot);
      if (mounted) {
        setState(() {
          _spot = updated;
          _isActionLoading = false;
        });
        _showToast(
          _spot.isVisited
              ? "Dipindahkan ke daftar Visited! ☕"
              : "Dipindahkan ke Wishlist Bucket! 🔖",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionLoading = false);
        _showToast("Gagal mengubah status: $e");
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse(_spot.mapsUrl.isNotEmpty
        ? _spot.mapsUrl
        : 'https://maps.google.com/?q=${Uri.encodeComponent("${_spot.name} ${_spot.city}")}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _copyAddressToClipboard();
      }
    } catch (_) {
      _copyAddressToClipboard();
    }
  }

  void _copyAddressToClipboard() {
    final text = "${_spot.name}\n${_spot.address}\n${_spot.mapsUrl}";
    Clipboard.setData(ClipboardData(text: text));
    _showToast("Alamat & Link Maps disalin ke Clipboard! 📋");
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<CafeSpot>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSpotScreen(spotToEdit: _spot),
      ),
    );

    if (result != null && mounted) {
      setState(() => _spot = result);
      _showToast("Catatan jurnal berhasil diperbarui di MockAPI! ✦");
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Spot Cafe Ini?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${_spot.name}' secara permanen dari MockAPI?",
          style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isActionLoading = true);
      try {
        await _apiService.deleteSpot(_spot.id);
        _showToast("Spot berhasil dihapus dari MockAPI");
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isActionLoading = false);
          _showToast("Gagal menghapus spot: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Collapsible / Hero Media App Bar
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                      onPressed: () => Navigator.pop(context, _spot),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(
                          _spot.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _spot.isFavorite ? const Color(0xFFBA1A1A) : AppColors.primary,
                          size: 20,
                        ),
                        onPressed: _isActionLoading ? null : _toggleFavorite,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                        onPressed: _isActionLoading ? null : _navigateToEdit,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppColors.primary, size: 20),
                        onPressed: _copyAddressToClipboard,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _spot.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.secondaryContainer,
                          child: const Center(
                            child: Icon(Icons.local_cafe, size: 64, color: AppColors.primary),
                          ),
                        ),
                      ),
                      // Dark bottom gradient vignette
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Location pill
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "${_spot.city} • ${_spot.category}".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Detail Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Spot Title & Metadata Card
                      _buildTitleCard(),
                      const SizedBox(height: 16),

                      // 2. Highlighted Signature Order Card
                      _buildMustOrderCard(),
                      const SizedBox(height: 16),

                      // 3. Location & Google Maps Card
                      _buildLocationCard(),
                      const SizedBox(height: 16),

                      // 4. Personal Journal & Vibe Section
                      _buildJournalSection(),
                      const SizedBox(height: 24),

                      // 5. Delete Spot Button
                      Center(
                        child: TextButton.icon(
                          onPressed: _isActionLoading ? null : _confirmDelete,
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 18),
                          label: const Text(
                            "Hapus Spot dari Log (MockAPI)",
                            style: TextStyle(
                              color: Color(0xFFBA1A1A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isActionLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _spot.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      _spot.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                    Text(
                      " (${_spot.reviewCount})",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${_spot.category} • Sanctuary & Roastery Notes",
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Visited vs Wishlist Toggle Pill
              GestureDetector(
                onTap: _isActionLoading ? null : _toggleVisited,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _spot.isVisited ? AppColors.visitedBg : AppColors.wishlistBg,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: _spot.isVisited
                          ? AppColors.visitedText.withValues(alpha: 0.3)
                          : AppColors.wishlistText.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _spot.isVisited ? Icons.check_circle : Icons.bookmark,
                        size: 14,
                        color: _spot.isVisited ? AppColors.visitedText : AppColors.wishlistText,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _spot.isVisited ? "Visited on ${_spot.loggedDate}" : "In Wishlist Bucket",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _spot.isVisited ? AppColors.visitedText : AppColors.wishlistText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_horiz,
                        size: 13,
                        color: _spot.isVisited ? AppColors.visitedText : AppColors.wishlistText,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  _spot.city,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMustOrderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.signaturePastelGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "MUST ORDER",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "Sephiwa's Rating 10/10",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSecondaryFixed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _spot.mustOrder,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Artisanal culinary curation. Recommended pair with hand-dripped pourover or warm buttery pastry.",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _spot.mustOrderPrice,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isActionLoading ? null : _toggleVisited,
                icon: Icon(
                  _spot.isVisited ? Icons.bookmark_add_outlined : Icons.check_circle_outline,
                  size: 15,
                ),
                label: Text(
                  _spot.isVisited ? "Add to Wishlist" : "Mark as Visited",
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Location & Hours",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        "${_spot.city} Sanctuary",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  "Open Daily",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.pin_drop_outlined, color: AppColors.outline, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _spot.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_outlined, color: AppColors.outline, size: 18),
              const SizedBox(width: 8),
              Text(
                "${_spot.openingHours} ",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Text(
                "(Early Bird Friendly)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map Preview Box
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFEAE4)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                      ),
                      itemCount: 24,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline, width: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_cafe, color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              _spot.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _spot.distanceText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _spot.walkingTime,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Two Action Buttons for Google Maps
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text("Buka Google Maps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _copyAddressToClipboard,
                  icon: const Icon(Icons.copy, size: 15),
                  label: const Text("Salin"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primaryContainer),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sephiwa's Journal",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        "Logged on ${_spot.loggedDate}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _isActionLoading ? null : _navigateToEdit,
                icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                label: const Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vibe tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _spot.vibeTags.map((vibe) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      vibe,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Editorial Journal quote box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "“${_spot.notes.isNotEmpty ? _spot.notes : 'Belum ada ulasan catatan personal untuk spot ini.'}”",
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Photo snapshots reel
          if (_spot.photoUrls.isNotEmpty) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Journal Snapshots",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _spot.photoUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _spot.photoUrls[index],
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.image, color: AppColors.outline),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Quick Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isActionLoading ? null : _navigateToEdit,
                  icon: const Icon(Icons.draw_outlined, size: 16),
                  label: const Text("Edit Note"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.onSurface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showToast("Fitur galeri foto tersimpan!");
                  },
                  icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                  label: const Text("Add Photos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryFixed,
                    foregroundColor: AppColors.onSecondaryFixed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
