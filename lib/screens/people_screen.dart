import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/neu_widgets.dart';
import 'person_screen.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final families = context.watch<AppData>().families;

    // On met toutes les personnes dans une seule liste, avec leur famille
    final lignes = <Widget>[];
    for (final family in families) {
      for (final person in family.members) {
        lignes.add(
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PersonScreen(familyId: family.id, personId: person.id),
              ),
            ),
            child: NeuCard(
              child: Row(
                children: [
                  EmojiAvatar(emoji: person.emoji),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person.name,
                            style: const TextStyle(
                                color: kTextPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(family.name,
                            style: const TextStyle(
                                color: kTextSecond, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          personStats(person),
                          style: TextStyle(
                            color: person.dislikedFoods.isEmpty
                                ? kTextSecond
                                : kAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: kTextSecond),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Text('👥', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 12),
                  Text('Personnes',
                      style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ],
              ),
            ),
            Expanded(
              child: lignes.isEmpty
                  ? const EmptyState(
                      emoji: '👤',
                      title: 'Aucune personne',
                      subtitle: 'Ajoutez des membres dans une famille',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: lignes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => lignes[i],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}