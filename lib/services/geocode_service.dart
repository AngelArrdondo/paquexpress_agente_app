// lib/services/geocode_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodeResult {
  final LatLng latLng;
  final String displayName;

  GeocodeResult(this.latLng, this.displayName);
}

class GeocodeService {
  // Caché simple en memoria
  final Map<String, GeocodeResult> _cache = {};

  Future<GeocodeResult?> geocode(String direccion) async {
    final key = direccion.trim().toLowerCase();
    if (key.isEmpty) return null;

    // Si ya está en cache, devolver rápido
    if (_cache.containsKey(key)) return _cache[key];

    final Uri url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=${Uri.encodeComponent(direccion)}"
      "&format=json&limit=1"
    );

    try {
      final response = await http.get(
        url,
        headers: {
          // Obligatorio para Nominatim
          'User-Agent': 'PaquexpressApp/1.0 (contacto@paquexpress.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) return null;

      final first = data.first;

      // LAT / LON seguros
      final latRaw = first["lat"] ?? first["latitude"];
      final lonRaw = first["lon"] ?? first["longitude"];

      final lat = double.tryParse(latRaw?.toString() ?? "");
      final lon = double.tryParse(lonRaw?.toString() ?? "");

      if (lat == null || lon == null) return null;

      final displayName = first["display_name"]?.toString() ?? direccion;

      final result = GeocodeResult(LatLng(lat, lon), displayName);

      // Guardar cache
      _cache[key] = result;

      return result;
    } catch (e) {
      print("[GeocodeService] Error: $e");
      return null;
    }
  }
}
