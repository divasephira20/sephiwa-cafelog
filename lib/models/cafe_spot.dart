import 'dart:convert';

class CafeSpot {
  final String id;
  final String name;
  final String category;
  final String city;
  final String address;
  final String mapsUrl;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String mustOrder;
  final String mustOrderPrice;
  final List<String> vibeTags;
  final bool isVisited;
  final bool isFavorite;
  final String notes;
  final String loggedDate;
  final String openingHours;
  final String distanceText;
  final String walkingTime;
  final List<String> photoUrls;

  CafeSpot({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.address,
    required this.mapsUrl,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.mustOrder,
    required this.mustOrderPrice,
    required this.vibeTags,
    required this.isVisited,
    required this.isFavorite,
    required this.notes,
    required this.loggedDate,
    required this.openingHours,
    required this.distanceText,
    required this.walkingTime,
    required this.photoUrls,
  });

  CafeSpot copyWith({
    String? id,
    String? name,
    String? category,
    String? city,
    String? address,
    String? mapsUrl,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? mustOrder,
    String? mustOrderPrice,
    List<String>? vibeTags,
    bool? isVisited,
    bool? isFavorite,
    String? notes,
    String? loggedDate,
    String? openingHours,
    String? distanceText,
    String? walkingTime,
    List<String>? photoUrls,
  }) {
    return CafeSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      city: city ?? this.city,
      address: address ?? this.address,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      mustOrder: mustOrder ?? this.mustOrder,
      mustOrderPrice: mustOrderPrice ?? this.mustOrderPrice,
      vibeTags: vibeTags ?? this.vibeTags,
      isVisited: isVisited ?? this.isVisited,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
      loggedDate: loggedDate ?? this.loggedDate,
      openingHours: openingHours ?? this.openingHours,
      distanceText: distanceText ?? this.distanceText,
      walkingTime: walkingTime ?? this.walkingTime,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  /// Parse from Map/JSON object (robust parsing for MockAPI data)
  factory CafeSpot.fromJson(Map<String, dynamic> json) {
    // Robust rating parser
    double parsedRating = 4.8;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else if (json['rating'] is String) {
        parsedRating = double.tryParse(json['rating']) ?? 4.8;
      }
    }

    // Robust reviewCount parser
    int parsedReviewCount = 24;
    if (json['reviewCount'] != null) {
      if (json['reviewCount'] is num) {
        parsedReviewCount = (json['reviewCount'] as num).toInt();
      } else if (json['reviewCount'] is String) {
        parsedReviewCount = int.tryParse(json['reviewCount']) ?? 24;
      }
    }

    // Robust boolean parser
    bool parseBool(dynamic val, bool defaultVal) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is String) {
        return val.toLowerCase() == 'true' || val == '1';
      }
      if (val is num) return val == 1;
      return defaultVal;
    }

    // Robust list parser
    List<String> parseStringList(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        return list.map((item) => item.toString()).toList();
      }
      if (list is String && list.isNotEmpty) {
        try {
          final decoded = jsonDecode(list);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          return [list];
        }
      }
      return [];
    }

    return CafeSpot(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Coffee Shop',
      city: json['city']?.toString() ?? 'Bandung',
      address: json['address']?.toString() ?? '',
      mapsUrl: json['mapsUrl']?.toString() ?? '',
      rating: parsedRating,
      reviewCount: parsedReviewCount,
      imageUrl: json['imageUrl']?.toString() ?? '',
      mustOrder: json['mustOrder']?.toString() ?? '',
      mustOrderPrice: json['mustOrderPrice']?.toString() ?? 'IDR 45.000',
      vibeTags: parseStringList(json['vibeTags']),
      isVisited: parseBool(json['isVisited'], true),
      isFavorite: parseBool(json['isFavorite'], false),
      notes: json['notes']?.toString() ?? '',
      loggedDate: json['loggedDate']?.toString() ?? 'Nov 2024',
      openingHours: json['openingHours']?.toString() ?? '08:00 AM – 10:00 PM',
      distanceText: json['distanceText']?.toString() ?? 'Nearby spot',
      walkingTime: json['walkingTime']?.toString() ?? '10 min walk',
      photoUrls: parseStringList(json['photoUrls']),
    );
  }

  /// Converts to exact 20-field Map for MockAPI
  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'name': name,
      'category': category,
      'city': city,
      'address': address,
      'mapsUrl': mapsUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'mustOrder': mustOrder,
      'mustOrderPrice': mustOrderPrice,
      'vibeTags': vibeTags,
      'isVisited': isVisited,
      'isFavorite': isFavorite,
      'notes': notes,
      'loggedDate': loggedDate,
      'openingHours': openingHours,
      'distanceText': distanceText,
      'walkingTime': walkingTime,
      'photoUrls': photoUrls,
    };
    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  Map<String, dynamic> toMap() => toJson(includeId: true);

  factory CafeSpot.fromMap(Map<String, dynamic> map) => CafeSpot.fromJson(map);

  String toJsonString() => json.encode(toJson());

  factory CafeSpot.fromJsonString(String source) => CafeSpot.fromJson(json.decode(source));
}
