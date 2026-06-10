import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'inicio_inmersivo_screen.dart';
import 'cartelera_screen.dart';
import 'reproductor_chat_screen.dart';
import 'reproductor_ingreso_nombre_screen.dart';
import '../services/database_service.dart';
import '../models/evento.dart';

class RecientesScreen extends StatelessWidget {
  RecientesScreen({super.key});

  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
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
      body: StreamBuilder<List<Evento>>(
        stream: _dbService.getEventosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFADC6FF)));
          }

          final rawEventos = snapshot.data ?? [];
          final now = DateTime.now();
          final eventos = rawEventos.where((evento) {
            final eventTime = Evento.parseFechaHora(evento.fechaHora);
            if (eventTime == null) return false;
            final expirationTime = eventTime.add(const Duration(days: 15));
            final isFinished = now.isAfter(eventTime) && evento.finStream;
            return isFinished && now.isBefore(expirationTime);
          }).toList()
            ..sort((a, b) {
              final timeA = Evento.parseFechaHora(a.fechaHora) ?? DateTime.fromMillisecondsSinceEpoch(0);
              final timeB = Evento.parseFechaHora(b.fechaHora) ?? DateTime.fromMillisecondsSinceEpoch(0);
              return timeB.compareTo(timeA); // Más recientes primero
            });

          if (eventos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 24),
                  const Text(
                    'No hay eventos recientes',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Por ahora no hay transmisiones pasadas disponibles. Vuelve más tarde.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8B90A0), fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Eventos recientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  height: 4,
                  width: 48,
                  color: const Color(0xFFADC6FF),
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                ),
                ...eventos.map((evento) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildEventCard(context, evento),
                )),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InicioInmersivoScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CarteleraScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Evento evento) {
    final isFree = evento.modo == 'libre';
    final dateTime = Evento.parseFechaHora(evento.fechaHora);
    String dateFormatted;
    String timeFormatted;
    if (dateTime != null) {
      dateFormatted = DateFormat('dd MMM yyyy').format(dateTime);
      timeFormatted = DateFormat('HH:mm a').format(dateTime);
    } else {
      dateFormatted = evento.fechaHora.isNotEmpty ? evento.fechaHora : 'FECHA NO DISPONIBLE';
      timeFormatted = '';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  evento.aficheHorizontal,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: const Color(0xFF131313),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.titulo,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evento.tipo,
                        style: const TextStyle(color: Color(0xFFADC6FF), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFFADC6FF)),
                const SizedBox(width: 4),
                Text(
                  dateFormatted,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (timeFormatted.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.schedule, size: 14, color: Color(0xFFADC6FF)),
                  const SizedBox(width: 4),
                  Text(
                    timeFormatted,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
                const Spacer(),
                if (isFree)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReproductorChatScreen(isExclusive: false, evento: evento),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, size: 14, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'VER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReproductorIngresoNombreScreen(evento: evento),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A0DAD),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'VER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
