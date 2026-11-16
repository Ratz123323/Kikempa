import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';
import '../widgets/neu_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _exporter(BuildContext context) {
    final json = context.read<AppData>().exportJson();
    exporterSauvegarde(json);
  }

  Future<void> _importer(BuildContext context) async {
    final texte = await choisirSauvegarde();
    if (texte == null || !context.mounted) return;

    showDeleteDialog(
      context,
      title: 'Remplacer vos données ?',
      subtitle:
          'Les familles actuelles seront remplacées par celles du fichier.',
      confirmLabel: 'Remplacer',
      onConfirm: () {
        final ok = context.read<AppData>().importJson(texte);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(ok ? 'Données importées' : 'Fichier invalide')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              children: [
                NeuIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  color: kTextPrimary,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Réglages',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SectionTitle('Sauvegarde'),
            NeuCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Exportez vos données dans un fichier pour les envoyer '
                    'à un proche ou les garder en sécurité. Importez-les pour '
                    'les retrouver sur un autre téléphone.',
                    style: TextStyle(color: kTextSecond, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  NeuButton(
                    onTap: () => _exporter(context),
                    color: kAccent,
                    child: const Center(child: Text('Exporter mes données')),
                  ),
                  const SizedBox(height: 14),
                  NeuButton(
                    onTap: () => _importer(context),
                    child: const Center(child: Text('Importer un fichier')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}