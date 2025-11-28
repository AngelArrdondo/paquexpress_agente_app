import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

import '../models/paquete.dart';
import '../services/paquete_service.dart';
import '../main.dart';

class EntregaScreen extends StatefulWidget {
  final Paquete paquete;
  const EntregaScreen({super.key, required this.paquete});

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  final PaqueteService _paqueteService = PaqueteService();

  CameraController? _cameraController;
  XFile? _capturedImage;
  Uint8List? _capturedImageBytes;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initCamera(); // solo Android/iOS
    }
  }

  Future<void> _initCamera() async {
    try {
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      debugPrint("Error al inicializar cámara móvil: $e");
    }
  }

  // --------------------------------------------------------
  // CAPTURA EN WEB → input type="file" (cámara o galería)
  // --------------------------------------------------------
  Future<void> _takePictureWeb() async {
    final input = html.FileUploadInputElement();
    input.accept = "image/*"; // cámara si existe, galería si no

    input.onChange.listen((event) async {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((event) {
        setState(() {
          _capturedImageBytes = reader.result as Uint8List;
        });
      });
    });

    input.click(); // abre selector de cámara/galería
  }


  // --------------------------------------------------------
  // CAPTURA MÓVIL
  // --------------------------------------------------------
  Future<void> _takePictureMobile() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cámara no lista')));
      return;
    }

    try {
      final picture = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = picture;
      });
    } catch (e) {
      debugPrint("Error tomar foto móvil: $e");
    }
  }

  // --------------------------------------------------------
  // REGISTRAR ENTREGA
  // --------------------------------------------------------
  Future<void> _handleEntrega() async {
    if (!kIsWeb && _capturedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debes tomar una foto.")));
      return;
    }

    if (kIsWeb && _capturedImageBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debes tomar una foto.")));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      bool ok;

      if (kIsWeb) {
        ok = await _paqueteService.registrarEntregaWeb(
          paqueteId: widget.paquete.id,
          lat: pos.latitude,
          lon: pos.longitude,
          bytes: _capturedImageBytes!,
        );
      } else {
        ok = await _paqueteService.registrarEntrega(
          paqueteId: widget.paquete.id,
          lat: pos.latitude,
          lon: pos.longitude,
          imagen: _capturedImage!,
        );
      }

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entrega registrada con éxito!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error al registrar entrega.")));
      }
    } catch (e) {
      debugPrint("Error entrega: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.paquete;

    return Scaffold(
      appBar: AppBar(
        title: Text("Entrega • ${p.paqueteId}"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildData(Icons.place, "Dirección", p.direccion),
                    _buildData(Icons.person, "Destinatario", p.destinatario),
                    _buildData(Icons.location_city, "Ciudad", p.ciudad),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildPhotoPreview(),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () =>
                  kIsWeb ? _takePictureWeb() : _takePictureMobile(),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar foto"),
            ),

            const SizedBox(height: 30),

            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleEntrega,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "ENTREGAR PAQUETE",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildData(IconData icon, String title, String? value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value ?? "—"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return SizedBox(
      height: 230,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Builder(builder: (context) {
          if (kIsWeb && _capturedImageBytes != null) {
            return Image.memory(_capturedImageBytes!, fit: BoxFit.cover);
          }
          if (!kIsWeb && _capturedImage != null) {
            return Image.file(File(_capturedImage!.path), fit: BoxFit.cover);
          }
          if (!kIsWeb &&
              _cameraController != null &&
              _cameraController!.value.isInitialized) {
            return CameraPreview(_cameraController!);
          }
          return const Center(child: Text("Sin foto"));
        }),
      ),
    );
  }
}
