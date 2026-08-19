class ZoneModel {
  String? success;
  String? error;
  String? message;
  List<ZoneData>? data;

  ZoneModel({this.success, this.error, this.message, this.data});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    // Safely parse data list - handle String, List, or null
    var dataRaw = json['data'];
    if (dataRaw != null && dataRaw is List && dataRaw.isNotEmpty) {
      data = <ZoneData>[];
      for (var v in dataRaw) {
        data!.add(ZoneData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ZoneData {
  int? id;
  String? name;
  String? description;
  int? parentId;
  String? zoneType;
  int? priority;
  String? status;
  String? inPrice;
  String? outPrice;
  String? pricingType;
  String? priceFrom;
  String? priceTo;
  String? createdAt;
  String? updatedAt;

  ZoneData({
    this.id,
    this.name,
    this.description,
    this.parentId,
    this.zoneType,
    this.priority,
    this.status,
    this.inPrice,
    this.outPrice,
    this.pricingType,
    this.priceFrom,
    this.priceTo,
    this.createdAt,
    this.updatedAt,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    parentId = json['parent_id'];
    zoneType = json['zone_type'];
    priority = json['priority'];
    status = json['status'];
    inPrice = json['in_price']?.toString();
    outPrice = json['out_price']?.toString();
    pricingType = json['pricing_type'];
    priceFrom = json['price_from']?.toString();
    priceTo = json['price_to']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['parent_id'] = parentId;
    data['zone_type'] = zoneType;
    data['priority'] = priority;
    data['status'] = status;
    data['in_price'] = inPrice;
    data['out_price'] = outPrice;
    data['pricing_type'] = pricingType;
    data['price_from'] = priceFrom;
    data['price_to'] = priceTo;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  /// Get zone type display name with emoji
  String get zoneTypeDisplay {
    switch (zoneType) {
      case 'country':
        return '🌍 Country/Region';
      case 'city':
        return '🏙️ City';
      case 'area':
        return '📍 Area/District';
      case 'neighborhood':
        return '🏘️ Neighborhood';
      default:
        return name ?? '';
    }
  }
}
