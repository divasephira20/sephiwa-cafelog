import 'package:flutter/material.dart';
import '../models/cafe_spot.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AddEditSpotScreen extends StatefulWidget {
  final CafeSpot? spotToEdit;

  const AddEditSpotScreen({super.key, this.spotToEdit});

  @override
  State<AddEditSpotScreen> createState() => _AddEditSpotScreenState();
}

class _AddEditSpotScreenState extends State<AddEditSpotScreen> {
  final ApiService _apiService = ApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _mustOrderController;
  late final TextEditingController _notesController;
  late final TextEditingController _imageUrlController;

  String _selectedCategory = 'Coffee Shop';
  bool _isVisited = true;
  String _selectedCity = 'Bandung';
  double _rating = 5.0;
  final List<String> _selectedVibes = [];
  bool _isSaving = false;

  final List<String> _presetVibes = [
    'Early Bird',
    'Creamy Iced Coffee',
    'WFC Friendly',
    'Afterwork Chill',
    'Outdoor Courtyard',
    'Pet Friendly',
    'Aesthetic Interior',
    'Filter Roast',
    'Artisan Pastry',
  ];

  final List<String> _presetCities = [
    'Bandung',
    'Jakarta',
    'Jakarta Selatan',
    'Jakarta Barat',
    'Jakarta Utara',
    'Depok',
  ];

  final List<String> _photoPresets = [
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.spotToEdit;
    _nameController = TextEditingController(text: s?.name ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _mustOrderController = TextEditingController(text: s?.mustOrder ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');
    _imageUrlController = TextEditingController(
      text: s?.imageUrl ?? _photoPresets.first,
    );

    if (s != null) {
      _selectedCategory = s.category;
      _isVisited = s.isVisited;
      _selectedCity = s.city;
      _rating = s.rating;
      _selectedVibes.addAll(s.vibeTags);
    } else {
      _selectedVibes.addAll(['Early Bird', 'Creamy Iced Coffee', 'WFC Friendly']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mustOrderController.dispose();
    _notesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _toggleVibe(String vibe) {
    setState(() {
      if (_selectedVibes.contains(vibe)) {
        _selectedVibes.remove(vibe);
      } else {
        _selectedVibes.add(vibe);
      }
    });
  }

  Future<void> _showCustomCityDialog() async {
    final controller = TextEditingController();
    final customCity = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Kota Lain", style: TextStyle(color: AppColors.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Contoh: Bogor, Surabaya, Bali",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text("Pilih"),
          ),
        ],
      ),
    );

    if (customCity != null && customCity.isNotEmpty) {
      setState(() {
        if (!_presetCities.contains(customCity)) {
          _presetCities.add(customCity);
        }
        _selectedCity = customCity;
      });
    }
  }

  Future<void> _saveSpot() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama cafe/spot wajib diisi!"),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";

    final address = _addressController.text.trim().isEmpty
        ? "$name, $_selectedCity"
        : _addressController.text.trim();

    final mapsUrl = "https://maps.google.com/?q=${Uri.encodeComponent("$name $_selectedCity")}";

    final spotPayload = CafeSpot(
      id: widget.spotToEdit?.id ?? '',
      name: name,
      category: _selectedCategory,
      city: _selectedCity,
      address: address,
      mapsUrl: widget.spotToEdit?.mapsUrl.isNotEmpty == true
          ? widget.spotToEdit!.mapsUrl
          : mapsUrl,
      rating: _rating,
      reviewCount: widget.spotToEdit?.reviewCount ?? 1,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? _photoPresets.first
          : _imageUrlController.text.trim(),
      mustOrder: _mustOrderController.text.trim().isEmpty
          ? "Specialty Signature Coffee & Pastry"
          : _mustOrderController.text.trim(),
      mustOrderPrice: widget.spotToEdit?.mustOrderPrice ?? "IDR 45.000",
      vibeTags: _selectedVibes.isEmpty ? ["Aesthetic Spot"] : _selectedVibes,
      isVisited: _isVisited,
      isFavorite: widget.spotToEdit?.isFavorite ?? false,
      notes: _notesController.text.trim(),
      loggedDate: widget.spotToEdit?.loggedDate ?? dateStr,
      openingHours: widget.spotToEdit?.openingHours ?? "08:00 AM – 10:00 PM",
      distanceText: widget.spotToEdit?.distanceText ?? "$_selectedCity Central",
      walkingTime: widget.spotToEdit?.walkingTime ?? "Accessible Hub",
      photoUrls: widget.spotToEdit?.photoUrls.isNotEmpty == true
          ? widget.spotToEdit!.photoUrls
          : [_imageUrlController.text.trim()],
    );

    try {
      CafeSpot resultSpot;
      if (widget.spotToEdit == null) {
        // Create (POST)
        resultSpot = await _apiService.createSpot(spotPayload);
      } else {
        // Update (PUT)
        resultSpot = await _apiService.updateSpot(spotPayload);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, resultSpot);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Peringatan jaringan: $e (disimpan secara offline)"),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
        Navigator.pop(context, spotPayload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.spotToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Spot Log" : "Log New Spot",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isEditing ? "MockAPI Edit" : "MockAPI Post",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Category Selector
                _buildCategorySelector(),
                const SizedBox(height: 18),

                // 2. Journal Status Toggle (Visited vs Wishlist)
                _buildStatusToggle(),
                const SizedBox(height: 18),

                // 3. Spot Info Card (Name, City chips, Address)
                _buildSpotInfoCard(),
                const SizedBox(height: 18),

                // 4. Photo Preset & URL Picker
                _buildPhotoPickerCard(),
                const SizedBox(height: 18),

                // 5. Culinary & Experience Highlights (Must-Order, Vibe Tags, Rating)
                _buildHighlightsCard(),
                const SizedBox(height: 18),

                // 6. Personal Notes Review Textarea
                _buildNotesCard(),
                const SizedBox(height: 24),

                // 7. Save and Cancel buttons
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveSpot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSaving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      else ...[
                        Text(
                          isEditing ? "Update via MockAPI (PUT)" : "Save to MockAPI (POST)",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("✦", style: TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel and discard",
                    style: TextStyle(
                      color: AppColors.outline,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'label': 'Coffee Shop', 'emoji': '☕'},
      {'label': 'Resto / Dining', 'emoji': '🍽️'},
      {'label': 'Artisan Bakery', 'emoji': '🥐'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.local_cafe, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  "Select Category",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              "Required",
              style: TextStyle(
                fontSize: 11,
                color: AppColors.outline.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat['label'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['label']!),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.signaturePastelGradient : null,
                    color: isSelected ? null : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryContainer : const Color(0xFFEFEAE4),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.04),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(cat['emoji']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text(
                        cat['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
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
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.verified, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              "Journal Status",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isVisited = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isVisited ? AppColors.visitedBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: _isVisited
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,
                          size: 15,
                          color: _isVisited ? AppColors.visitedText : AppColors.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Visited",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _isVisited ? AppColors.visitedText : AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isVisited = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isVisited ? AppColors.wishlistBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: !_isVisited
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 15,
                          color: !_isVisited ? AppColors.wishlistText : AppColors.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Wishlist",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: !_isVisited ? AppColors.wishlistText : AppColors.outline,
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
      ],
    );
  }

  Widget _buildSpotInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spot Name",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.storefront, color: AppColors.primary, size: 20),
              hintText: "e.g. Two Cents Coffee, UNION, Seroja Bake",
            ),
          ),
          const SizedBox(height: 14),

          // City Chips
          const Text(
            "City / Destination",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._presetCities.map((city) {
                final isSelected = _selectedCity == city;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = city),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      city,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: _showCustomCityDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppColors.onSecondaryContainer),
                      SizedBox(width: 4),
                      Text(
                        "Other City",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Address
          const Text(
            "Full Address / Maps Landmark",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _addressController,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.outline, size: 20),
              hintText: "e.g. Jl. Cimanuk No. 2, Riau, Bandung",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPickerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "Curated Photo",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                "Tap to choose preset",
                style: TextStyle(fontSize: 11, color: AppColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photoPresets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final url = _photoPresets[index];
                final isSelected = _imageUrlController.text == url;
                return GestureDetector(
                  onTap: () => setState(() => _imageUrlController.text = url),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _imageUrlController,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.link, size: 18, color: AppColors.outline),
              hintText: "Atau masukkan URL foto khusus...",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Must Order
          const Text(
            "Must-Order Signature Menu",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _mustOrderController,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.restaurant_menu, color: AppColors.secondary, size: 18),
              hintText: "e.g. Iced Butterscotch Latte & Almond Croissant",
            ),
          ),
          const SizedBox(height: 16),

          // Vibe tags
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sensory Atmosphere & Vibes",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text("Multi-select", style: TextStyle(fontSize: 11, color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetVibes.map((vibe) {
              final isSelected = _selectedVibes.contains(vibe);
              return GestureDetector(
                onTap: () => _toggleVibe(vibe),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vibe,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Text("✦", style: TextStyle(fontSize: 9, color: AppColors.primary)),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Overall Experience Rating",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "${_rating.toStringAsFixed(1)} ★",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  icon: Icon(
                    _rating >= starValue ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = starValue),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAE4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "Sephiwa's Personal Notes & Review",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text("Editorial", style: TextStyle(fontSize: 11, color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, height: 1.5),
            decoration: const InputDecoration(
              hintText: "Tuliskan kesan ambience, pencahayaan, suasana kerja, atau keunikan rasa kopi...",
            ),
          ),
        ],
      ),
    );
  }
}
