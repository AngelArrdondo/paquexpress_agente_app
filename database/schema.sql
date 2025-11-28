-- schema.sql
CREATE DATABASE IF NOT EXISTS paquexpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE paquexpress;

-- Usuarios (agentes)
CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  rol VARCHAR(50) DEFAULT 'agente',
  creado_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Paquetes
CREATE TABLE IF NOT EXISTS paquetes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  paquete_id VARCHAR(100) NOT NULL UNIQUE,
  direccion VARCHAR(255) NOT NULL,
  ciudad VARCHAR(100),
  estado VARCHAR(100),
  codigo_postal VARCHAR(20),
  destinatario VARCHAR(150),
  asignado_a INT NULL,
  estado_entrega VARCHAR(50) DEFAULT 'pendiente',
  creado_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (asignado_a) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- Entregas (evidencias)
CREATE TABLE IF NOT EXISTS entregas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  paquete_id INT NOT NULL,
  agente_id INT NOT NULL,
  lat DECIMAL(10,7) NULL,
  lon DECIMAL(10,7) NULL,
  foto_path VARCHAR(255),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (paquete_id) REFERENCES paquetes(id) ON DELETE CASCADE,
  FOREIGN KEY (agente_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Datos de ejemplo
INSERT INTO usuarios (username, nombre, password_hash, rol) VALUES
('agente1', 'Juan Perez', '$2b$12$EXAMPLE_HASH_DO_NOT_USE', 'agente'); -- Reemplaza password_hash con bcrypt

INSERT INTO paquetes (paquete_id, direccion, ciudad, estado, codigo_postal, destinatario, asignado_a)
VALUES
('PKG-0001', 'Calle Falsa 123', 'Ciudad', 'Estado', '00000', 'Maria Gomez', 1),
('PKG-0002', 'Av. Principal 45', 'Ciudad', 'Estado', '00000', 'Carlos Ruiz', 1);
