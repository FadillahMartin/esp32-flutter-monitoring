# Panduan Konfigurasi & Integrasi Sistem Monitoring ESP32, Firebase, dan Flutter
---
## 1. Kebutuhan Board ESP32 (Arduino IDE)

Sebelum dapat memprogram board ESP32, Anda perlu menambahkan dukungan board ESP32 di Arduino IDE:

1. Buka menu **Tools > Board > Boards Manager**, cari `esp32` (oleh Espressif Systems), lalu klik **Install**.
2. Setelah selesai, pilih board Anda melalui **Tools > Board > esp32 > ESP32 Dev Module**.





---
## 2. Kebutuhan Library (Arduino IDE)

Sebelum melakukan upload program ke ESP32, pastikan library berikut sudah terinstal di Arduino IDE (melalui **Tools > Manage Libraries**):

* **Firebase ESP32 Client** (oleh Mobizt) – Digunakan untuk menghubungkan ESP32 ke Firebase Realtime Database.
* **WiFi** (Bawaan board ESP32) – Digunakan untuk mengelola koneksi internet pada ESP32.





---
## 3. Skema Wiring / Pengkabelan (ESP32)

Berikut adalah petunjuk sambungan pin antara komponen hardware dan ESP32:

### A. Sensor Kelembaban Tanah (Soil Moisture Sensor)

| **Pin Sensor**      | **Pin ESP32**         |
| VCC                 | Pin 3.3V / 5V ESP32   |
| GND                 | Pin GND ESP32         |
| A0(Analog Output)   | Pin GPIO 34 ESP32     |

### B. Modul Relay (Active High)

| **Pin Modul Relay**   | **Pin ESP32**      |
| VCC                   | Pin 5V / VIN ESP32 |
| GND                   | Pin GND ESP32      |
| IN / Signal           | Pin GPIO 25 ESP32  |





---
## 4. Konfigurasi pada Firebase Console

### A. Membuat Proyek Firebase Baru

1. Buka browser dan masuk ke [Firebase Console](https://console.firebase.google.com/).
2. Klik tombol **Add Project**.
3. Masukkan nama proyek Anda, contoh: `“MonitoringTanah”`, lalu klik **Continue**.
4. Pada pilihan Google Analytics, Anda bisa menonaktifkannya (**Disable**) untuk mempercepat proses pembuatan, lalu klik **Create Project**.
5. Tunggu hingga proyek selesai dibuat, lalu klik **Continue**.

### B. Membuat Realtime Database

1. Di dashboard utama Firebase, buka menu sidebar di sebelah kiri, klik **Build > Realtime Database**.
2. Klik tombol **Create Database**.
3. Pilih lokasi server terdekat (disarankan **Singapore / asia-southeast1** untuk akses lebih cepat dari Indonesia), klik **Next**.
4. Pada pilihan Security Rules, pilih **Start in test mode** (Mode Pengujian) agar database bisa diakses langsung selama masa pengembangan, lalu klik **Enable**.

### C. Mengubah Rules Database (Penting)

1. Masuk ke tab **Rules** di bagian atas halaman Realtime Database.
2. Ubah struktur kodenya menjadi seperti berikut:
   ```json
   {
     "rules": {
       ".read": "true",
       ".write": "true"
     }
   }
   ```
3. Klik tombol **Publish** di pojok kanan atas untuk menyimpan perubahan.





---
## 5. Integrasi ke Aplikasi Flutter

### A. Mendaftarkan Aplikasi Android ke Firebase

1. Kembali ke halaman utama **Project Overview** di Firebase Console.
2. Klik ikon **Android** (logo robot) untuk mulai mendaftarkan aplikasi mobile Anda.
3. Masukkan Android package name. Anda bisa mengecek nama paket ini di dalam proyek Flutter Anda pada file: `android/app/build.gradle` (cari baris `applicationId`, contoh: `com.example.monitoring_tanah`).
4. (Opsional) Masukkan nama alias aplikasi.
5. Klik tombol **Register app**.

### B. Mengunduh dan Memasang `google-services.json`

1. Setelah aplikasi terdaftar, Firebase akan memunculkan tombol **Download google-services.json**. Klik tombol tersebut untuk mengunduh file konfigurasinya.
2. Buka folder proyek Flutter Anda menggunakan VS Code atau File Explorer.
3. Pindahkan file `google-services.json` yang baru diunduh ke dalam folder:
   ```
   [Folder_Proyek_Flutter]/android/app/
   ```
   *\*Pastikan file diletakkan tepat di dalam folder `app`, bukan hanya di folder `android`.*






---
## 6. Integrasi ke Perangkat Keras (ESP32)

### A. Mengambil Firebase Auth (Database Secrets)

1. Di Firebase Console, klik ikon **Gigi Roda** (**Project Settings**) di pojok kiri atas, di samping tulisan **"Project Overview"**.
2. Pilih **Project Settings**.
3. Masuk ke tab **Service Accounts** di bagian atas.
4. Klik menu sub-tab **Database secrets** di panel bagian bawah.
5. Arahkan kursor ke kode token yang tersamar, lalu klik tombol **Show** dan **Copy**.

### B. Memasukkan Kredensial ke Code Arduino IDE

1. Masukkan URL Realtime Database tanpa tanda `"https://"` dan tanpa `"/"` di ujungnya:
   #define FIREBASE_HOST "Masukan URL Firebase RTDB"
   
2. Tempelkan Database Secret / Token Auth yang Anda salin dari langkah sebelumnya:
   #define FIREBASE_AUTH " Masukan Database Secret "






---
## 7. Pengujian Akhir

1. Hubungkan ESP32 ke komputer, lakukan **Compile** dan **Upload** program melalui Arduino IDE.
2. Buka **Serial Monitor** pada Baud Rate `115200`. Pastikan status memunculkan tulisan `Connected!`.
3. Jalankan aplikasi Flutter Anda di emulator atau perangkat fisik (HP asli).
4. Amati halaman Realtime Database di Firebase Console. Struktur data baru bernama `/kelembaban`, `/mode_manual`, dan `/status_relay` akan terbentuk dan nilainya akan berubah secara dinamis saat sistem mendeteksi perubahan kondisi tanah atau saat tombol di aplikasi Flutter ditekan.
