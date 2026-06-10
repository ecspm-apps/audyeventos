import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      // Intentar abrir directamente en la aplicación nativa
      bool success = await launchUrl(
        url,
        mode: LaunchMode.externalNonBrowserApplication,
      );

      // Si no fue posible, abrir en el navegador web externo
      if (!success) {
        success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
          );
        }
      }
    } catch (e) {
      // Fallback al navegador web si hay un error
      try {
        final success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
            );
          }
        }
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al abrir el enlace: $err')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF131313),
      child: Column(
        children: [
          DrawerHeader(
            child: Image.asset('assets/images/logo.png'),
          ),
          ListTile(
            leading: const Icon(Icons.video_library, color: Colors.red),
            title: const Text('YOUTUBE', style: TextStyle(color: Colors.white)),
            onTap: () => _launchURL(context, 'https://www.youtube.com/@audyeventos'),
          ),
          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white), // Icono representativo para TikTok
            title: const Text('TIKTOK', style: TextStyle(color: Colors.white)),
            onTap: () => _launchURL(context, 'https://www.tiktok.com/@audy_eventos'),
          ),
          ListTile(
            leading: const Icon(Icons.facebook, color: Colors.blue),
            title: const Text('FACEBOOK', style: TextStyle(color: Colors.white)),
            onTap: () => _launchURL(context, 'https://www.facebook.com/@audyeventos'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
