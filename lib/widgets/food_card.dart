import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neu_widgets.dart';

class FoodCard extends StatelessWidget {
  final String food;
  final List<String> persons;
  final int total;
  const FoodCard(
      {super.key,
      required this.food,
      required this.persons,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = persons.length / total;
    final isHigh = ratio >= 0.5;

    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(food,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
          const SizedBox(height: 8),
          NeuProgressBar(ratio: ratio, color: isHigh ? kDanger : kAccent),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: persons
                .map((name) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
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