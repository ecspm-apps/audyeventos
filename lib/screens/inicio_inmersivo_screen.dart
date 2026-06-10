import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/app_drawer.dart';
import '../services/database_service.dart';
import '../models/evento.dart';
import 'cartelera_screen.dart';
import 'recientes_screen.dart';
import 'reproductor_chat_screen.dart';
import 'reproductor_ingreso_nombre_screen.dart';

class InicioInmersivoScreen extends StatelessWidget {
  final bool hasEvents;
  const InicioInmersivoScreen({super.key, this.hasEvents = true});

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
      body: StreamBuilder<List<Evento>>(
        stream: DatabaseService().getEventosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFADC6FF)));
          }

          final rawEventos = snapshot.data ?? [];
          final now = DateTime.now();
          final eventos = rawEventos.where((evento) {
            final eventTime = Evento.parseFechaHora(evento.fechaHora);
            if (eventTime == null) return true;
            final isFinished = now.isAfter(eventTime) && evento.finStream;
            return !isFinished;
          }).toList()
            ..sort((a, b) {
              final timeA = Evento.parseFechaHora(a.fechaHora) ?? DateTime.fromMillisecondsSinceEpoch(0);
              final timeB = Evento.parseFechaHora(b.fechaHora) ?? DateTime.fromMillisecondsSinceEpoch(0);
              return timeA.compareTo(timeB);
            });

          if (eventos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 24),
                  const Text(
                    'No hay eventos por ahora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Estamos preparando nuevas experiencias. Próximamente más eventos increíbles para ti.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8B90A0),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show the top (first) active event
          final topEvento = eventos.first;
          final isFree = topEvento.modo == 'libre';
          final dateTime = Evento.parseFechaHora(topEvento.fechaHora);
          String dateTimeFormatted;
          if (dateTime != null) {
            final dateStr = DateFormat('dd MMM yyyy').format(dateTime).toUpperCase();
            final timeStr = DateFormat('HH:mm a').format(dateTime);
            dateTimeFormatted = '$dateStr • $timeStr';
          } else {
            dateTimeFormatted = topEvento.fechaHora.isNotEmpty ? topEvento.fechaHora : 'FECHA NO DISPONIBLE';
          }

          return Stack(
            children: [
              // Featured Stream Image (using vertical poster for full screen background)
              Positioned.fill(
                child: Image.network(
                  topEvento.aficheVertical.isNotEmpty ? topEvento.aficheVertical : topEvento.aficheHorizontal,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
              // Dark gradient overlay for text legibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Meta Content
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (isFree) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReproductorChatScreen(isExclusive: false, evento: topEvento),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReproductorIngresoNombreScreen(evento: topEvento),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isFree ? Colors.amber : const Color(0xFF6A0DAD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isFree ? Icons.play_arrow : Icons.lock,
                                  size: 20,
                                  color: isFree ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isFree ? 'INICIAR' : 'EXCLUSIVO',
                                  style: TextStyle(
                                    color: isFree ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF201F1F).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            dateTimeFormatted,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      topEvento.tipo.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFADC6FF),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      topEvento.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarteleraScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecientesScreen()),
            );
          }
        },
      ),
    );
  }
}
