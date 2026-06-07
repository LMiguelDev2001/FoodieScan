import 'package:flutter/material.dart';
import 'camscanner_view.dart';
import '../views/fridge_view.dart';
import '../views/products_view.dart';

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
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedIndex: currentIndex,
        backgroundColor: Colors.grey[900],
        indicatorColor: Colors.greenAccent,

        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Cámara',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Nevera',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Productos',
          ),
        ],
      ),
      body: _pantallas[currentIndex],
    );
  }
}
