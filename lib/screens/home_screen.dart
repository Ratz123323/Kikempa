import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../widgets/neu_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/family_card.dart';
import 'family_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final families = context.watch<AppData>().families;

    return Scaffold(
      body: NeuPage(
        header: const _Header(),
        fab: NeuFab(
          icon: Icons.add_rounded,
          onTap: () => _showAddDialog(context),
        ),
        builder: (padding) => families.isEmpty
            ? const EmptyState(emoji: '🏠', title: 'Aucune famille')
            : ReorderableListView.builder(
                padding: padding,
                itemCount: families.length,
                buildDefaultDragHandles: false,
                proxyDecorator: (child, _, __) =>
                    Material(type: MaterialType.transparency, child: child),
                onReorder: context.read<AppData>().reorderFamilies,
                itemBuilder: (ctx, i) => ReorderableDelayedDragStartListener(
                  key: ValueKey(families[i].id),
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FamilyCard(
                      family: families[i],
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) =>
                              FamilyScreen(familyId: families[i].id),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showTextInputDialog(
      context,
      title: 'Nouvelle famille',
      hint: 'Nom de la famille',
      confirmLabel: 'Créer',
      onConfirm: (name) {
        final ok = context.read<AppData>().addFamily(name);
        if (!ok) showMessage(context, 'Ce nom existe déjà');
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: PageTitle('Kikempa')),
        NeuIconButton(
          icon: Icons.settings_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}
