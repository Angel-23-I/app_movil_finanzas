import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'ingresos_screen.dart';
import 'egresos_screen.dart';
import 'ajustes_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [
    DashboardScreen(),
    IngresosScreen(),
    EgresosScreen(),
    AjustesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.south_west_outlined),
              selectedIcon: Icon(Icons.south_west_rounded),
              label: 'Ingresos'),
          NavigationDestination(
              icon: Icon(Icons.north_east_outlined),
              selectedIcon: Icon(Icons.north_east_rounded),
              label: 'Gastos'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Ajustes'),
        ],
      ),
    );
  }
}
