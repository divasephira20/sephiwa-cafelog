import 'package:flutter/material.dart';
import '../models/cafe_spot.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class JournalProfileScreen extends StatefulWidget {
  const JournalProfileScreen({super.key});

  @override
  State<JournalProfileScreen> createState() => _JournalProfileScreenState();
}

class _JournalProfileScreenState extends State<JournalProfileScreen> {
  final ApiService _apiService = ApiService();
  List<CafeSpot> _spots = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final spots = await _apiService.getSpots();
      if (mounted) {
        setState(() {
          _spots = spots;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncSeedDataToMockApi() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sinkronkan ke MockAPI?", style: TextStyle(color: AppColors.onSurface)),
        content: const Text(
          "Aplikasi akan mengirimkan (POST) seluruh 10 spot autentik rekomendasi Diva (Two Cents, Sate ITENAS, Khad's Corner, Maru + Bodas, UNION, Dream Dates, Aloha PIK, dll.) langsung ke MockAPI.io kamu.",
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Upload ke MockAPI"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSyncing = true);
      final count = await _apiService.pushSeedDataToMockApi();
      await _loadStats();
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil mengunggah $count spot ke server MockAPI! ✦"),
            backgroundColor: AppColors.inverseSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitedCount = _spots.where((s) => s.isVisited).length;
    final wishlistCount = _spots.where((s) => !s.isVisited).length;
    final favCount = _spots.where((s) => s.isFavorite).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Curator Profile & Journal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
            onPressed: _loadStats,
            tooltip: "Refresh dari MockAPI",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.signaturePastelGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEFEAE4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text("☕", style: TextStyle(fontSize: 34)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Diva Sephira",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Bandung & Out-of-Town Cafe Hopping Curator",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_stories, color: AppColors.primary, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  "Warm Editorial Cafe Log",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Three Quick Metrics
                    Row(
                      children: [
                        _buildMetricTile("Visited", "$visitedCount", AppColors.visitedBg, AppColors.visitedText),
                        const SizedBox(width: 8),
                        _buildMetricTile("Wishlist", "$wishlistCount", AppColors.wishlistBg, AppColors.wishlistText),
                        const SizedBox(width: 8),
                        _buildMetricTile("Favorites", "$favCount", AppColors.secondaryFixed, AppColors.onSecondaryFixed),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Editorial Manifesto Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEAE4)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_quote, color: AppColors.primary, size: 24),
                              SizedBox(width: 6),
                              Text(
                                "Journal Philosophy",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "“Every cup holds an ambient memory. From the quiet morning sun of Cimanuk Bandung to the bustling roasteries of Jakarta and lush glasshouses of Depok, Sephiwa's Cafe Log records cozy sanctuaries that warm the heart and spark inspiration.”",
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // REST API & MockAPI Integration Status Section
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEAE4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.cloud_done, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "MockAPI.io REST Endpoint",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const SelectableText(
                              ApiService.baseUrl,
                              style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Jika koleksi di MockAPI.io kamu masih kosong (0 records), tekan tombol di bawah untuk mengunggah otomatis spot awal rekomendasi autentik.",
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: _isSyncing ? null : _syncSeedDataToMockApi,
                            icon: _isSyncing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  )
                                : const Icon(Icons.cloud_upload_outlined, size: 16),
                            label: Text(_isSyncing ? "Mengunggah..." : "Upload Seed Data ke MockAPI"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primaryContainer),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
