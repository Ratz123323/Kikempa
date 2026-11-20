import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/neu_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/family_card.dart';
import 'person_screen.dart';
import 'summary_screen.dart';

class FamilyScreen extends StatefulWidget {
  final String familyId;
  const FamilyScreen({super.key, required this.familyId});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  int _tab = 0;

  // Dernière version connue : évite un écran vide pendant l'animation
  // de fermeture quand la famille vient d'être supprimée.
  Family? _lastFamily;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final family = data.familyById(widget.familyId) ?? _lastFamily;
    if (family == null) return const Scaffold();
    _lastFamily = family;

    return Scaffold(
      body: NeuPage(
        headerHeight: 124,
        header: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FamilyHeader(
              family: family,
              onBack: () => Navigator.pop(context),
              onRename: () => _showRenameDialog(family),
              onDelete: () => _showDeleteDialog(family),
            ),
            const SizedBox(height: 8),
            NeuTabBar(
              labels: const ['👤 Membres', '📋 Résumé'],
              selected: _tab,
              onChanged: (v) => setState(() => _tab = v),
            ),
          ],
        ),
        fab: _tab == 0
            ? NeuFab(
                icon: Icons.person_add_rounded,
                onTap: () => _showAddPersonDialog(family.id),
              )
            : null,
        builder: (padding) => _tab == 0
            ? _MembersTab(family: family, padding: padding)
            : SummaryScreen(family: family, padding: padding),
      ),
    );
  }

  void _showRenameDialog(Family family) {
    showTextInputDialog(
      context,
      title: 'Renommer',
      hint: 'Nouveau nom',
      initialText: family.name,
      onConfirm: (name) {
        final ok = context.read<AppData>().updateFamilyName(family.id, name);
        if (!ok) showMessage(context, 'Ce nom existe déjà');
      },
    );
  }

  void _showDeleteDialog(Family family) {
    showDeleteDialog(
      context,
      title: 'Supprimer "${family.name}" ?',
      subtitle: 'Tous les membres et préférences seront perdus.',
      onConfirm: () {
        final data = context.read<AppData>();
        Navigator.pop(context); // ferme l'écran
        data.deleteFamily(family.id);
      },
    );
  }

  void _showAddPersonDialog(String familyId) {
    showPersonDialog(
      context,
      title: 'Nouveau membre',
      confirmLabel: 'Ajouter',
      onConfirm: (name, emoji) {
        final ok = context.read<AppData>().addPerson(familyId, name, emoji);
        if (!ok) showMessage(context, 'Ce prénom existe déjà');
      },
    );
  }
}

class _MembersTab extends StatelessWidget {
  final Family family;
  final EdgeInsets padding;
  const _MembersTab({required this.family, required this.padding});

  @override
  Widget build(BuildContext context) {
    if (family.members.isEmpty) {
      return const EmptyState(emoji: '👤', title: 'Aucun membre');
    }
    return ReorderableListView.builder(
      padding: padding,
      itemCount: family.members.length,
      buildDefaultDragHandles: false,
      proxyDecorator: (child, _, __) =>
          Material(type: MaterialType.transparency, child: child),
      onReorder: (ancien, nouveau) =>
          context.read<AppData>().reorderMembers(family.id, ancien, nouveau),
      itemBuilder: (context, i) => ReorderableDelayedDragStartListener(
        key: ValueKey(family.members[i].id),
        index: i,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PersonCard(family: family, person: family.members[i]),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Family family;
  final Person person;
  const _PersonCard({required this.family, required this.person});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PersonScreen(familyId: family.id, personId: person.id),
        ),
      ),
      child: NeuCard(
        padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 4),
                  Text(
                    personStats(person),
                    style: TextStyle(
                      color:
                          person.dislikedFoods.isEmpty ? kTextSecond : kAccent,
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
    );
  }
}
