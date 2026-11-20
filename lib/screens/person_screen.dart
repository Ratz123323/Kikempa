import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/neu_widgets.dart';
import '../widgets/dialogs.dart';

// Réglages des suggestions
const _minLettres = 2; // lettres à taper avant d'afficher des suggestions
const _minPersonnes = 2; // personnes qui doivent détester l'aliment

class PersonScreen extends StatefulWidget {
  final String familyId;
  final String personId;
  const PersonScreen(
      {super.key, required this.familyId, required this.personId});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final _foodCtrl = TextEditingController();

  // Dernière version connue : évite un écran vide pendant l'animation
  // de fermeture quand la personne vient d'être supprimée.
  Person? _lastPerson;

  @override
  void initState() {
    super.initState();
    _foodCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _foodCtrl.dispose();
    super.dispose();
  }

  /// Aliments détestés par plusieurs personnes de l'app, pas encore dans
  /// la liste de cette personne, et qui correspondent à ce qui est tapé.
  List<String> _suggestions(AppData data, Person person) {
    final saisie = foodKey(_foodCtrl.text);
    if (saisie.length < _minLettres) return [];

    final resultat = <String>[];
    for (final entry in data.foodCounts.entries) {
      if (entry.value < _minPersonnes) continue;
      if (person.containsFood(entry.key)) continue;
      if (!foodKey(entry.key).contains(saisie)) continue;
      resultat.add(entry.key);
    }
    return resultat.take(8).toList();
  }

  void _addSuggestion(String food) {
    context
        .read<AppData>()
        .addDislikedFood(widget.familyId, widget.personId, food);
    _foodCtrl.clear();
  }

  void _addFood() {
    final food = _foodCtrl.text.trim();
    if (food.isEmpty) return;

    final added = context
        .read<AppData>()
        .addDislikedFood(widget.familyId, widget.personId, food);

    if (!added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Déjà dans la liste')));
    }
    _foodCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final person =
        data.personById(widget.familyId, widget.personId) ?? _lastPerson;
    if (person == null) return const Scaffold();
    _lastPerson = person;

    final suggestions = _suggestions(data, person);

    return Scaffold(
      body: NeuPage(
        header: _PersonHeader(
          person: person,
          onEdit: () => _showEditDialog(person),
          onDelete: () => _showDeleteDialog(person),
        ),
        builder: (padding) => ListView(
          padding: padding,
          children: [
            _AddFoodRow(controller: _foodCtrl, onAdd: _addFood),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map((food) => _SuggestionChip(
                          label: food,
                          onTap: () => _addSuggestion(food),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            person.dislikedFoods.isEmpty
                ? const EmptyState(emoji: '😋', title: 'Aucun aliment à éviter')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: person.dislikedFoods
                        .map((food) => NeuChip(
                              key: ValueKey(food),
                              label: food,
                              onDelete: () => context
                                  .read<AppData>()
                                  .removeDislikedFood(
                                      widget.familyId, widget.personId, food),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Person person) {
    showPersonDialog(
      context,
      title: 'Modifier',
      initialName: person.name,
      initialEmoji: person.emoji,
      onConfirm: (name, emoji) {
        final ok = context
            .read<AppData>()
            .updatePerson(widget.familyId, person.id, name, emoji);
        if (!ok) showMessage(context, 'Ce prénom existe déjà');
      },
    );
  }

  void _showDeleteDialog(Person person) {
    showDeleteDialog(
      context,
      title: 'Supprimer ${person.name} ?',
      subtitle: 'Toutes ses préférences seront perdues.',
      onConfirm: () {
        final data = context.read<AppData>();
        Navigator.pop(context); // ferme l'écran
        data.deletePerson(widget.familyId, person.id);
      },
    );
  }
}

class _PersonHeader extends StatelessWidget {
  final Person person;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PersonHeader(
      {required this.person, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NeuIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          color: kTextPrimary,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        EmojiAvatar(emoji: person.emoji),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(person.name,
                  style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(personStats(person),
                  style: const TextStyle(color: kTextSecond, fontSize: 12)),
            ],
          ),
        ),
        NeuIconButton(icon: Icons.edit_rounded, onTap: onEdit),
        const SizedBox(width: 8),
        NeuIconButton(
          icon: Icons.delete_outline_rounded,
          color: kDanger,
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _AddFoodRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  const _AddFoodRow({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NeuTextField(
            controller: controller,
            hint: 'Ex : épinards, foie…',
            onSubmitted: onAdd,
          ),
        ),
        const SizedBox(width: 12),
        NeuButton(
          onTap: onAdd,
          color: kAccent,
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: neuBoxOutSmall(radius: 20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.add_rounded, size: 14, color: kAccent),
          ],
        ),
      ),
    );
  }
}
