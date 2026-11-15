import '../../network/json_utils.dart';

/// Layanan fisik Panam Academy Hub (O2O).
class HubServiceModel {
  final String id;
  final String name;
  final String tagline;
  final String category;
  final int priceIdr;
  final String priceFormatted;
  final String unit;
  final String location;
  final List<String> features;
  final bool isAvailable;

  const HubServiceModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.priceIdr,
    required this.priceFormatted,
    required this.unit,
    required this.location,
    required this.features,
    required this.isAvailable,
  });

  factory HubServiceModel.fromJson(Map<String, dynamic> json) {
    return HubServiceModel(
      id: pickString(json, ['id']),
      name: pickString(json, ['name']),
      tagline: pickString(json, ['tagline']),
      category: pickString(json, ['category']),
      priceIdr: pickInt(json, ['price_idr', 'priceIdr']),
      priceFormatted: pickString(json, ['price_formatted', 'priceFormatted']),
      unit: pickString(json, ['unit']),
      location: pickString(json, ['location']),
      features: pickList(json, ['features']).map((e) => e.toString()).toList(),
      isAvailable: pickBool(json, ['is_available', 'isAvailable'], fallback: true),
    );
  }
}

class HubCatalogModel {
  final String hubName;
  final String address;
  final String operationalHours;
  final List<HubServiceModel> services;

  const HubCatalogModel({
    required this.hubName,
    required this.address,
    required this.operationalHours,
    required this.services,
  });

  factory HubCatalogModel.fromJson(Map<String, dynamic> json) {
    return HubCatalogModel(
      hubName: pickString(json, ['hub_name', 'hubName']),
      address: pickString(json, ['address']),
      operationalHours:
          pickString(json, ['operational_hours', 'operationalHours']),
      services: pickMapList(json, ['services'])
          .map(HubServiceModel.fromJson)
          .toList(),
    );
  }
}

/// Respons `POST /api/hub/book`.
class HubBookingModel {
  final String bookingCode;
  final String serviceName;
  final String priceFormatted;
  final String preferredDate;
  final String status;
  final String instructions;

  const HubBookingModel({
    required this.bookingCode,
    required this.serviceName,
    required this.priceFormatted,
    required this.preferredDate,
    required this.status,
    required this.instructions,
  });

  factory HubBookingModel.fromJson(Map<String, dynamic> json) {
    final service = asJsonMap(pick(json, ['service']));
    return HubBookingModel(
      bookingCode: pickString(json, ['booking_code', 'bookingCode']),
      serviceName: pickString(service, ['name']),
      priceFormatted:
          pickString(service, ['price_formatted', 'priceFormatted']),
      preferredDate: pickString(json, ['preferred_date', 'preferredDate']),
      status: pickString(json, ['status']),
      instructions: pickString(json, ['instructions']),
    );
  }
}
