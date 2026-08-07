import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

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
    
    // Inisialisasi video dari assets
    _controller = VideoPlayerController.asset("assets/video.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        // Hapus splash screen asli setelah video siap diputar
        FlutterNativeSplash.remove();
      });

    // Pindah ke halaman utama (Dashboard) setelah video selesai
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        // Ganti 'HomeScreen()' dengan widget dashboard monitoring kamu
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text("Dashboard")))),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Agar serasi dengan video
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: Colors.green),
      ),
    );
  }
}