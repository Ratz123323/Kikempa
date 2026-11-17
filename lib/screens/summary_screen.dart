import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/neu_widgets.dart';

class SummaryScreen extends StatelessWidget {
  final Family family;
  const SummaryScreen({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    if (family.members.isEmpty) {
      return const EmptyState(
        emoji: '👥',
        title: 'Aucun membre dans cette famille',
        subtitle: 'Ajoutez des membres pour voir le résumé',
      );
    }

    final dislikedMap = family.dislikedFoodsByFood;
    if (dislikedMap.isEmpty) {
      return const EmptyState(
        emoji: '🎉',
        title: 'Tout le monde mange de tout !',
        subtitle: 'Aucune restriction alimentaire',
      );
    }

    // Les plus détestés d'abord, puis ordre alphabétique.
    final sortedFoods = dislikedMap.entries.toList()
      ..sort((a, b) {
        final parNombre = b.value.length.compareTo(a.value.length);
        if (parNombre != 0) return parNombre;
        return foodKey(a.key).compareTo(foodKey(b.key));
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        NeuCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: neuBoxAccent(radius: 14),
                child: const Center(
                    child: Text('📋', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plural(dislikedMap.length, 'aliment')} à éviter',
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plural(family.members.length, 'membre')} dans la famille',
                    style: const TextStyle(color: kTextSecond, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('Aliments à ne pas servir'),
        ...sortedFoods.map((entry) => _FoodSummaryCard(
              food: entry.key,
              persons: entry.value,
              totalMembers: family.members.length,
            )),
      ],
    );
  }
}

class _FoodSummaryCard extends StatelessWidget {
  final String food;
  final List<String> persons;
  final int totalMembers;
  const _FoodSummaryCard(
      {required this.food, required this.persons, required this.totalMembers});

  @override
  Widget build(BuildContext context) {
    final ratio = persons.length / totalMembers;
    final isHigh = ratio >= 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeuCard(
        padding: const EdgeInsets.all(16),
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
                  child: Text('${persons.length}/$totalMembers',
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
      ),
    );
  }
}
