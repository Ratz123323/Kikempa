import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../widgets/food_card.dart';
import '../widgets/neu_widgets.dart';

class FoodsScreen extends StatelessWidget {
  const FoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final families = context.watch<AppData>().families;

    // Pour chaque aliment : le nom affiché et la liste des personnes
    final noms = <String, String>{}; // clé -> nom affiché
    final personnes = <String, List<String>>{}; // clé -> prénoms
    var totalPersonnes = 0;

    for (final family in families) {
      for (final person in family.members) {
        totalPersonnes++;
        for (final food in person.dislikedFoods) {
          final cle = foodKey(food);
          noms.putIfAbsent(cle, () => food);
          personnes.putIfAbsent(cle, () => []).add(person.name);
        }
      }
    }

    // Les plus détestés d'abord, puis ordre alphabétique
    final cles = personnes.keys.toList()
      ..sort((a, b) {
        final parNombre = personnes[b]!.length.compareTo(personnes[a]!.length);
        if (parNombre != 0) return parNombre;
        return a.compareTo(b);
      });

    return Scaffold(
      body: NeuPage(
        header: const PageTitle('Aliments'),
        builder: (padding) => cles.isEmpty
            ? const EmptyState(emoji: '🎉', title: 'Aucun aliment non apprécié')
            : ListView.separated(
                padding: padding,
                itemCount: cles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => FoodCard(
                  food: noms[cles[i]]!,
                  persons: personnes[cles[i]]!,
                  total: totalPersonnes,
                ),
              ),
      ),
    );
  }
}
