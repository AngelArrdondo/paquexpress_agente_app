import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'map_screen.dart';

class MapView extends StatelessWidget {
  final String direccion;
  const MapView({super.key, required this.direccion});

  @override
  Widget build(BuildContext context) {
    // Solo Web tiene vista previa del mapa
    if (!kIsWeb) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "El mapa solo está disponible en la versión Web.",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      );
    }

    // WEB → Vista previa clickeable
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapScreen(direccion: direccion),
          ),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          image: const DecorationImage(
            image: AssetImage('assets/map_placeholder.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
          child: const Text(
            "Ver ubicación en mapa",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
