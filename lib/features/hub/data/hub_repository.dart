import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/hub_service_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final hubRepositoryProvider = Provider<HubRepository>((ref) {
  return HubRepository(ref.watch(apiClientProvider));
});

class HubRepository {
  final ApiClient _api;

  HubRepository(this._api);

  /// `GET /api/hub/services` — katalog layanan fisik Panam Academy Hub.
  Future<HubCatalogModel> getServices() async {
    final data = await _api.get(ApiEndpoints.hubServices);
    return HubCatalogModel.fromJson(asJsonMap(data));
  }

  /// `POST /api/hub/book` — reservasi layanan offline.
  Future<HubBookingModel> book({
    required String serviceId,
    required String fullName,
    required String whatsapp,
    required String university,
    required String preferredDate,
    String? notes,
  }) async {
    final data = await _api.post(
      ApiEndpoints.hubBook,
      data: {
        'service_id': serviceId,
        'full_name': fullName,
        'whatsapp': whatsapp,
        'university': university,
        'preferred_date': preferredDate,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return HubBookingModel.fromJson(asJsonMap(data));
  }
}
