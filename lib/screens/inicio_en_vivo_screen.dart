import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class InicioEnVivoScreen extends StatelessWidget {
  const InicioEnVivoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFADC6FF)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const [],
      ),
      body: Stack(
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida/AP1WRLtZb_8hbwlFDDDGE9vYPkFilPZFcDNzlhpjaett_MhU8bloSmuN4ZtuLOT7Nx06F2-ovA0di-7D5JShMWhJHmY9cM7XnKs-oVSBMCXmiVYUmcfGSCgODpuk0__0QD3WyM-wQo29u4K-mijQg56t84yoTkeE3S5Cy6cmsNPPtKR_9TeJ4iXH4270j3Ol3waugYE4mMf7sJlQgm3cbvnYpCBbrFRihnzlTtA0H_DnRq2fq82M7tLQiNBEyKY',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black, Colors.transparent]))),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFADC6FF), borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.play_arrow, size: 50, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 10, color: Colors.white), SizedBox(width: 6), Text('EN VIVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                ),
                const SizedBox(height: 10),
                const Text('Ministerio JAYAMARA desde Oruro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: const Color(0xFFADC6FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'INICIO'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'CARTELERA'),
        ],
      ),
    );
  }
}
