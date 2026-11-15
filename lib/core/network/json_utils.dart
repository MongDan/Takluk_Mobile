/// Helper pembacaan JSON yang toleran terhadap dua gaya penamaan dari backend:
/// `snake_case` (mayoritas endpoint) dan `camelCase` (beberapa endpoint Drizzle).
///
/// Contoh: [pick] pada `{'semesterTarget': 1}` dengan keys
/// `['semester_target', 'semesterTarget']` tetap mengembalikan `1`.
dynamic pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) return json[key];
  }
  return null;
}

String pickString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  final value = pick(json, keys);
  if (value == null) return fallback;
  return value.toString();
}

String? pickStringOrNull(Map<String, dynamic> json, List<String> keys) {
  final value = pick(json, keys);
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int pickInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  final value = pick(json, keys);
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? pickIntOrNull(Map<String, dynamic> json, List<String> keys) {
  final value = pick(json, keys);
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double pickDouble(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  final value = pick(json, keys);
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool pickBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  final value = pick(json, keys);
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

DateTime? pickDate(Map<String, dynamic> json, List<String> keys) {
  final value = pick(json, keys);
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<dynamic> pickList(Map<String, dynamic> json, List<String> keys) {
  final value = pick(json, keys);
  if (value is List) return value;
  return const [];
}

List<Map<String, dynamic>> pickMapList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  return pickList(json, keys)
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}
