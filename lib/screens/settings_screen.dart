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
      body: NeuPage(
        header: Row(
          children: [
            NeuIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              color: kTextPrimary,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            const PageTitle('Réglages'),
          ],
        ),
        builder: (padding) => ListView(
          padding: padding,
          children: [
            const SectionTitle('Sauvegarde'),
            NeuCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeuButton(
                    onTap: () => _exporter(context),
                    color: kAccent,
                    child: const Center(child: Text('Exporter mes données')),
                  ),
                  const SizedBox(height: 12),
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
