import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/neu_widgets.dart';
import '../widgets/dialogs.dart';

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
  void dispose() {
    _foodCtrl.dispose();
    super.dispose();
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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _PersonHeader(
              person: person,
              onEdit: () => _showEditDialog(person),
              onDelete: () => _showDeleteDialog(person),
            ),
            const SectionTitle('Aliments à éviter'),
            _AddFoodRow(controller: _foodCtrl, onAdd: _addFood),
            const SizedBox(height: 20),
            person.dislikedFoods.isEmpty
                ? const EmptyState(
                    emoji: '😋',
                    title: 'Aucun aliment à éviter',
                    subtitle: 'Ajoutez un aliment ci-dessus',
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
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
      onConfirm: (name, emoji) => context
          .read<AppData>()
          .updatePerson(widget.familyId, person.id, name, emoji),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: neuBoxOut(radius: 24),
      child: Row(
        children: [
          NeuIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            color: kTextPrimary,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          EmojiAvatar(emoji: person.emoji, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                Text(personStats(person),
                    style: const TextStyle(color: kTextSecond, fontSize: 13)),
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
      ),
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
          padding: const EdgeInsets.all(14),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}
