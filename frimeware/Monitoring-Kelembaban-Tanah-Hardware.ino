#include <WiFi.h>
#include <FirebaseESP32.h>

// 1. Data WiFi
#define WIFI_SSID ""//Masukan id WI-FI
#define WIFI_PASSWORD ""//Masukan Password

// 2. Data Firebase
#define FIREBASE_HOST ""//Masukan URL Firebae RTDB
#define FIREBASE_AUTH ""//Masukan databases secrets

// Objek data Firebase
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Konfigurasi Pin
const int soilPin = 34;
const int relayPin = 25; 

void setup() {
  Serial.begin(115200);
  
  // Setup Pin Relay - High Trigger
  digitalWrite(relayPin, LOW); // Pompa mati saat awal
  pinMode(relayPin, OUTPUT);
  
  // Koneksi ke WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected!");
  
  // Konfigurasi Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  if (Firebase.ready()) {
    // 1. Ambil Mode (Manual atau Otomatis) dari Firebase
    int modeManual = 0;
    if (Firebase.getInt(fbdo, "/mode_manual")) {
      modeManual = fbdo.intData();
    }
    
    // 2. Baca Sensor & Hitung Kelembaban
    int rawValue = analogRead(soilPin);
    int humidity = map(rawValue, 2600, 950, 0, 100);
    humidity = constrain(humidity, 0, 100);
    
    // Menentukan Status Tanah untuk Serial Monitor
    String statusTanah;
    if (humidity < 40) statusTanah = "KERING";
    else if (humidity <= 80) statusTanah = "LEMBAB";
    else statusTanah = "BASAH";
    
    // HANYA MENGIRIM DATA PERSENTASE KELEMBABAN KE FIREBASE
    Firebase.setInt(fbdo, "/kelembaban", humidity); 
    
    if (modeManual == 1) {
      // --- MODE MANUAL ---
      if (Firebase.getInt(fbdo, "/status_relay")) {
        int perintahStatus = fbdo.intData(); 
        if (perintahStatus == 1) {
          digitalWrite(relayPin, HIGH); // NYALA
        } else {
          digitalWrite(relayPin, LOW);  // MATI
        }
      }
      
      // Indikator Serial Monitor
      Serial.print("Mode: MANUAL | Sensor: ");
      Serial.print(rawValue);
      Serial.print(" | Kelembaban: ");
      Serial.print(humidity);
      Serial.print("% (");
      Serial.print(statusTanah);
      Serial.print(") | Relay: ");
      Serial.println(digitalRead(relayPin) == HIGH ? "ON" : "OFF");
    } 
    else {
      // --- MODE OTOMATIS ---
      if (humidity <= 40) { 
        digitalWrite(relayPin, HIGH); // NYALA
        Firebase.setInt(fbdo, "/status_relay", 1); 
      } 
      else if (humidity >= 80) {
        digitalWrite(relayPin, LOW); // MATI
        Firebase.setInt(fbdo, "/status_relay", 0); 
      }
      
      // Indikator Serial Monitor
      Serial.print("Mode: OTOMATIS | Sensor: ");
      Serial.print(rawValue);
      Serial.print(" | Kelembaban: ");
      Serial.print(humidity);
      Serial.print("% (");
      Serial.print(statusTanah);
      Serial.print(") | Relay: ");
      Serial.println(digitalRead(relayPin) == HIGH ? "ON" : "OFF");
    }
  }
  delay(1300); 
}