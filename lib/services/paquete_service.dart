// lib/services/paquete_service.dart
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../models/paquete.dart';
import 'auth_service.dart';
import '../main.dart' as app_main;
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

const String API_BASE_URL = "http://192.168.1.71:8000";

class PaqueteService {
  final AuthService _authService = AuthService();

  // -------------------------------------------
  // OBTENER PAQUETES
  // -------------------------------------------
  Future<List<Paquete>> obtenerPaquetes() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$API_BASE_URL/paquetes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return List<Paquete>.from(
        data.map((e) => Paquete.fromJson(e)),
      );
    }

    if (response.statusCode == 401) {
      final ctx = app_main.navigatorKey.currentContext;
      if (ctx != null) {
        Provider.of<AuthProvider>(ctx, listen: false).logout();
      }
      throw Exception("Sesión expirada. Inicie sesión de nuevo.");
    }

    throw Exception("Error al obtener paquetes: ${response.statusCode}");
  }

  // -------------------------------------------
  // REGISTRAR ENTREGA — ANDROID / IOS
  // -------------------------------------------
  Future<bool> registrarEntrega({
    required int paqueteId,
    required double lat,
    required double lon,
    required XFile imagen,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final uri = Uri.parse("$API_BASE_URL/entregar");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json"
    });

    // Campos
    request.fields["paquete_id"] = paqueteId.toString();
    request.fields["lat"] = lat.toString();
    request.fields["lon"] = lon.toString();

    // MÓVIL: archivo desde path
    final mime = imagen.path.toLowerCase().endsWith(".png")
        ? MediaType("image", "png")
        : MediaType("image", "jpeg");

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imagen.path,
        filename: imagen.name,
        contentType: mime,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      print("Entrega registrada (MOVIL): ${response.body}");
      return true;
    }

    print("Error entrega MOVIL (${response.statusCode}): ${response.body}");
    return false;
  }

  // -------------------------------------------
  // REGISTRAR ENTREGA — WEB (bytes)
  // -------------------------------------------
  Future<bool> registrarEntregaWeb({
    required int paqueteId,
    required double lat,
    required double lon,
    required Uint8List bytes,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final uri = Uri.parse("$API_BASE_URL/entregar");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json"
    });

    request.fields["paquete_id"] = paqueteId.toString();
    request.fields["lat"] = lat.toString();
    request.fields["lon"] = lon.toString();

    // Detectar PNG vs JPEG por los "magic numbers"
    bool isPng = bytes.length > 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;

    final file = http.MultipartFile.fromBytes(
      "file",
      bytes,
      filename: isPng ? "captura_web.png" : "captura_web.jpg",
      contentType: isPng
          ? MediaType("image", "png")
          : MediaType("image", "jpeg"),
    );

    request.files.add(file);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      print("Entrega registrada (WEB): ${response.body}");
      return true;
    }

    print("Error entrega WEB (${response.statusCode}): ${response.body}");
    return false;
  }
}
