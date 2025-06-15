class PoiModel {
  final int id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final bool? verified;
  final double? distance;

  PoiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.verified,
    this.distance,
  });

  factory PoiModel.fromJson(Map<String, dynamic> json) {
    final rawLat = json['latitude'];
    final rawLng = json['longitude'];

    double parseCoord(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      throw FormatException('Invalid coordinate: $v');
    }

    // parse distance if present
    double? parseDistance(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return PoiModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      latitude: parseCoord(rawLat),
      longitude: parseCoord(rawLng),
      verified: json['verified'] as bool?,
      distance: parseDistance(json['distance']),
    );
  }
}
