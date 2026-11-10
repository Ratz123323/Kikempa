import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'neu_widgets.dart';

class _FamilyAvatar extends StatelessWidget {
  const _FamilyAvatar();

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: neuBoxAccent(radius: 14),
        child: const Center(
            child: Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 24))),
      );
}

class _FamilyInfo extends StatelessWidget {
  final Family family;
  const _FamilyInfo({required this.family});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(family.name,
              style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(familyStats(family),
              style: const TextStyle(color: kTextSecond, fontSize: 13)),
        ],
      );
}

/// Carte affichée sur l'écran d'accueil, dans la liste des familles.
class FamilyCard extends StatelessWidget {
  final Family family;
  final VoidCallback onTap;
  const FamilyCard({super.key, required this.family, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        radius: 20,
        child: Row(
          children: [
            const _FamilyAvatar(),
            const SizedBox(width: 14),
            Expanded(child: _FamilyInfo(family: family)),
            const Icon(Icons.chevron_right_rounded, color: kTextSecond),
          ],
        ),
      ),
    );
  }
}

/// En-tête affiché en haut de l'écran d'une famille.
class FamilyHeader extends StatelessWidget {
  final Family family;
  final VoidCallback onBack;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FamilyHeader({
    super.key,
    required this.family,
    required this.onBack,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      radius: 20,
      child: Row(
        children: [
          NeuIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            color: kTextPrimary,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          const _FamilyAvatar(),
          const SizedBox(width: 14),
          Expanded(child: _FamilyInfo(family: family)),
          NeuIconButton(icon: Icons.edit_rounded, onTap: onRename),
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
