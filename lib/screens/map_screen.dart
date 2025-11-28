import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/geocode_service.dart';

class MapScreen extends StatefulWidget {
  final String direccion;
  const MapScreen({super.key, required this.direccion});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GeocodeService _geocodeService = GeocodeService();
  LatLng? _coords;
  String? _display;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGeocode();
  }

  Future<void> _loadGeocode() async {
    try {
      final result = await _geocodeService.geocode(widget.direccion);

      if (result == null) {
        setState(() {
          _error = "No se encontró la ubicación para esta dirección.";
          _loading = false;
        });
        return;
      }

      setState(() {
        _coords =
            LatLng(result.latLng.latitude, result.latLng.longitude);
        _display = result.displayName;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error geocodificando dirección:\n$e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ver en mapa")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (_coords == null) {
      return const Scaffold(
        body: Center(
          child: Text("No se pudo obtener coordenadas."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_display ?? "Mapa"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _coords!,
          initialZoom: 16,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: _coords!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
