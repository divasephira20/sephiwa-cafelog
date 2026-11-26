import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cafe_spot.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://6b07f2d058419b87a438e57d.mockapi.io/api/v1/spots';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _fallbackStorage = StorageService();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// 1. HTTP GET: Ambil seluruh daftar cafe spot dari MockAPI
  Future<List<CafeSpot>> getSpots() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers).timeout(
        const Duration(seconds: 12),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        final spots = jsonList.map((item) => CafeSpot.fromJson(item as Map<String, dynamic>)).toList();

        // Jika MockAPI masih baru/kosong, coba sinkronkan data awal autentik
        if (spots.isEmpty) {
          final cached = await _fallbackStorage.getSpots();
          return cached;
        }

        // Cache hasil ke local storage sebagai backup offline
        await _fallbackStorage.saveSpots(spots);
        return spots;
      } else {
        throw Exception('Server mengembalikan kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback ke penyimpanan lokal jika offline atau terjadi error jaringan
      final cached = await _fallbackStorage.getSpots();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  /// 2. HTTP POST: Menambahkan spot baru ke MockAPI
  Future<CafeSpot> createSpot(CafeSpot spot) async {
    try {
      final payload = json.encode(spot.toJson(includeId: false));
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: payload,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        final createdSpot = CafeSpot.fromJson(responseData);
        // Simpan ke local cache
        await _fallbackStorage.addSpot(createdSpot);
        return createdSpot;
      } else {
        throw Exception('Gagal membuat spot baru (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Jika jaringan gagal, tetap simpan lokal
      await _fallbackStorage.addSpot(spot);
      return spot;
    }
  }

  /// 3. HTTP PUT: Memperbarui spot yang sudah ada di $baseUrl/${spot.id}
  Future<CafeSpot> updateSpot(CafeSpot spot) async {
    try {
      final payload = json.encode(spot.toJson(includeId: true));
      final response = await http.put(
        Uri.parse('$baseUrl/${spot.id}'),
        headers: _headers,
        body: payload,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        final updated = CafeSpot.fromJson(responseData);
        await _fallbackStorage.updateSpot(updated);
        return updated;
      } else {
        throw Exception('Gagal memperbarui spot (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Jika jaringan gagal, tetap perbarui cache lokal
      await _fallbackStorage.updateSpot(spot);
      return spot;
    }
  }

  /// 4. HTTP DELETE: Menghapus spot dari $baseUrl/$id
  Future<bool> deleteSpot(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _fallbackStorage.deleteSpot(id);
        return true;
      } else {
        throw Exception('Gagal menghapus spot (${response.statusCode})');
      }
    } catch (e) {
      await _fallbackStorage.deleteSpot(id);
      return true;
    }
  }

  /// Toggle status Visited vs Wishlist melalui PUT
  Future<CafeSpot> toggleVisited(CafeSpot spot) async {
    final updated = spot.copyWith(isVisited: !spot.isVisited);
    return await updateSpot(updated);
  }

  /// Toggle status Favorite melalui PUT
  Future<CafeSpot> toggleFavorite(CafeSpot spot) async {
    final updated = spot.copyWith(isFavorite: !spot.isFavorite);
    return await updateSpot(updated);
  }

  /// Sinkronkan seed data autentik Diva ke MockAPI (bisa dipanggil dari JournalProfileScreen)
  Future<int> pushSeedDataToMockApi() async {
    final seedSpots = await _fallbackStorage.resetToSeedData();
    int successCount = 0;
    for (final spot in seedSpots) {
      try {
        await http.post(
          Uri.parse(baseUrl),
          headers: _headers,
          body: json.encode(spot.toJson(includeId: false)),
        );
        successCount++;
      } catch (_) {}
    }
    return successCount;
  }
}
