import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/neu_widgets.dart';
import 'person_screen.dart';

const _decalageMenu = 48.0; // distance entre le haut de l'écran et la popup
const _nomsTri = {
  TriPersonnes.famille: 'Par famille',
  TriPersonnes.alphabetique: 'Alphabétique',
  TriPersonnes.aliments: "Nombre d'aliments",
  TriPersonnes.manuel: 'Ordre manuel',
};

/// Une personne avec sa famille.
class _Ligne {
  final Family family;
  final Person person;
  _Ligne(this.family, this.person);
}

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  List<_Ligne> _trier(
      List<Family> families, TriPersonnes tri, List<String> ordre) {
    // Par défaut : ordre des familles, puis ordre des personnes
    final lignes = <_Ligne>[];
    for (final family in families) {
      for (final person in family.members) {
        lignes.add(_Ligne(family, person));
      }
    }

    if (tri == TriPersonnes.alphabetique) {
      lignes.sort(
          (a, b) => foodKey(a.person.name).compareTo(foodKey(b.person.name)));
    } else if (tri == TriPersonnes.aliments) {
      lignes.sort((a, b) {
        final parNombre = b.person.dislikedFoods.length
            .compareTo(a.person.dislikedFoods.length);
        if (parNombre != 0) return parNombre;
        return foodKey(a.person.name).compareTo(foodKey(b.person.name));
      });
    } else if (tri == TriPersonnes.manuel) {
      return _ordreManuel(lignes, ordre);
    }
    return lignes;
  }

  /// Les personnes de l'ordre enregistré d'abord, puis les nouvelles.
  List<_Ligne> _ordreManuel(List<_Ligne> lignes, List<String> ordre) {
    final resultat = <_Ligne>[];
    for (final id in ordre) {
      for (final ligne in lignes) {
        if (ligne.person.id == id) resultat.add(ligne);
      }
    }
    for (final ligne in lignes) {
      if (!ordre.contains(ligne.person.id)) resultat.add(ligne);
    }
    return resultat;
  }

  void _ouvrirMenu(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top + _decalageMenu;
    final actuel = context.read<AppData>().triPersonnes;
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) => _MenuTri(
        haut: haut,
        actuel: actuel,
        onChoix: (tri) => context.read<AppData>().changerTri(tri),
      ),
    );
  }

  void _deplacer(
      BuildContext context, List<_Ligne> lignes, int ancien, int nouveau) {
    if (nouveau > ancien) nouveau -= 1;
    final ligne = lignes.removeAt(ancien);
    lignes.insert(nouveau, ligne);
    context
        .read<AppData>()
        .changerOrdrePersonnes(lignes.map((l) => l.person.id).toList());
  }

  /// Mode « par famille » : un titre par famille, puis ses personnes.
  List<Widget> _blocsFamilles(List<_Ligne> lignes) {
    final widgets = <Widget>[];
    String? familleCourante;
    for (final ligne in lignes) {
      if (ligne.family.id != familleCourante) {
        familleCourante = ligne.family.id;
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 10));
        widgets.add(SectionTitle(ligne.family.name));
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PersonneCard(ligne: ligne, afficherFamille: false),
      ));
    }
    return widgets;
  }

  Widget _liste(BuildContext context, List<_Ligne> lignes, TriPersonnes tri,
      EdgeInsets padding) {
    if (lignes.isEmpty) {
      return const EmptyState(emoji: '👤', title: 'Aucune personne');
    }

    if (tri == TriPersonnes.manuel) {
      return ReorderableListView.builder(
        padding: padding,
        itemCount: lignes.length,
        buildDefaultDragHandles: false,
        proxyDecorator: (child, _, __) =>
            Material(type: MaterialType.transparency, child: child),
        onReorder: (ancien, nouveau) =>
            _deplacer(context, lignes, ancien, nouveau),
        itemBuilder: (_, i) => ReorderableDelayedDragStartListener(
          key: ValueKey(lignes[i].person.id),
          index: i,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PersonneCard(ligne: lignes[i], afficherFamille: true),
          ),
        ),
      );
    }

    if (tri == TriPersonnes.famille) {
      return ListView(padding: padding, children: _blocsFamilles(lignes));
    }

    return ListView.separated(
      padding: padding,
      itemCount: lignes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) =>
          _PersonneCard(ligne: lignes[i], afficherFamille: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final tri = data.triPersonnes;
    final lignes = _trier(data.families, tri, data.ordrePersonnes);

    return Scaffold(
      body: NeuPage(
        header: Row(
          children: [
            const Expanded(child: PageTitle('Personnes')),
            NeuIconButton(
              icon: Icons.filter_list_rounded,
              onTap: () => _ouvrirMenu(context),
            ),
          ],
        ),
        builder: (padding) => _liste(context, lignes, tri, padding),
      ),
    );
  }
}

// ─── Popup de choix du tri ───────────────────────────────────────────────────
class _MenuTri extends StatelessWidget {
  final double haut;
  final TriPersonnes actuel;
  final ValueChanged<TriPersonnes> onChoix;
  const _MenuTri(
      {required this.haut, required this.actuel, required this.onChoix});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: haut, right: 16),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 210,
            padding: const EdgeInsets.all(8),
            decoration: neuBoxOut(radius: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final tri in TriPersonnes.values)
                  _ChoixTri(
                    label: _nomsTri[tri]!,
                    actif: tri == actuel,
                    onTap: () {
                      onChoix(tri);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoixTri extends StatelessWidget {
  final String label;
  final bool actif;
  final VoidCallback onTap;
  const _ChoixTri(
      {required this.label, required this.actif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: actif ? neuBoxIn(radius: 12) : const BoxDecoration(),
          child: Text(
            label,
            style: TextStyle(
              color: actif ? kAccent : kTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Carte d'une personne ────────────────────────────────────────────────────
class _PersonneCard extends StatelessWidget {
  final _Ligne ligne;
  final bool afficherFamille; // faux quand la famille est déjà en titre
  const _PersonneCard({required this.ligne, required this.afficherFamille});

  @override
  Widget build(BuildContext context) {
    final family = ligne.family;
    final person = ligne.person;
    final stats = personStats(person);

    return GestureDetector(
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
                  Text(
                    afficherFamille ? '${family.name} · $stats' : stats,
                    style: const TextStyle(color: kTextSecond, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kTextSecond),
          ],
        ),
      ),
    );
  }
}
