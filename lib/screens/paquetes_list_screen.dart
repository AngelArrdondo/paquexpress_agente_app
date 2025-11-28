// lib/screens/paquetes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/paquete_service.dart';
import '../models/paquete.dart';
import 'entrega_screen.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import '../main.dart' as app_main;

class PaquetesListScreen extends StatefulWidget {
  const PaquetesListScreen({super.key});

  @override
  State<PaquetesListScreen> createState() => _PaquetesListScreenState();
}

class _PaquetesListScreenState extends State<PaquetesListScreen> {
  late Future<List<Paquete>> _paquetesFuture;
  final PaqueteService _paqueteService = PaqueteService();

  List<Paquete> _paquetesCache = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _reloadFuture();
  }

  void _reloadFuture() {
    _paquetesFuture = _paqueteService.obtenerPaquetes().then((list) {
      _paquetesCache = list;
      return list;
    });
    setState(() {});
  }

  List<Paquete> _filtered(List<Paquete> list) {
    if (_searchQuery.trim().isEmpty) return list;

    final q = _searchQuery.toLowerCase().trim();

    return list.where((p) {
      final id = p.paqueteId?.toString().toLowerCase() ?? '';
      final dir = p.direccion?.toLowerCase() ?? '';
      final dest = p.destinatario?.toLowerCase() ?? '';

      return id.contains(q) || dir.contains(q) || dest.contains(q);
    }).toList();
  }

  Future<void> _handleLogout() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    await Provider.of<AuthProvider>(context, listen: false).logout();

    app_main.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'entregado':
        return Colors.green.shade700;
      case 'en_ruta':
        return Colors.blue.shade700;
      case 'pendiente':
      default:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas Asignadas'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadFuture,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por ID, dirección o destinatario',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    '${_paquetesCache.length}',
                    style: theme.textTheme.titleMedium,
                  ),
                )
              ],
            ),
          ),
        ),
      ),

      body: FutureBuilder<List<Paquete>>(
        future: _paquetesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.primaryColor),
                  const SizedBox(height: 12),
                  const Text('Cargando paquetes...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error al cargar paquetes', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _reloadFuture,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final paquetes = snapshot.data ?? [];
          final filtered = _filtered(paquetes);

          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _reloadFuture(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey),
                        SizedBox(height: 20),
                        Text("No hay paquetes disponibles."),
                      ],
                    ),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadFuture(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),

              itemBuilder: (context, index) {
                final paquete = filtered[index];
                final estado = paquete.estadoEntrega?.toLowerCase() ?? 'pendiente';
                final statusColor = _statusColor(estado);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EntregaScreen(paquete: paquete)),
                      );
                      _reloadFuture();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.local_shipping, color: statusColor, size: 30),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${paquete.paqueteId ?? paquete.id}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  paquete.direccion ?? 'Dirección no disponible',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        paquete.destinatario ?? '—',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor.withOpacity(0.18)),
                                ),
                                child: Text(
                                  estado.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              IconButton(
                                icon: const Icon(Icons.map_outlined),
                                onPressed: () {
                                  final address = paquete.direccion;
                                  if (address == null || address.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Dirección no disponible')),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MapScreen(direccion: address),
                                    ),
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
