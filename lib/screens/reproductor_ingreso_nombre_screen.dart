import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/evento.dart';
import 'reproductor_chat_screen.dart';

class ReproductorIngresoNombreScreen extends StatefulWidget {
  final Evento evento;
  const ReproductorIngresoNombreScreen({super.key, required this.evento});

  @override
  State<ReproductorIngresoNombreScreen> createState() => _ReproductorIngresoNombreScreenState();
}

class _ReproductorIngresoNombreScreenState extends State<ReproductorIngresoNombreScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String _generateRandomColorHex() {
    const List<String> profileColors = [
      '#E57373', // Coral claro
      '#F06292', // Rosa
      '#BA68C8', // Lavanda
      '#9575CD', // Violeta
      '#7986CB', // Azul índigo
      '#64B5F6', // Azul cielo
      '#4FC3F7', // Celeste
      '#4DD0E1', // Turquesa
      '#4DB6AC', // Verde azulado
      '#81C784', // Verde claro
      '#AED581', // Verde lima
      '#D4E157', // Amarillo lima
      '#FFD54F', // Ámbar
      '#FFB74D', // Naranja claro
      '#FF8A65', // Naranja coral
      '#A1887F', // Marrón claro
    ];
    return profileColors[Random().nextInt(profileColors.length)];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModal();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showModal() {
    bool isLoading = false;
    String? errorMessage;
    bool isNameReadOnly = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canSubmit = _nameController.text.isNotEmpty && _codeController.text.isNotEmpty && !isLoading;

            Future<void> validarYIngresar() async {
              final name = _nameController.text.trim();
              final code = _codeController.text.trim();

              if (name.isEmpty || code.isEmpty) return;

              setDialogState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                final deviceName = await _getDeviceName();

                // Referencia directa al código del evento actual
                final codeRef = FirebaseDatabase.instance
                    .ref('codigos_acceso')
                    .child(widget.evento.id)
                    .child(code);

                final snapshot = await codeRef.get();

                if (!snapshot.exists) {
                  setDialogState(() {
                    isLoading = false;
                    errorMessage = 'Código de acceso incorrecto';
                  });
                  return;
                }

                final dbValue = snapshot.value;
                bool canAccess = false;
                bool shouldWriteDevice = false;
                String userColorHex = '';

                if (dbValue is Map) {
                  final data = Map<dynamic, dynamic>.from(dbValue);
                  final bool activo = data['activo'] == true;
                  final String dispositivo = data['dispositivo'] ?? '';
                  userColorHex = data['color'] ?? '';

                  if (!activo) {
                    // El código está libre/disponible. Lo activamos y registramos.
                    canAccess = true;
                    shouldWriteDevice = true;
                    userColorHex = _generateRandomColorHex();
                  } else {
                    // El código ya fue activado por un dispositivo.
                    final String dispTrim = dispositivo.trim().toLowerCase();
                    final String userDevTrim = deviceName.trim().toLowerCase();

                    // Verificamos si es el mismo dispositivo, si está vacío o si es desconocido
                    if (dispTrim.isEmpty ||
                        dispTrim == 'dispositivo desconocido' ||
                        dispTrim == userDevTrim) {
                      canAccess = true;
                      // Si estaba vacío o era desconocido, actualizamos los datos
                      if (dispTrim.isEmpty || dispTrim == 'dispositivo desconocido') {
                        shouldWriteDevice = true;
                      }
                      if (userColorHex.isEmpty) {
                        userColorHex = _generateRandomColorHex();
                        shouldWriteDevice = true;
                      }
                    } else {
                      // Es un dispositivo diferente. Denegar acceso.
                      setDialogState(() {
                        isLoading = false;
                        errorMessage = 'El código está activo en otro dispositivo';
                      });
                      return;
                    }
                  }
                } else if (dbValue == true) {
                  // Retrocompatibilidad: El código anterior plano estaba libre (valor es 'true')
                  canAccess = true;
                  shouldWriteDevice = true;
                  userColorHex = _generateRandomColorHex();
                } else if (dbValue is String) {
                  // Retrocompatibilidad: El código anterior plano ya fue reclamado por un dispositivo.
                  final String dbValTrim = dbValue.trim().toLowerCase();
                  final String userDevTrim = deviceName.trim().toLowerCase();

                  if (dbValTrim.isEmpty ||
                      dbValTrim == 'dispositivo desconocido' ||
                      dbValTrim == userDevTrim) {
                    canAccess = true;
                    if (dbValTrim.isEmpty || dbValTrim == 'dispositivo desconocido') {
                      shouldWriteDevice = true;
                    }
                    userColorHex = _generateRandomColorHex();
                  } else {
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = 'El código está activo en otro dispositivo';
                    });
                    return;
                  }
                } else {
                  setDialogState(() {
                    isLoading = false;
                    errorMessage = 'Código de acceso no disponible';
                  });
                  return;
                }

                if (canAccess) {
                  if (shouldWriteDevice) {
                    // Si el formato es el nuevo mapa, actualizamos sus campos específicos
                    if (dbValue is Map) {
                      await codeRef.update({
                        'activo': true,
                        'dispositivo': deviceName,
                        'nombre': name,
                        'color': userColorHex,
                      });
                    } else {
                      // Si era el formato retrocompatible plano, migramos a la nueva estructura con color
                      await codeRef.set({
                        'activo': true,
                        'dispositivo': deviceName,
                        'nombre': name,
                        'color': userColorHex,
                      });
                    }
                  }

                  if (context.mounted) {
                    Navigator.pop(context); // Cierra el modal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReproductorChatScreen(
                          isExclusive: true,
                          evento: widget.evento,
                          userName: name,
                          accessCode: code,
                          userColor: userColorHex,
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                setDialogState(() {
                  isLoading = false;
                  errorMessage = 'Error al verificar el código. Inténtalo de nuevo.';
                });
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text('Acceso Exclusivo', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ingresa tu nombre y el código de acceso', style: TextStyle(color: Color(0xFF8B90A0))),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    readOnly: isNameReadOnly,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tu nombre',
                      filled: true,
                      fillColor: isNameReadOnly ? const Color(0xFF1E1E1E) : const Color(0xFF131313),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: isNameReadOnly ? const Icon(Icons.lock_outline, color: Color(0xFFADC6FF)) : null,
                      helperText: isNameReadOnly ? 'Nombre registrado con este código' : null,
                      helperStyle: const TextStyle(color: Color(0xFFADC6FF), fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeController,
                    onChanged: (value) async {
                      setDialogState(() {});
                      final code = value.trim();
                      if (code.length >= 4) {
                        try {
                          final codeRef = FirebaseDatabase.instance
                              .ref('codigos_acceso')
                              .child(widget.evento.id)
                              .child(code);
                          final snapshot = await codeRef.get();
                          if (snapshot.exists) {
                            final dbValue = snapshot.value;
                            if (dbValue is Map) {
                              final data = Map<dynamic, dynamic>.from(dbValue);
                              final bool activo = data['activo'] == true;
                              final String nombre = data['nombre'] ?? '';
                              if (activo && nombre.isNotEmpty) {
                                setDialogState(() {
                                  _nameController.text = nombre;
                                  isNameReadOnly = true;
                                });
                              } else {
                                setDialogState(() {
                                  isNameReadOnly = false;
                                });
                              }
                            } else {
                              setDialogState(() {
                                isNameReadOnly = false;
                              });
                            }
                          } else {
                            setDialogState(() {
                              isNameReadOnly = false;
                            });
                          }
                        } catch (e) {
                          // Ignore
                        }
                      } else {
                        setDialogState(() {
                          if (isNameReadOnly) {
                            _nameController.clear();
                          }
                          isNameReadOnly = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Código de acceso',
                      filled: true,
                      fillColor: const Color(0xFF131313),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: canSubmit ? validarYIngresar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSubmit ? const Color(0xFFADC6FF) : Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                          )
                        : const Text('INGRESAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context); // Cierra el modal
                            Navigator.pop(context); // Retorna a INICIO
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFADC6FF)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('CANCELAR', style: TextStyle(color: Color(0xFFADC6FF), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final shortId = androidInfo.id.length > 6 ? androidInfo.id.substring(0, 6) : androidInfo.id;
        // Se registra marca, modelo, placa (board) y hardware del dispositivo Android
        return '${androidInfo.brand} ${androidInfo.model} [Placa: ${androidInfo.board}] [Hardware: ${androidInfo.hardware}] ($shortId)';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final shortId = (iosInfo.identifierForVendor ?? '').length > 6
            ? iosInfo.identifierForVendor!.substring(0, 6)
            : (iosInfo.identifierForVendor ?? 'UnknownID');
        // iOS no expone board/hardware directamente, se usa un identificador único
        return '${iosInfo.name} [Placa: Apple] ($shortId)';
      }
    } catch (e) {
      debugPrint('Error al obtener info del dispositivo: $e');
    }
    return 'Dispositivo Desconocido';
  }

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
      body: Container(), // The modal covers this
    );
  }
}
