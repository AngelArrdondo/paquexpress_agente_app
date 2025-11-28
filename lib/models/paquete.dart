// lib/models/paquete.dart
class Paquete {
  final int id;
  final String paqueteId;
  final String direccion;
  final String ciudad;
  final String estado;
  final String codigoPostal;
  final String destinatario;
  final String estadoEntrega;

  Paquete({
    required this.id,
    required this.paqueteId,
    required this.direccion,
    required this.ciudad,
    required this.estado,
    required this.codigoPostal,
    required this.destinatario,
    required this.estadoEntrega,
  });

  factory Paquete.fromJson(Map<String, dynamic> json) {
    return Paquete(
      id: json["id"],
      paqueteId: json["paquete_id"],
      direccion: json["direccion"],
      ciudad: json["ciudad"],
      estado: json["estado"],
      codigoPostal: json["codigo_postal"],
      destinatario: json["destinatario"],
      estadoEntrega: json["estado_entrega"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "paquete_id": paqueteId,
      "direccion": direccion,
      "ciudad": ciudad,
      "estado": estado,
      "codigo_postal": codigoPostal,
      "destinatario": destinatario,
      "estado_entrega": estadoEntrega,
    };
  }
}
