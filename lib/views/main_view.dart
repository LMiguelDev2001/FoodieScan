import 'package:flutter/material.dart';
import 'camscanner_view.dart';
import '../views/fridge_view.dart';
import '../views/products_view.dart';
import 'package:google_fonts/google_fonts.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int currentIndex = 0;

  final List<Widget> _pantallas = [
    const ScannerView(),
    const FridgeView(),
    const ProductsView(),
  ];

  @override
  Widget build(BuildContext context) {
    //Fuente de texto retro
    final TextStyle labelRetroStyle = GoogleFonts.pixelifySans(
      textStyle: const TextStyle(color: Colors.white, fontSize: 14),
    );

    return Scaffold(
      //Para modificar la feunte de la barra de navegacion, es necesario envolverlo en "NavigationBarTheme"
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStatePropertyAll(labelRetroStyle),
        ),
        child: Container(
          child: NavigationBar(
            height: 60,
            selectedIndex: currentIndex,
            backgroundColor: const Color(0xFF1E1E2C),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1),
            ),
            indicatorColor: Colors.white30,
            overlayColor: WidgetStatePropertyAll(Colors.white10),
            destinations: <Widget>[
              NavigationDestination(
                icon: Image.asset(
                  'assets/icons/camara.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/camara.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                label: 'Cámara',
              ),
              NavigationDestination(
                icon: Image.asset(
                  'assets/icons/despensa.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/despensa.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                label: 'Inventario',
              ),
              NavigationDestination(
                icon: Image.asset(
                  'assets/icons/history.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/history.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                label: 'Historial',
              ),
            ],

            onDestinationSelected: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),
      body: _pantallas[currentIndex],
    );
  }
}
