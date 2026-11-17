import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🥦', style: TextStyle(fontSize: 36)),
                      SizedBox(width: 12),
                      Text('Aliments',
                          style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${plural(cles.length, 'aliment')} non apprécié(s)',
                      style: const TextStyle(color: kTextSecond, fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: cles.isEmpty
                  ? const EmptyState(
                      emoji: '🎉',
                      title: 'Aucun aliment non apprécié',
                      subtitle: 'Ajoutez-en depuis la fiche d\'une personne',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: cles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _FoodCard(
                        food: noms[cles[i]]!,
                        persons: personnes[cles[i]]!,
                        total: totalPersonnes,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String food;
  final List<String> persons;
  final int total;
  const _FoodCard(
      {required this.food, required this.persons, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = persons.length / total;
    final isHigh = ratio >= 0.5;

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(food,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHigh ? kDangerSoft : kAccentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${persons.length}/$total',
                    style: TextStyle(
                        color: isHigh ? kDanger : kAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          NeuProgressBar(ratio: ratio, color: isHigh ? kDanger : kAccent),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: persons
                .map((name) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: neuBoxOutSmall(radius: 20),
                      child: Text(name,
                          style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
