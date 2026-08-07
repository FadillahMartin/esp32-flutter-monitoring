# IoT Soil Moisture Monitoring System

Sistem monitoring kelembaban tanah berbasis IoT menggunakan ESP32, sensor kelembaban tanah kapasitif, Firebase Realtime Database, dan aplikasi mobile Flutter.

## 📌 Fitur Utama
- Real-time monitoring data kelembaban tanah via aplikasi Flutter.
- Kalibrasi sensor kapasitif untuk pengukuran yang akurat.
- Mode kontrol manual dan otomatis untuk sistem irigasi.
- Integrasi Firebase Realtime Database untuk sinkronisasi data instan.

## 🛠️ Ringkasan Komponen
- **Hardware:** ESP32, Capacitive Soil Moisture Sensor, Relay
- **Mobile App:** Flutter & Dart
- **Backend/Database:** Firebase Realtime Database
- **IDE:** Arduino IDE & VS Code

## 📁 Struktur Repositori
- `firmware/` : Kode program C++ / Arduino IDE untuk ESP32.
- `mobile_app/` : Source code aplikasi Flutter.
- `docs/` : Panduan integrasi Firebase, ESP32, dan Flutter.

## 📖 Panduan Integrasi
Untuk panduan langkah demi langkah mengenai konfigurasi Firebase, pengunggahan kode ke ESP32, dan integrasi Flutter, silakan baca [Panduan Integrasi Firebase & ESP32](docs/panduan-integrasi.md).