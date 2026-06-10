import 'package:firebase_database/firebase_database.dart';
import '../models/evento.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('eventos');

  Stream<List<Evento>> getEventosStream() {
    return _dbRef.onValue.map((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        return Evento.fromMap(entry.key, entry.value);
      }).toList();
    });
  }
}
