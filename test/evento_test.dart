import 'package:flutter_test/flutter_test.dart';
import 'package:app_audyeventos/models/evento.dart';

void main() {
  group('Evento Status Tests (RTDB only)', () {
    final now = DateTime.now();

    test('Event with finStream=false should be in CARTELERA and not in RECIENTES', () {
      final evento = Evento(
        id: '1',
        titulo: 'Evento Activo',
        tipo: 'Concierto',
        fechaHora: '2026-06-17T13:00:00',
        modo: 'libre',
        tipoStream: 'youtube',
        urlStream: 'https://youtube.com/...',
        aficheVertical: 'url_v',
        aficheHorizontal: 'url_h',
        finStream: false,
        recientes: false,
      );

      expect(evento.esReciente(now), isFalse);
      expect(evento.esCartelera(now), isTrue);
    });

    test('Event with finStream=false and recientes=true should be in CARTELERA and not in RECIENTES', () {
      final evento = Evento(
        id: '2',
        titulo: 'Evento No Finalizado pero Marcado como Reciente',
        tipo: 'Concierto',
        fechaHora: '2026-06-17T11:00:00',
        modo: 'libre',
        tipoStream: 'youtube',
        urlStream: 'https://youtube.com/...',
        aficheVertical: 'url_v',
        aficheHorizontal: 'url_h',
        finStream: false,
        recientes: true,
      );

      expect(evento.esReciente(now), isFalse);
      expect(evento.esCartelera(now), isTrue);
    });

    test('Event with finStream=true and recientes=false should not be in CARTELERA nor in RECIENTES', () {
      final evento = Evento(
        id: '3',
        titulo: 'Evento Finalizado No Reciente',
        tipo: 'Concierto',
        fechaHora: '2026-06-17T11:00:00',
        modo: 'libre',
        tipoStream: 'youtube',
        urlStream: 'https://youtube.com/...',
        aficheVertical: 'url_v',
        aficheHorizontal: 'url_h',
        finStream: true,
        recientes: false,
      );

      expect(evento.esReciente(now), isFalse);
      expect(evento.esCartelera(now), isFalse);
    });

    test('Event with finStream=true and recientes=true should be in RECIENTES and not in CARTELERA', () {
      final evento = Evento(
        id: '4',
        titulo: 'Evento Finalizado y Reciente',
        tipo: 'Concierto',
        fechaHora: '2026-06-17T11:00:00',
        modo: 'libre',
        tipoStream: 'youtube',
        urlStream: 'https://youtube.com/...',
        aficheVertical: 'url_v',
        aficheHorizontal: 'url_h',
        finStream: true,
        recientes: true,
      );

      expect(evento.esReciente(now), isTrue);
      expect(evento.esCartelera(now), isFalse);
    });
  });
}
