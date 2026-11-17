import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text('🍽️', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 12),
                  Text('Repas',
                      style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Qui sera présent ?',
                  style: TextStyle(color: kTextSecond, fontSize: 14)),
            ),
            if (families.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyState(
                  emoji: '🏠',
                  title: 'Aucune famille',
                  subtitle: 'Créez une famille depuis l\'accueil',
                ),
              )
            else ...[
              ...families.map((family) => _bloc(family)),
              SectionTitle('Aliments à éviter'),
              _resultat(nbPresents, cles, noms, personnes),
            ],
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
        child: EmptyState(
          emoji: '👆',
          title: 'Choisissez les personnes présentes',
          subtitle: 'Les aliments à éviter apparaîtront ici',
        ),
      );
    }
    if (cles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: EmptyState(
          emoji: '🎉',
          title: 'Tout le monde mange de tout !',
          subtitle: 'Aucune restriction pour ce repas',
        ),
      );
    }

    return Column(
      children: cles
          .map((cle) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AlimentCard(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

class _AlimentCard extends StatelessWidget {
  final String food;
  final List<String> persons;
  final int total;
  const _AlimentCard(
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
