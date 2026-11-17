import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../theme/app_theme.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            Expanded(
              child: families.isEmpty
                  ? const EmptyState(
                      emoji: '🏠',
                      title: 'Aucune famille pour l\'instant',
                      subtitle: 'Appuyez sur + pour en ajouter une',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: families.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) => FamilyCard(
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
          ],
        ),
      ),
      floatingActionButton: NeuFab(
        icon: Icons.add_rounded,
        onTap: () => _showAddDialog(context),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Familles',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              NeuIconButton(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Gérez les préférences de chacun',
              style: TextStyle(color: kTextSecond, fontSize: 14)),
        ],
      ),
    );
  }
}
