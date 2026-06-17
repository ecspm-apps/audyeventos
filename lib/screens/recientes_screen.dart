import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'inicio_inmersivo_screen.dart';
import 'cartelera_screen.dart';
import 'reproductor_chat_screen.dart';
import 'reproductor_ingreso_nombre_screen.dart';
import '../services/database_service.dart';
import '../models/evento.dart';

class RecientesScreen extends StatefulWidget {
  const RecientesScreen({super.key});

  @override
  State<RecientesScreen> createState() => _RecientesScreenState();
}

class _RecientesScreenState extends State<RecientesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<Evento>> _eventosStream;

  @override
  void initState() {
    super.initState();
    _eventosStream = _dbService.getEventosStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        stream: _eventosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFADC6FF)));
          }

          final rawEventos = snapshot.data ?? [];
          final now = DateTime.now();
          final recientesEventos = rawEventos.where((evento) => evento.esReciente(now)).toList();

          final query = _searchController.text.toLowerCase().trim();
          final eventos = recientesEventos.where((evento) {
            return query.isEmpty ||
                evento.titulo.toLowerCase().contains(query) ||
                evento.tipo.toLowerCase().contains(query);
          }).toList()
            ..sort((a, b) {
              final timeA = Evento.parseFechaHora(a.fechaHora) ?? DateTime.fromMillisecondsSinceEpoch(0);
              final timeB = Evento.parseFechaHora(b.fechaHora) ?? DateTime.fromMillisecondsSinceEpoch(0);
              return timeB.compareTo(timeA); // Más recientes primero
            });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar en recientes...',
                    hintStyle: const TextStyle(color: Color(0xFF8B90A0), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFADC6FF), size: 18),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.clear, color: Color(0xFF8B90A0), size: 18),
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
                    filled: true,
                    fillColor: const Color(0xFF201F1F),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFADC6FF), width: 1),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const Divider(color: Color(0x1AFFFFFF), thickness: 1, height: 1),
              Expanded(
                child: _buildContent(context, recientesEventos, eventos, query),
              ),
            ],
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

  Widget _buildContent(BuildContext context, List<Evento> recientesEventos, List<Evento> eventos, String query) {
    if (recientesEventos.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
        ),
      );
    }

    if (eventos.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Color(0xFF8B90A0)),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron resultados',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay eventos que coincidan con "$query"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8B90A0), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final evento = eventos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildEventCard(context, evento),
        );
      },
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
