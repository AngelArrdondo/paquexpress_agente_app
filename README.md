# 📦 Paquexpress Agente App

Aplicación móvil desarrollada en Flutter para agentes de entrega de **Paquexpress S.A. de C.V.**, diseñada para mejorar la trazabilidad y seguridad en el proceso de distribución de paquetes a nivel nacional.

## 🎯 Características Principales

- ✅ **Autenticación segura** con JWT y encriptación de contraseñas (Bcrypt)
- 📸 **Captura de evidencia fotográfica** al momento de la entrega
- 📍 **Geolocalización GPS** para registrar la ubicación exacta de entrega
- 🗺️ **Visualización en mapas interactivos** (OpenStreetMap)
- 🔍 **Búsqueda y filtrado** de paquetes asignados
- 🔄 **Sincronización en tiempo real** con API REST
- 📱 **Compatibilidad multiplataforma**: Web, Android e iOS

## 🏗️ Arquitectura del Sistema

### Stack Tecnológico

- **Frontend**: Flutter 3.4.3+
- **Backend**: FastAPI (Python)
- **Base de Datos**: MySQL 8.0+
- **Autenticación**: JWT (JSON Web Tokens)
- **Mapas**: OpenStreetMap + flutter_map
- **Geocodificación**: Nominatim API

### Estructura del Proyecto
```
paquexpress_agente_app/
├── lib/
│   ├── models/           # Modelos de datos (Paquete)
│   ├── providers/        # Gestión de estado (AuthProvider)
│   ├── services/         # Lógica de negocio (API calls)
│   ├── screens/          # Pantallas de la aplicación
│   └── main.dart         # Punto de entrada
├── assets/               # Recursos multimedia
├── android/              # Configuración Android
├── ios/                  # Configuración iOS
├── macos/                # Configuración macOS
├── windows/              # Configuración Windows
├── linux/                # Configuración Linux
├── build/                # Archivos generados de compilación
├── test/                 # Pruebas unitarias
├── pubspec.yaml           # Dependencias y configuración de Flutter
├── pubspec.lock           # Registro de versiones de dependencias
├── analysis_options.yaml  # Reglas de análisis de código
├── devtools_options.yaml  # Configuración de DevTools
├── paquexpress_agente_app.iml  # Configuración del IDE
└── venv/                 # Entorno virtual (si lo estás usando)

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK >= 3.4.3
- Python 3.9+
- MySQL 8.0+
- Android Studio / Xcode (para emuladores)

### 1️⃣ Configuración de la Base de Datos
```bash
# Acceder a MySQL
mysql -u root -p

# Crear la base de datos
source database/schema.sql

# Crear usuario de prueba (contraseña: "agente123")
INSERT INTO usuarios (username, nombre, password_hash, rol) VALUES
('agente1', 'Juan Pérez', '$2b$12$HASH_BCRYPT_AQUI', 'agente');
```

### 2️⃣ Configuración del Backend (FastAPI)
```bash
cd api

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install fastapi uvicorn sqlalchemy pymysql python-jose passlib python-multipart

# Configurar credenciales de BD en main.py
DATABASE_URL = "mysql+pymysql://root:TU_PASSWORD@localhost:3306/paquexpress"

# Ejecutar servidor
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 3️⃣ Configuración de la App Flutter
```bash
# Instalar dependencias
flutter pub get

# Configurar URL de API en lib/services/auth_service.dart y paquete_service.dart
const String API_BASE_URL = "http://TU_IP:8000";  # Ej: http://192.168.1.71:8000

# Ejecutar en navegador (Web)
flutter run -d chrome

# Ejecutar en Android
flutter run

# Ejecutar en iOS
flutter run -d ios
```

## 📱 Uso de la Aplicación

### 1. Inicio de Sesión
- **Usuario**: `agente1`
- **Contraseña**: `agente123`

### 2. Lista de Paquetes
- Visualiza todos los paquetes asignados
- Busca por ID, dirección o destinatario
- Pull-to-refresh para actualizar

### 3. Registrar Entrega
1. Selecciona un paquete de la lista
2. Captura una fotografía como evidencia
3. El sistema obtiene automáticamente tu ubicación GPS
4. Presiona "ENTREGAR PAQUETE" para confirmar

### 4. Visualizar Mapa (solo Web)
- Click en el ícono de mapa para ver la ubicación del destino
- Navegación interactiva con OpenStreetMap

## 🔐 Seguridad Implementada

| Característica | Implementación |
|----------------|----------------|
| Autenticación | JWT con expiración de 24 horas |
| Contraseñas | Bcrypt con salt automático (passlib) |
| Sesiones | Token almacenado en SharedPreferences |
| Comunicación | CORS configurado, validación de Content-Type |
| Archivos | Solo JPG/PNG permitidos, validación MIME |

## 📚 Dependencias Principales
```yaml
dependencies:
  provider: ^6.1.1          # Gestión de estado
  http: ^1.2.1              # Peticiones HTTP
  shared_preferences: ^2.2.2 # Almacenamiento local
  camera: ^0.10.5+9         # Acceso a cámara
  geolocator: ^11.0.0       # GPS/ubicación
  flutter_map: ^6.1.0       # Mapas interactivos
  latlong2: ^0.9.1          # Coordenadas geográficas
  http_parser: ^4.0.2       # Parsing multipart
```

## 🗄️ Modelo de Base de Datos

### Tabla: `usuarios`
- `id` (PK), `username`, `nombre`, `password_hash`, `rol`, `creado_at`

### Tabla: `paquetes`
- `id` (PK), `paquete_id`, `direccion`, `ciudad`, `estado`, `codigo_postal`
- `destinatario`, `asignado_a` (FK), `estado_entrega`, `creado_at`

### Tabla: `entregas`
- `id` (PK), `paquete_id` (FK), `agente_id` (FK), `lat`, `lon`
- `foto_path`, `timestamp`

## 🛠️ Solución de Problemas

### Error: "No se puede conectar a la API"
```bash
# Verifica que el servidor FastAPI esté corriendo
curl http://localhost:8000/paquetes

# Actualiza la IP en los servicios de Flutter
# Usa tu IP local, no 127.0.0.1 pa