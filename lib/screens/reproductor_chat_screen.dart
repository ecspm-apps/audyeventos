import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../models/evento.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'cartelera_screen.dart';
import 'recientes_screen.dart';
import 'inicio_inmersivo_screen.dart';

class ReproductorChatScreen extends StatefulWidget {
  final bool isExclusive;
  final Evento evento;
  final String? userName;
  final String? accessCode;
  final String? userColor;

  const ReproductorChatScreen({
    super.key,
    this.isExclusive = false,
    required this.evento,
    this.userName,
    this.accessCode,
    this.userColor,
  });

  @override
  State<ReproductorChatScreen> createState() => _ReproductorChatScreenState();
}

class _ReproductorChatScreenState extends State<ReproductorChatScreen> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _hlsController;
  bool _isHlsInitialized = false;
  bool _isPlayerLoading = true;
  bool _hasErrorLoading = false;
  StreamSubscription<DatabaseEvent>? _eventSubscription;
  String _urlStream = '';
  String _tipoStream = '';
  String _facebookUrl = '';
  String _tiktokUrl = '';
  String _youtubeUrl = '';
  final TextEditingController _chatController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isChatLoading = true;
  StreamSubscription<DatabaseEvent>? _chatSubscription;
  bool _isPlayerHidden = false;

  @override
  void initState() {
    super.initState();
    _urlStream = widget.evento.urlStream;
    _tipoStream = widget.evento.tipoStream;
    _facebookUrl = widget.evento.facebookUrl;
    _tiktokUrl = widget.evento.tiktokUrl;
    _youtubeUrl = widget.evento.youtubeUrl;
    _initializePlayer();

    _eventSubscription = FirebaseDatabase.instance
        .ref('eventos')
        .child(widget.evento.id)
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final String newUrl = data['url_stream'] ?? '';
        final String newTipo = data['tipo_stream'] ?? '';
        final redes = data['redes_sociales'] as Map<dynamic, dynamic>?;
        final String newFacebook = redes?['facebook'] ?? '';
        final String newTiktok = redes?['tiktok'] ?? '';
        final String newYoutube = redes?['youtube'] ?? '';

        final streamChanged = newUrl != _urlStream || newTipo != _tipoStream;
        final socialsChanged = newFacebook != _facebookUrl ||
            newTiktok != _tiktokUrl ||
            newYoutube != _youtubeUrl;

        if (streamChanged || socialsChanged) {
          if (mounted) {
            setState(() {
              _urlStream = newUrl;
              _tipoStream = newTipo;
              _facebookUrl = newFacebook;
              _tiktokUrl = newTiktok;
              _youtubeUrl = newYoutube;
            });
            if (streamChanged) {
              _initializePlayer();
            }
          }
        }
      }
    });
    _chatSubscription = FirebaseDatabase.instance
        .ref('comentarios')
        .child(widget.evento.id)
        .onValue
        .listen((DatabaseEvent event) {
      if (mounted) {
        final rawData = event.snapshot.value;
        final List<Map<String, dynamic>> loadedComments = [];

        if (rawData is Map) {
          rawData.forEach((key, value) {
            if (value is Map) {
              loadedComments.add({
                'id': key,
                'nombre': value['nombre'] ?? 'Anónimo',
                'codigo': value['codigo'] ?? '',
                'color': value['color'] ?? '',
                'mensaje': value['mensaje'] ?? '',
                'timestamp': value['timestamp'] ?? 0,
              });
            }
          });
        }

        loadedComments.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {
          _comments = loadedComments;
          _isChatLoading = false;
        });
      }
    }, onError: (error) {
      debugPrint('Error en la suscripción del chat: $error');
      if (mounted) {
        setState(() {
          _isChatLoading = false;
        });
      }
    });
  }

  void _initializePlayer() {
    // Limpiar controladores previos
    _youtubeController?.close();
    _youtubeController = null;
    _hlsController?.removeListener(_videoPlayerListener);
    _hlsController?.dispose();
    _hlsController = null;

    if (!mounted) return;
    setState(() {
      _isHlsInitialized = false;
      _isPlayerLoading = true;
      _hasErrorLoading = false;
    });

    final tipoStream = _tipoStream.toLowerCase();
    final url = _urlStream.trim();

    if (url.isEmpty) {
      if (mounted) {
        setState(() {
          _isPlayerLoading = false;
          _hasErrorLoading = false; // Sin enlace aún
        });
      }
      return;
    }

    if (tipoStream == 'youtube') {
      final videoId = _convertUrlToId(url);
      if (videoId != null) {
        if (mounted) {
          setState(() {
            _youtubeController = YoutubePlayerController.fromVideoId(
              videoId: videoId,
              autoPlay: true,
              params: const YoutubePlayerParams(
                showControls: true,
                showFullscreenButton: true,
                mute: false,
              ),
            );
            _youtubeController!.setFullScreenListener((isFullScreen) {
              if (isFullScreen) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              } else {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
              }
            });
            _isPlayerLoading = false;
            _hasErrorLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPlayerLoading = false;
            _hasErrorLoading = true;
          });
        }
        _scheduleRetry();
      }
    } else if (tipoStream == 'hls' || tipoStream == 'mediamtx' || url.endsWith('.m3u8')) {
      _hlsController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isHlsInitialized = true;
              _isPlayerLoading = false;
              _hasErrorLoading = false;
            });
            _hlsController!.play();
            _hlsController!.addListener(_videoPlayerListener);
          }
        }).catchError((error) {
          debugPrint('Error al inicializar HLS VideoPlayer: $error');
          if (mounted) {
            setState(() {
              _isHlsInitialized = false;
              _isPlayerLoading = false;
              _hasErrorLoading = true;
            });
          }
          _scheduleRetry();
        });
    } else {
      if (mounted) {
        setState(() {
          _isPlayerLoading = false;
          _hasErrorLoading = true;
        });
      }
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_urlStream.trim().isEmpty) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && (_hasErrorLoading || _isPlayerLoading) && !_isHlsInitialized && _youtubeController == null) {
        _initializePlayer();
      }
    });
  }

  String? _convertUrlToId(String url) {
    if (url.isEmpty) return null;
    final RegExp regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/|live\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      if (id != null && id.length == 11) {
        return id;
      }
    }
    return null;
  }

  void _videoPlayerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _youtubeController?.close();
    _hlsController?.removeListener(_videoPlayerListener);
    _hlsController?.dispose();
    _eventSubscription?.cancel();
    _chatSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final name = widget.userName ?? 'Anónimo';
    final code = widget.accessCode ?? '';
    final userColor = widget.userColor ?? '';

    FirebaseDatabase.instance
        .ref('comentarios')
        .child(widget.evento.id)
        .push()
        .set({
      'nombre': name,
      'codigo': code,
      'color': userColor,
      'mensaje': text,
      'timestamp': ServerValue.timestamp,
    });

    _chatController.clear();
  }

  void _toggleFullScreenHls() {
    if (_hlsController == null || !_isHlsInitialized) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(controller: _hlsController!),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = Evento.parseFechaHora(widget.evento.fechaHora);
    String dateFormatted;
    String timeFormatted;
    if (dateTime != null) {
      dateFormatted = DateFormat('dd MMM yyyy').format(dateTime);
      timeFormatted = DateFormat('HH:mm a').format(dateTime);
    } else {
      dateFormatted = widget.evento.fechaHora.isNotEmpty ? widget.evento.fechaHora : 'FECHA NO DISPONIBLE';
      timeFormatted = '';
    }
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFADC6FF)),
          onPressed: () => Navigator.pop(context),
        ),
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
        actions: widget.isExclusive
            ? [
                IconButton(
                  icon: Icon(
                    _isPlayerHidden ? Icons.tv : Icons.tv_off,
                    color: const Color(0xFFADC6FF),
                  ),
                  tooltip: _isPlayerHidden ? 'Mostrar reproductor' : 'Esconder reproductor',
                  onPressed: () {
                    setState(() {
                      _isPlayerHidden = !_isPlayerHidden;
                    });
                  },
                ),
              ]
            : const [],
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: (widget.isExclusive && _isPlayerHidden) ? 0.0 : 1.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video Player Container
                    Container(
                      height: 230,
                      color: Colors.black,
                      child: (_urlStream.trim().isEmpty || _isPlayerLoading || _hasErrorLoading)
                          ? _buildInfiniteLoadingPlayer()
                          : _youtubeController != null
                              ? YoutubePlayer(
                                  controller: _youtubeController!,
                                  aspectRatio: 16 / 9,
                                )
                              : _hlsController != null
                                  ? Stack(
                                      children: [
                                        if (_isHlsInitialized) ...[
                                          Positioned.fill(
                                            child: Center(
                                              child: AspectRatio(
                                                aspectRatio: _hlsController!.value.aspectRatio,
                                                child: VideoPlayer(_hlsController!),
                                              ),
                                            ),
                                          ),
                                          // HLS controls at the bottom
                                          Positioned(
                                            bottom: 8,
                                            left: 12,
                                            right: 12,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        _hlsController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _hlsController!.value.isPlaying
                                                              ? _hlsController!.pause()
                                                              : _hlsController!.play();
                                                        });
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _hlsController!.value.volume > 0 ? Icons.volume_up : Icons.volume_mute,
                                                        color: Colors.white,
                                                        size: 24,
                                                        ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _hlsController!.setVolume(_hlsController!.value.volume > 0 ? 0.0 : 1.0);
                                                        });
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.fullscreen,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  onPressed: () {
                                                    _toggleFullScreenHls();
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ] else ...[
                                          _buildInfiniteLoadingPlayer(),
                                        ],
                                      ],
                                    )
                                  : _buildInfiniteLoadingPlayer(),
                    ),

                    // Stream Info Header
                    if (!isKeyboardOpen)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        color: const Color(0xFF131313),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.evento.titulo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.evento.tipo.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFADC6FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Color(0xFFADC6FF)),
                                const SizedBox(width: 6),
                                Text(
                                  dateFormatted,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                if (timeFormatted.isNotEmpty) ...[
                                  const SizedBox(width: 16),
                                  const Icon(Icons.schedule, size: 14, color: Color(0xFFADC6FF)),
                                  const SizedBox(width: 6),
                                  Text(
                                    timeFormatted,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Under-player area based on mode
          if (widget.isExclusive) ...[
            // ------------------ EXCLUSIVE MODE CHAT SECTION ------------------
            // Blue thin progress bar line
            if (!_isPlayerHidden && !isKeyboardOpen)
              Container(
                height: 3,
                width: double.infinity,
                color: const Color(0xFFADC6FF),
              ),
            Expanded(
              child: Container(
                color: const Color(0xFF1E1E1E),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'CHAT EN VIVO',
                            style: TextStyle(
                              color: Color(0xFF8B90A0),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlayerHidden ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                              color: const Color(0xFFADC6FF),
                            ),
                            tooltip: _isPlayerHidden
                                ? 'Mostrar reproductor'
                                : 'Maximizar chat / Esconder reproductor',
                            onPressed: () {
                              setState(() {
                                _isPlayerHidden = !_isPlayerHidden;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isChatLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFADC6FF),
                              ),
                            )
                          : _comments.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay comentarios aún. ¡Sé el primero!',
                                    style: TextStyle(color: Color(0xFF8B90A0)),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  reverse: true,
                                  itemCount: _comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = _comments[index];
                                    final String senderName = comment['nombre'];
                                    final String senderMsg = comment['mensaje'];
                                    final String senderCode = comment['codigo'];
                                    final String senderColor = comment['color'] ?? '';
                                    final bool isMod = senderName.contains('Moderador') || senderName.contains('Admin');

                                    return _buildMessage(
                                      senderName,
                                      senderMsg,
                                      senderCode,
                                      userColorHex: senderColor,
                                      isMod: isMod,
                                      timestamp: comment['timestamp'] ?? 0,
                                    );
                                  },
                                ),
                    ),
                    // Chat Input Field
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: isKeyboardOpen ? 8.0 : 20.0,
                        top: 12.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF201F1F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatController,
                                onSubmitted: (_) => _sendMessage(),
                                decoration: const InputDecoration(
                                  hintText: 'Escribe un mensaje...',
                                  hintStyle: TextStyle(color: Color(0xFF8B90A0)),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D2D3D),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Color(0xFFADC6FF),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // ------------------ FREE MODE INFO & EXTERNAL PLATFORMS ------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final cards = <Widget>[];
                        if (_tiktokUrl.isNotEmpty) {
                          cards.add(_buildPlatformCard(
                            'TikTok',
                            const Color(0xFF000000),
                            Icons.music_note,
                            borderColor: const Color(0xFF00F2FE),
                            onTap: () => _launchURL(_tiktokUrl),
                          ));
                        }
                        if (_youtubeUrl.isNotEmpty) {
                          cards.add(_buildPlatformCard(
                            'YouTube',
                            const Color(0xFFFF0000),
                            Icons.play_circle_fill,
                            onTap: () => _launchURL(_youtubeUrl),
                          ));
                        }
                        if (_facebookUrl.isNotEmpty) {
                          cards.add(_buildPlatformCard(
                            'Facebook',
                            const Color(0xFF1877F2),
                            Icons.facebook,
                            onTap: () => _launchURL(_facebookUrl),
                          ));
                        }

                        if (cards.isEmpty) return const SizedBox.shrink();

                        final rowChildren = <Widget>[];
                        for (int i = 0; i < cards.length; i++) {
                          rowChildren.add(cards[i]);
                          if (i < cards.length - 1) {
                            rowChildren.add(const SizedBox(width: 12));
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            const Text(
                              'VER EN OTRAS PLATAFORMAS',
                              style: TextStyle(
                                color: Color(0xFF8B90A0),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(children: rowChildren),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: isKeyboardOpen
          ? null
          : CustomBottomNavigationBar(
              currentIndex: widget.isExclusive ? 0 : 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const InicioInmersivoScreen()),
                    (route) => false,
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CarteleraScreen()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RecientesScreen()),
                  );
                }
              },
            ),
    );
  }

  Color _getUserColor(String key) {
    if (key.isEmpty) return const Color(0xFF8B90A0);

    final List<Color> colors = [
      const Color(0xFFE57373), // Coral claro
      const Color(0xFFF06292), // Rosa
      const Color(0xFFBA68C8), // Lavanda
      const Color(0xFF9575CD), // Violeta
      const Color(0xFF7986CB), // Azul índigo
      const Color(0xFF64B5F6), // Azul cielo
      const Color(0xFF4FC3F7), // Celeste
      const Color(0xFF4DD0E1), // Turquesa
      const Color(0xFF4DB6AC), // Verde azulado
      const Color(0xFF81C784), // Verde claro
      const Color(0xFFAED581), // Verde lima
      const Color(0xFFD4E157), // Amarillo lima
      const Color(0xFFFFD54F), // Ámbar
      const Color(0xFFFFB74D), // Naranja claro
      const Color(0xFFFF8A65), // Naranja coral
      const Color(0xFFA1887F), // Marrón claro
    ];

    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = key.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final index = hash.abs() % colors.length;
    return colors[index];
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        buffer.write('ff');
      }
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFFE57373);
    }
  }

  String _formatCommentRelativeTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(dt);

    if (diff.isNegative || diff.inSeconds < 60) {
      return 'un momento';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} d';
    } else {
      final int weeks = (diff.inDays / 7).floor();
      return '$weeks sem';
    }
  }

  Widget _buildMessage(String user, String message, String code, {String userColorHex = '', bool isMod = false, int timestamp = 0}) {
    final String initial = user.isNotEmpty ? user.trim()[0].toUpperCase() : '?';
    
    Color avatarColor;
    if (isMod) {
      avatarColor = Colors.blue;
    } else if (userColorHex.isNotEmpty) {
      avatarColor = _parseHexColor(userColorHex);
    } else {
      avatarColor = _getUserColor(code);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            radius: 18,
            child: isMod
                ? const Icon(Icons.shield, size: 16, color: Colors.white)
                : Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      user,
                      style: TextStyle(
                        color: isMod ? Colors.blue[300] : const Color(0xFF8B90A0),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (timestamp > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatCommentRelativeTimestamp(timestamp),
                        style: const TextStyle(
                          color: Color(0xFF5A5F6E),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: isMod ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(String label, Color color, IconData icon, {Color? borderColor, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      // Intentar abrir directamente en la aplicación nativa (YouTube, Facebook, TikTok, etc.)
      bool success = await launchUrl(
        url,
        mode: LaunchMode.externalNonBrowserApplication,
      );

      // Si no fue posible abrir en la aplicación nativa, abrir en el navegador externo
      if (!success) {
        success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
        );
      }
    } catch (e) {
      // Si ocurre un error intentando abrir la app nativa, reintentar con el navegador
      try {
        final success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
          );
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al abrir el enlace: $err')),
          );
        }
      }
    }
  }

  Widget _buildInfiniteLoadingPlayer() {
    final eventTime = Evento.parseFechaHora(widget.evento.fechaHora);
    final isBeforeEvent = eventTime != null && DateTime.now().isBefore(eventTime);
     final String loadingText = isBeforeEvent
        ? 'Conectando con la transmisión\nverifica la fecha y hora de transmisión'
        : 'Conectando con la transmisión...';

    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            widget.evento.aficheHorizontal.isNotEmpty
                ? widget.evento.aficheHorizontal
                : widget.evento.aficheVertical,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF131313),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFADC6FF),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    loadingText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            if (_showControls) ...[
              // Bottom Controls (Play/Pause, Volume, and Fullscreen Exit)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.controller.value.isPlaying
                                      ? widget.controller.pause()
                                      : widget.controller.play();
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                widget.controller.value.volume > 0 ? Icons.volume_up : Icons.volume_mute,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.controller.setVolume(widget.controller.value.volume > 0 ? 0.0 : 1.0);
                                });
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


