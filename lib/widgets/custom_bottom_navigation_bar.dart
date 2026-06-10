import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFF131313);
    
    // Usamos un Container con Column para asegurar que la barra
    // de navegación respete el espacio de la zona segura inferior
    // y mantenga el color de fondo constante.
    return Container(
      color: backgroundColor,
      // Aumentamos el padding superior para dar mas espacio al indicador seleccionado
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: backgroundColor,
              selectedItemColor: const Color(0xFFADC6FF),
              unselectedItemColor: const Color(0xFF8B90A0),
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: onTap,
              // Ajustamos el tamaño del icono para que el indicador no se desborde tanto
              iconSize: 24,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'Cartelera',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'Recientes',
                ),
              ],
            ),
          ),
          // Añadimos el espacio necesario de la zona segura inferior
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
