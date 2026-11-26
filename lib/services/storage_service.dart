import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cafe_spot.dart';

class StorageService {
  static const String _spotsStorageKey = 'sephiwa_cafe_log_spots_v1';

  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Retrieve all spots from SharedPreferences, seeds default if first run
  Future<List<CafeSpot>> getSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_spotsStorageKey);

    if (rawData == null || rawData.isEmpty) {
      final initialSpots = _getInitialSeedData();
      await saveSpots(initialSpots);
      return initialSpots;
    }

    try {
      final List<dynamic> decoded = json.decode(rawData);
      return decoded.map((item) => CafeSpot.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback in case of parse error
      final initialSpots = _getInitialSeedData();
      await saveSpots(initialSpots);
      return initialSpots;
    }
  }

  /// Save full list of spots
  Future<void> saveSpots(List<CafeSpot> spots) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(spots.map((s) => s.toMap()).toList());
    await prefs.setString(_spotsStorageKey, encoded);
  }

  /// Add new spot (Create)
  Future<void> addSpot(CafeSpot spot) async {
    final spots = await getSpots();
    spots.insert(0, spot);
    await saveSpots(spots);
  }

  /// Update existing spot (Update)
  Future<void> updateSpot(CafeSpot updatedSpot) async {
    final spots = await getSpots();
    final index = spots.indexWhere((s) => s.id == updatedSpot.id);
    if (index != -1) {
      spots[index] = updatedSpot;
      await saveSpots(spots);
    }
  }

  /// Delete spot permanently (Delete)
  Future<void> deleteSpot(String id) async {
    final spots = await getSpots();
    spots.removeWhere((s) => s.id == id);
    await saveSpots(spots);
  }

  /// Toggle visited vs wishlist status
  Future<CafeSpot?> toggleVisitedStatus(String id) async {
    final spots = await getSpots();
    final index = spots.indexWhere((s) => s.id == id);
    if (index != -1) {
      final current = spots[index];
      final updated = current.copyWith(isVisited: !current.isVisited);
      spots[index] = updated;
      await saveSpots(spots);
      return updated;
    }
    return null;
  }

  /// Toggle favorite status
  Future<CafeSpot?> toggleFavorite(String id) async {
    final spots = await getSpots();
    final index = spots.indexWhere((s) => s.id == id);
    if (index != -1) {
      final current = spots[index];
      final updated = current.copyWith(isFavorite: !current.isFavorite);
      spots[index] = updated;
      await saveSpots(spots);
      return updated;
    }
    return null;
  }

  /// Reset to initial seed data
  Future<List<CafeSpot>> resetToSeedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spotsStorageKey);
    final initialSpots = _getInitialSeedData();
    await saveSpots(initialSpots);
    return initialSpots;
  }

  /// Authentic seed data requested by user and from stitch designs
  List<CafeSpot> _getInitialSeedData() {
    return [
      CafeSpot(
        id: 'spot-1',
        name: 'Two Cents Coffee',
        category: 'Coffee Shop',
        city: 'Bandung',
        address: 'Jl. Cimanuk No. 2, Citarum, Kec. Bandung Wetan, Kota Bandung, Jawa Barat 40115',
        mapsUrl: 'https://maps.google.com/?q=Two+Cents+Coffee+Bandung',
        rating: 4.9,
        reviewCount: 42,
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDE5ps_TYcscUfeWCRcdsO8n1PESQTUe8Y0WImk2Xr3trL1Y8t6uE1gWDyyhGJwHjRrffLq3Kst0Q4DUqzJvptLlAK2VD8-cecFL8NruQPZuidIpwTx7bMfFNJ146Dl994lfcTFOZ7KVroTrbVAFPFlQSP21pxwv8iq3pO8MEzYiVqWfOawhSLCYTWzjWnehUm6TTkgZzXU_RPaL9X-Qf3JCEWvQx6YqLP6V2gw2wU',
        mustOrder: 'Iced Butterscotch Latte & Almond Croissant',
        mustOrderPrice: 'IDR 48.000',
        vibeTags: ['Early Bird', 'Creamy Iced Coffee', 'WFC Friendly', 'Outdoor Courtyard'],
        isVisited: true,
        isFavorite: true,
        notes: 'The morning light hitting the courtyard is unbeatable for morning journaling or remote sprint tasks. Their butterscotch foam is dense without overpowering the single origin beans. Baristas are exceptionally welcoming.',
        loggedDate: 'Oct 14, 2024',
        openingHours: '07:00 AM – 10:00 PM',
        distanceText: '550m from Gedung Sate',
        walkingTime: '12 min walk',
        photoUrls: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBhvYHiDKLIYLb9Ztbtf-9fvDIghMLOJqDjsVpQNEZeiHGcdngcfBeYhI2uvjrf4r_MmvM6XE4Nar_rY6UEEwps_qkAnGzdPG-yB37Pted9BuVnX-IjkmJIh9Wp4b0o7XhpBrK-pughVEm23jVJOpmw2omR0j-czuPi-y3Xwu-7S3iY79YZzCGBMWy_LKejwa_Hx6Tr_B9z7cfiTUPav8tCLj-MGPJqv57Nl4XhzMc',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCRGHfE4S0OxfO2mbhAsywk-lbK6MaoRDg9oBvjaO_oxTQ2Qb2TbpKKq21NoMQhth5GkZv9ZL6SZhdh9kR769wriK8FxSnIAbFUAqza4dt3rBoDDW0AhcULFzb4_-xGJEAHtClcegst2SUXAhKDKcwjRjAaFUzMrXCwAIvzV-P7QnEEu-_hpfNrPV_ZZyO4r33W5qYxEHAJGIQ9cHQBy6ranM0egG43d8uZ5CMudsw',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDARo96EfSbBzAOmnszTLyZBot2UtdN6jpoc4X7wSjPvAZ9Nqss1AD8NEVhRP07S4IqSM8LR-d8oNmHsiGDFy9hZlQoecPflf-hXxjQWD_3xGNKvMHvpQRH_XCLDXwiCOHQidE-xqhwEJD_lM_OeKRbixznmqJnBoVoku_IUKxsxgrOlucBcN-4tkQDyI0pQQcgNuGYfRQ315RGgiG4ASlll9UPg5rbRlPnICVtVZU',
        ],
      ),
      CafeSpot(
        id: 'spot-2',
        name: "Khad's Corner Bandung",
        category: 'Coffee Shop',
        city: 'Bandung',
        address: 'Jl. Bengawan No. 23, Cihapit, Kec. Bandung Wetan, Kota Bandung',
        mapsUrl: 'https://maps.google.com/?q=Khads+Corner+Bandung',
        rating: 4.8,
        reviewCount: 36,
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
        mustOrder: 'Signature Khad Mocktail & Churros Cinnamon',
        mustOrderPrice: 'IDR 42.000',
        vibeTags: ['WFC Friendly', 'Aesthetic Interior', 'Chill Music'],
        isVisited: true,
        isFavorite: false,
        notes: 'Tempat ngopi teduh dengan banyak tanaman hijau dan area indoor ber-AC yang nyaman buat ngetik seharian. Wifi stabil dan colokan melimpah.',
        loggedDate: 'Nov 02, 2024',
        openingHours: '08:00 AM – 10:00 PM',
        distanceText: 'Bandung Wetan',
        walkingTime: '15 min walk',
        photoUrls: [
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
        ],
      ),
      CafeSpot(
        id: 'spot-3',
        name: 'Sate Asin Pedas ITENAS',
        category: 'Resto / Dining',
        city: 'Bandung',
        address: 'Jl. PH.H. Mustofa No. 23 (Sebelah Kampus ITENAS), Cibeunying Kaler, Kota Bandung',
        mapsUrl: 'https://maps.google.com/?q=Sate+Asin+Pedas+ITENAS+Bandung',
        rating: 4.9,
        reviewCount: 95,
        imageUrl: 'https://images.unsplash.com/photo-1529563021893-cc83c914d73e?auto=format&fit=crop&w=800&q=80',
        mustOrder: 'Sate Asin Pedas Ayam + Soto Gurih Krispi',
        mustOrderPrice: 'IDR 25.000',
        vibeTags: ['Afterwork Chill', 'Kuliner Malam', 'Super Savory'],
        isVisited: true,
        isFavorite: true,
        notes: 'Legendaris di kalangan mahasiswa dan pemburu kuliner malam Bandung. Bumbu asin pedasnya meresap sempurna, dibakar arang wangi gurih maksimal!',
        loggedDate: 'Oct 28, 2024',
        openingHours: '05:00 PM – 12:00 AM',
        distanceText: 'Dekat Kampus ITENAS',
        walkingTime: 'Street food vibe',
        photoUrls: [
          'https://images.unsplash.com/photo-1529563021893-cc83c914d73e?auto=format&fit=crop&w=800&q=80',
        ],
      ),
      CafeSpot(
        id: 'spot-4',
        name: 'Maru + Bodas Blok M',
        category: 'Coffee Shop',
        city: 'Jakarta Selatan',
        address: 'Jl. Melawai III No. 8, Blok M, Kebayoran Baru, Jakarta Selatan',
        mapsUrl: 'https://maps.google.com/?q=Maru+Bodas+Blok+M+Jakarta',
        rating: 4.8,
        reviewCount: 52,
        imageUrl: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=800&q=80',
        mustOrder: 'Bodas Creamy White & Yuzu Matcha Chiffon',
        mustOrderPrice: 'IDR 52.000',
        vibeTags: ['Early Bird', 'Aesthetic Interior', 'Blok M Hopping'],
        isVisited: true,
        isFavorite: true,
        notes: 'Minimalist Japanese aesthetic interior with spotless white vibes. Espresso and pastry combo are world class. Great spot right in the heart of Blok M culinary hub.',
        loggedDate: 'Nov 12, 2024',
        openingHours: '08:00 AM – 09:00 PM',
        distanceText: '300m from MRT Blok M',
        walkingTime: '5 min walk',
        photoUrls: [
          'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=800&q=80',
        ],
      ),
      CafeSpot(
        id: 'spot-5',
        name: 'UNION Central Park',
        category: 'Artisan Bakery',
        city: 'Jakarta Barat',
        address: 'Central Park Mall GF, Letjen S. Parman St No.28, Tj. Duren Sel., Jakarta Barat',
        mapsUrl: 'https://maps.google.com/?q=UNION+Central+Park+Jakarta',
        rating: 4.9,
        reviewCount: 88,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
        mustOrder: 'Famous Red Velvet Cake & Truffle Pasta',
        mustOrderPrice: 'IDR 75.000',
        vibeTags: ['Artisan Pastry', 'Afterwork Chill', 'Fine Bistro'],
        isVisited: true,
        isFavorite: true,
        notes: 'The gold standard of Indonesian bakery & brassiere. The red velvet cake texture is iconic, crunchy nougat topping and cream cheese balance are unmatched.',
        loggedDate: 'Nov 18, 2024',
        openingHours: '10:00 AM – 10:00 PM',
        distanceText: 'Inside Central Park Mall',
        walkingTime: 'Indoor hub',
        photoUrls: [
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
        ],
      ),
      CafeSpot(
        id: 'spot-6',
        name: 'Dream Dates Artisan Bakery & Restaurant PIM 5',
        category: 'Artisan Bakery',
        city: 'Jakarta Selatan',
        address: 'Pondok Indah Mall (PIM 3/Street Gallery area), Pondok Pinang, Jakarta Selatan',
        mapsUrl: 'https://maps.google.com/?q=Dream+Dates+Artisan+Bakery+Pondok+Indah',
        rating: 4.8,
        reviewCount: 40,
        imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?auto=format&fit=crop&w=800&q=80',
        mustOrder: 'Pistachio Croissant & Date Honey Macchiato',
        mustOrderPrice: 'IDR 60.000',
        vibeTags: ['Artisan Bakery', 'Aesthetic Interior', 'Luxury Brunch'],
        isVisited: false,
        isFavorite: true,
        notes: 'Wishlist utama! Penasaran banget sama olahan dates premium dan lapisan pastry buttery yang harum semerbak.',
        loggedDate: 'Nov 20, 2024',
        openingHours: '09:00 AM – 10:00 PM',
        distanceText: 'PIM Area',
        walkingTime: 'Indoor luxury',
        photoUrls: [
          'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?auto=format&fit=crop&w=800&q=80',
        ],
      ),
      CafeSpot(
        id: 'spot-7',
        name: 'Aloha Pasir Putih PIK',
        category: 'Resto / Dining',
        city: 'Jakarta Utara',
        address: 'Kawasan Pantai Pasir Putih PIK 2, Tangerang / Jakarta Utara',
        mapsUrl: 'https://maps.google.com/?q=Aloha+Pasir+Putih+PIK+2',
        rating: 4.7,
        reviewCount: 74,
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        mustOrder: 'Hawaiian Coconut Shake & Seafood Platter',
        mustOrderPrice: 'IDR 85.000',
        vibeTags: ['Outdoor Courtyard', 'Pet Friendly', 'Sunset Beach Vibe'],
        isVisited: false,
        isFavorite: false,
        notes: 'Konsep tropical beachfront yang serasa di Hawaii. Angin sepoi-sepoi dan spot foto cantik pas senja.',
        loggedDate: 'Nov 22, 2024',
        openingHours: '10:00 AM – 10:00 PM',
        distanceText: 'PIK 2 White Sand Beach',
        walkingTime: 'Beachfront walk',
        photoUrls: [
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        ],
      ),
      CafeSpot(
        id: 'spot-8',
        name: 'Common Grounds Ground Zero',
        category: 'Coffee Shop',
        city: 'Jakarta Selatan',
        address: 'Ashta District 8 GF, SCBD, Senopati, Kebayoran Baru, Jakarta Selatan',
        mapsUrl: 'https://maps.google.com/?q=Common+Grounds+Ashta+District+8',
        rating: 4.8,
        reviewCount: 65,
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDD-GeiAZ1kKC5KNfWnPLkz2en1VPv9aP6wZTCWwxgNIBmHjhjfOUI0eAFRyGqIMWHSlkbKuDr8y3z71INndeNAYBbkLKE5Yj2xR4b3pRCtLvyD1hvQngvOLB50N-hLep_73wcSM4FfYUdKm2yXueG2lp-AG7ZQ7fejGUkiw7P7fDFZHFUdGlr_YXqlT6JgkaRS2VWj8qdKFBbX1oe1hqfZ5O1cUEC5akfTgOwJAog',
        mustOrder: 'Panama Geisha Pour Over & Truffle Fries',
        mustOrderPrice: 'IDR 68.000',
        vibeTags: ['WFC Friendly', 'Filter Roast', 'SCBD Hustle'],
        isVisited: false,
        isFavorite: true,
        notes: 'High ceiling glasshouse cafe inside Ashta District 8. Perfect specialty coffee bar for serious coffee connoisseurs and business meetings.',
        loggedDate: 'Oct 20, 2024',
        openingHours: '08:00 AM – 10:00 PM',
        distanceText: 'SCBD Hub',
        walkingTime: '3 min walk from office',
        photoUrls: [],
      ),
      CafeSpot(
        id: 'spot-9',
        name: 'Kopi Nako Djuanda',
        category: 'Coffee Shop',
        city: 'Depok',
        address: 'Jl. Ir. H. Juanda No. 9, Kemiri Muka, Beji, Kota Depok, Jawa Barat 16423',
        mapsUrl: 'https://maps.google.com/?q=Kopi+Nako+Djuanda+Depok',
        rating: 4.7,
        reviewCount: 89,
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuASQ9iI9_hfsJqlyKJgigskMHkWD7jSTcTGVh85LF2i-3UyinkEG03QVgwIcMSgGM5eLUP0Ol_G-QN1XuRDI_Cr--oLWuH5Qnyg52eouyhfifa-aVwk3DMvCs4voRw8WGKG2lGMyS1eqG-cDo3AhvIkAWJmMFpedNYsN0-GifMYDaIKerh2QdVhckhVeKrQu9yM_KAsHa-wCIcKNwi_fwPS0LWbP5Ll0eL0IEzw8IM',
        mustOrder: 'Es Kopi Nako Sayang & Cireng Salju',
        mustOrderPrice: 'IDR 32.000',
        vibeTags: ['Afterwork Chill', 'Glass House', 'Outdoor Courtyard'],
        isVisited: true,
        isFavorite: false,
        notes: 'Cozy Japanese kissaten glasshouse with lush greenery. Perfect sunset hangout spot with friends after work in Depok.',
        loggedDate: 'Sep 29, 2024',
        openingHours: '08:00 AM – 11:00 PM',
        distanceText: 'Juanda Depok Corridor',
        walkingTime: 'Spacious parking',
        photoUrls: [],
      ),
      CafeSpot(
        id: 'spot-10',
        name: 'Seroja Bake',
        category: 'Artisan Bakery',
        city: 'Bandung',
        address: 'Jl. Cihapit No. 21C, Cihapit, Kec. Bandung Wetan, Kota Bandung',
        mapsUrl: 'https://maps.google.com/?q=Seroja+Bake+Cihapit+Bandung',
        rating: 4.9,
        reviewCount: 57,
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfLFDtaQtCXf4iPUzXi_P3AuMSFdTAfcAyNE145SXpi2Jup3lAmXsSTqqjDLLS-qLW_RP6TX82a6_Jw-sAackftSgNmSutCWELSBP7Koff-NNyDIJst_cBu_YcMbXpKKlHXfNQfQuR1Zj5V96UgIRzDn0p9aL95ZbQlp7u_qNsO6Fpskeh6K4gZTieqE8Tv7FtCvcC0U5wHKUTNByBhMeU3QSj8-FR25TvbrOejg4',
        mustOrder: 'Tart Singkong & Strawberry Pavlova',
        mustOrderPrice: 'IDR 45.000',
        vibeTags: ['Artisan Pastry', 'Aesthetic Interior', 'Local Ingredients'],
        isVisited: false,
        isFavorite: true,
        notes: 'Kue dan tart artisan yang mengangkat rempah dan bahan lokal Indonesia dengan teknik baking Prancis. Salah satu permata terindah di Cihapit Bandung.',
        loggedDate: 'Nov 15, 2024',
        openingHours: '08:00 AM – 08:00 PM',
        distanceText: 'Kawasan Pasar Cihapit',
        walkingTime: 'Heritage walk',
        photoUrls: [],
      ),
    ];
  }
}
