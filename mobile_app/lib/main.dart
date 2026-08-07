import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding wb = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: wb);

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Kelembaban Tanah',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F8FF), // Light blue background
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const VideoSplashScreen());
}

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});
  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        FlutterNativeSplash.remove();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MonitoringPage()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white, // Agar serasi dengan video
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(100),
          child: _controller.value.isInitialized
              ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
              : const CircularProgressIndicator(color: Colors.blue),
        ),
      ));
}

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});
  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void _toggleMode(bool isManual) => _database.update({'mode_manual': isManual ? 1 : 0});
  void _setRelay(int status) => _database.update({'status_relay': status});

  String _getMoistureStatus(int h) => h < 40 ? 'KERING' : h <= 80 ? 'LEMBAB' : 'BASAH';
  
  Color _getMoistureColor(int h) {
    if (h < 40) return const Color(0xFFEF4444);     // Red
    if (h <= 80) return const Color(0xFFF59E0B);    // Orange
    return const Color(0xFF3B82F6);                 // Blue
  }

  IconData _getMoistureIcon(int h) => h < 40 ? Icons.water_drop_outlined : h <= 80 ? Icons.water_drop : Icons.water;

  @override
  Widget build(BuildContext context) => Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Monitoring Kelembaban Tanah", 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2FE), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: _database.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              int humidity = values['kelembaban'] ?? 0;
              bool isManual = values['mode_manual'].toString() == "1";
              bool relayOn = values['status_relay'].toString() == "1";

              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(children: [
                    const SizedBox(height: 20),

                    // Moisture Card - Modern Look
                    Card(
                      elevation: 10,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getMoistureIcon(humidity), color: _getMoistureColor(humidity), size: 28),
                              const SizedBox(width: 10),
                              const Text("Kelembaban Tanah", 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Stack(alignment: Alignment.center, children: [
                            SizedBox(
                              height: 160,
                              width: 160,
                              child: CircularProgressIndicator(
                                value: humidity / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(_getMoistureColor(humidity)),
                              ),
                            ),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Text("$humidity", 
                                  style: TextStyle(
                                    fontSize: 52, 
                                    fontWeight: FontWeight.bold, 
                                    color: _getMoistureColor(humidity)
                                  )),
                              const Text("%", style: TextStyle(fontSize: 20)),
                            ]),
                          ]),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: _getMoistureColor(humidity).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _getMoistureStatus(humidity),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getMoistureColor(humidity),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Mode Control
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: const Text("Mode Kontrol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(isManual ? "Manual (Tombol)" : "Otomatis (Sensor)"),
                        trailing: Switch(
                          value: isManual,
                          onChanged: _toggleMode,
                          activeColor: Colors.blue,
                          activeTrackColor: Colors.blue.withOpacity(0.4),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Relay Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isManual 
                              ? (relayOn ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 6,
                        ),
                        onPressed: isManual ? () => _setRelay(relayOn ? 0 : 1) : null,
                        icon: Icon(relayOn ? Icons.power_settings_new : Icons.water_drop, size: 26),
                        label: Text(
                          relayOn ? "MATIKAN KERAN" : "NYALAKAN KERAN",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isManual 
                            ? Colors.orange.shade50 
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isManual 
                              ? Colors.orange.shade200 
                              : Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isManual 
                            ? "Mode manual aktif: Kontrol keran melalui tombol di atas." 
                            : "Mode otomatis aktif: Keran bekerja berdasarkan sensor.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isManual 
                              ? Colors.orange.shade900 
                              : Colors.green.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ]),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          },
        ),
      ));
}