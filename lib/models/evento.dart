class Evento {
  final String id;
  final String titulo;
  final String tipo;
  final String fechaHora;
  final String modo; // 'libre' o 'exclusivo'
  final String tipoStream;
  final String urlStream;
  final String aficheVertical;
  final String aficheHorizontal;
  final String facebookUrl;
  final String tiktokUrl;
  final String youtubeUrl;
  final bool finStream;

  Evento({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.fechaHora,
    required this.modo,
    required this.tipoStream,
    required this.urlStream,
    required this.aficheVertical,
    required this.aficheHorizontal,
    this.facebookUrl = '',
    this.tiktokUrl = '',
    this.youtubeUrl = '',
    this.finStream = false,
  });

  factory Evento.fromMap(String id, Map<dynamic, dynamic> map) {
    final redesSociales = map['redes_sociales'] as Map<dynamic, dynamic>?;
    return Evento(
      id: id,
      titulo: map['titulo'] ?? '',
      tipo: map['tipo'] ?? '',
      fechaHora: map['fecha_hora'] ?? '',
      modo: map['modo'] ?? 'libre',
      tipoStream: map['tipo_stream'] ?? '',
      urlStream: map['url_stream'] ?? '',
      aficheVertical: map['afiche_vertical'] ?? '',
      aficheHorizontal: map['afiche_horizontal'] ?? '',
      facebookUrl: redesSociales?['facebook'] ?? '',
      tiktokUrl: redesSociales?['tiktok'] ?? '',
      youtubeUrl: redesSociales?['youtube'] ?? '',
      finStream: map['fin_stream'] ?? false,
    );
  }

  static DateTime? parseFechaHora(String str) {
    if (str.isEmpty) return null;
    
    // First try standard parsing
    var parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;
    
    // If it fails, attempt to normalize single-digit components
    try {
      final parts = str.split('T');
      final datePart = parts[0];
      final dateComponents = datePart.split(RegExp(r'[-/]'));
      if (dateComponents.length == 3) {
        final year = dateComponents[0];
        final month = dateComponents[1].padLeft(2, '0');
        final day = dateComponents[2].padLeft(2, '0');
        
        final normalizedDate = '$year-$month-$day';
        final normalizedStr = normalizedDate + (parts.length > 1 ? 'T${parts[1]}' : '');
        return DateTime.tryParse(normalizedStr);
      }
    } catch (e) {
      // Ignore conversion errors and return null
    }
    
    return null;
  }
}
