import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/food_card.dart';
import '../widgets/neu_widgets.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  // Personnes présentes au repas, stockées sous la forme "idFamille/idPersonne"
  final Set<String> _presents = {};

  String _cle(Family family, Person person) => '${family.id}/${person.id}';

  void _basculerPersonne(Family family, Person person) {
    final cle = _cle(family, person);
    setState(() {
      if (_presents.contains(cle)) {
        _presents.remove(cle);
      } else {
        _presents.add(cle);
      }
    });
  }

  // Si toute la famille est déjà présente, on la retire, sinon on l'ajoute
  void _basculerFamille(Family family) {
    final toutPresent =
        family.members.every((p) => _presents.contains(_cle(family, p)));
    setState(() {
      for (final person in family.members) {
        if (toutPresent) {
          _presents.remove(_cle(family, person));
        } else {
          _presents.add(_cle(family, person));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final families = context.watch<AppData>().families;

    // Aliments à éviter pour les personnes présentes
    final noms = <String, String>{}; // clé -> nom affiché
    final personnes = <String, List<String>>{}; // clé -> prénoms
    var nbPresents = 0;

    for (final family in families) {
      for (final person in family.members) {
        if (!_presents.contains(_cle(family, person))) continue;
        nbPresents++;
        for (final food in person.dislikedFoods) {
          final cle = foodKey(food);
          noms.putIfAbsent(cle, () => food);
          personnes.putIfAbsent(cle, () => []).add(person.name);
        }
      }
    }

    final cles = personnes.keys.toList()
      ..sort((a, b) {
        final parNombre = personnes[b]!.length.compareTo(personnes[a]!.length);
        if (parNombre != 0) return parNombre;
        return a.compareTo(b);
      });

    return Scaffold(
      body: NeuPage(
        header: const PageTitle('Repas'),
        builder: (padding) => families.isEmpty
            ? const EmptyState(emoji: '🏠', title: 'Aucune famille')
            : ListView(
                padding: padding,
                children: [
                  ...families.map((family) => _bloc(family)),
                  const SectionTitle('Aliments à éviter'),
                  _resultat(nbPresents, cles, noms, personnes),
                ],
              ),
      ),
    );
  }

  Widget _bloc(Family family) {
    if (family.members.isEmpty) return const SizedBox.shrink();

    final toutPresent =
        family.members.every((p) => _presents.contains(_cle(family, p)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SectionTitle(family.name)),
            GestureDetector(
              onTap: () => _basculerFamille(family),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  toutPresent ? 'Tout retirer' : 'Toute la famille',
                  style: const TextStyle(
                      color: kAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: family.members
              .map((person) => _PersonneChip(
                    person: person,
                    present: _presents.contains(_cle(family, person)),
                    onTap: () => _basculerPersonne(family, person),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _resultat(int nbPresents, List<String> cles, Map<String, String> noms,
      Map<String, List<String>> personnes) {
    if (nbPresents == 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: EmptyState(emoji: '👆', title: 'Qui est présent ?'),
      );
    }
    if (cles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: EmptyState(
            emoji: '🎉', title: 'Tout le monde mange de tout !'),
      );
    }

    return Column(
      children: cles
          .map((cle) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FoodCard(
                  food: noms[cle]!,
                  persons: personnes[cle]!,
                  total: nbPresents,
                ),
              ))
          .toList(),
    );
  }
}

class _PersonneChip extends StatelessWidget {
  final Person person;
  final bool present;
  final VoidCallback onTap;
  const _PersonneChip(
      {required this.person, required this.present, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration:
            present ? neuBoxAccent(radius: 20) : neuBoxOutSmall(radius: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(person.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(person.name,
                style: TextStyle(
                    color: present ? Colors.white : kTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
