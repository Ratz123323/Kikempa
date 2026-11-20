import 'package:flutter/material.dart';
import '../widgets/neu_widgets.dart';
import 'home_screen.dart';
import 'foods_screen.dart';
import 'meal_screen.dart';
import 'people_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _onglet = 0;

  // Les 3 derniers écrans sont provisoires, on les remplace ensuite.
  static const _pages = [
    HomeScreen(),
    PeopleScreen(),
    FoodsScreen(),
    MealScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _onglet, children: _pages),
      bottomNavigationBar: NeuBottomNav(
        icons: const [
          Icons.home_rounded,
          Icons.people_rounded,
          Icons.no_food_rounded,
          Icons.restaurant_rounded,
        ],
        labels: const ['Accueil', 'Personnes', 'Aliments', 'Repas'],
        selected: _onglet,
        onChanged: (i) => setState(() => _onglet = i),
      ),
    );
  }
}
