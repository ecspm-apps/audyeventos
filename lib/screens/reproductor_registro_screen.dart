import 'package:flutter/material.dart';

class ReproductorRegistroScreen extends StatefulWidget {
  const ReproductorRegistroScreen({super.key});

  @override
  State<ReproductorRegistroScreen> createState() => _ReproductorRegistroScreenState();
}

class _ReproductorRegistroScreenState extends State<ReproductorRegistroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'AUDY EVENTOS',
              style: TextStyle(
                color: Color(0xFFADC6FF),
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFADC6FF)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: Stack(
        children: [
          // Background content
          Container(),
          // Registration Modal Overlay
          Container(
            color: Colors.black.withOpacity(0.6),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Registrarse para chatear', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text('Crea una cuenta para interactuar en el chat', style: TextStyle(color: Color(0xFF8B90A0))),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFADC6FF), minimumSize: const Size(double.infinity, 50)), child: const Text('REGISTRARSE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
