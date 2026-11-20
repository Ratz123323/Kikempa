import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/food_card.dart';
import '../widgets/neu_widgets.dart';

class SummaryScreen extends StatelessWidget {
  final Family family;
  final EdgeInsets padding;
  const SummaryScreen({super.key, required this.family, required this.padding});

  @override
  Widget build(BuildContext context) {
    if (family.members.isEmpty) {
      return const EmptyState(emoji: '👥', title: 'Aucun membre');
    }

    final dislikedMap = family.dislikedFoodsByFood;
    if (dislikedMap.isEmpty) {
      return const EmptyState(
          emoji: '🎉', title: 'Tout le monde mange de tout !');
    }

    // Les plus détestés d'abord, puis ordre alphabétique.
    final sortedFoods = dislikedMap.entries.toList()
      ..sort((a, b) {
        final parNombre = b.value.length.compareTo(a.value.length);
        if (parNombre != 0) return parNombre;
        return foodKey(a.key).compareTo(foodKey(b.key));
      });

    return ListView.separated(
      padding: padding,
      itemCount: sortedFoods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => FoodCard(
        food: sortedFoods[i].key,
        persons: sortedFoods[i].value,
        total: family.members.length,
      ),
    );
  }
}
