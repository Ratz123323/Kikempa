import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neu_widgets.dart';

const List<String> kEmojis = [
  '😀',
  '😎',
  '🤓',
  '👦',
  '👧',
  '🧑',
  '👨',
  '👩',
  '🧓',
  '👴',
  '👵',
  '🧔',
  '👱',
  '🧒',
  '🐶',
  '🐱',
  '🦊',
  '🐻',
  '🐼',
  '🐨',
  '🐯',
];

// ─── Fonctions à appeler depuis les écrans ───────────────────────────────────

/// Dialogue avec un champ texte (nouvelle famille, renommer...).
void showTextInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required ValueChanged<String> onConfirm,
  String initialText = '',
  String confirmLabel = 'Valider',
}) {
  showDialog(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      hint: hint,
      initialText: initialText,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
    ),
  );
}

/// Dialogue prénom + avatar (nouveau membre, modifier).
void showPersonDialog(
  BuildContext context, {
  required String title,
  required void Function(String name, String emoji) onConfirm,
  String initialName = '',
  String? initialEmoji,
  String confirmLabel = 'Valider',
}) {
  showDialog(
    context: context,
    builder: (_) => _PersonDialog(
      title: title,
      initialName: initialName,
      initialEmoji: initialEmoji ?? kEmojis.first,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
    ),
  );
}

/// Dialogue de confirmation de suppression.
/// Ferme le dialogue, puis appelle [onConfirm].
void showDeleteDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required VoidCallback onConfirm,
  String confirmLabel = 'Supprimer',
}) {
  showDialog(
    context: context,
    builder: (_) => _DeleteDialog(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
    ),
  );
}

/// Petit message en bas de l'écran.
void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

// ─── Coque commune : défile et suit le clavier ───────────────────────────────
class _DialogShell extends StatelessWidget {
  final Widget child;
  const _DialogShell({required this.child});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          clipBehavior: Clip.none, // pour ne pas couper les ombres
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: neuBoxOut(radius: 28),
            child: child,
          ),
        ),
      );
}

class _DialogTitle extends StatelessWidget {
  final String text;
  const _DialogTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w700));
}

class _DialogButtons extends StatelessWidget {
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _DialogButtons({
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: NeuButton(
            onTap: onCancel,
            child: const Center(
                child: Text('Annuler', style: TextStyle(color: kTextSecond))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NeuButton(
            onTap: onConfirm,
            color: kAccent,
            child: Center(child: Text(confirmLabel)),
          ),
        ),
      ]);
}

// ─── Dialogue : champ texte ──────────────────────────────────────────────────
class _TextInputDialog extends StatefulWidget {
  final String title, hint, initialText, confirmLabel;
  final ValueChanged<String> onConfirm;
  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.initialText,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onConfirm(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogTitle(widget.title),
          const SizedBox(height: 20),
          NeuTextField(
            controller: _ctrl,
            hint: widget.hint,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: _submit,
          ),
          const SizedBox(height: 24),
          _DialogButtons(
            confirmLabel: widget.confirmLabel,
            onConfirm: _submit,
            onCancel: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ─── Dialogue : prénom + avatar ──────────────────────────────────────────────
class _PersonDialog extends StatefulWidget {
  final String title, initialName, initialEmoji, confirmLabel;
  final void Function(String name, String emoji) onConfirm;
  const _PersonDialog({
    required this.title,
    required this.initialName,
    required this.initialEmoji,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  State<_PersonDialog> createState() => _PersonDialogState();
}

class _PersonDialogState extends State<_PersonDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialName);
  late String _emoji = widget.initialEmoji;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    widget.onConfirm(name, _emoji);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogTitle(widget.title),
          const SizedBox(height: 20),
          NeuTextField(
            controller: _ctrl,
            hint: 'Prénom',
            textCapitalization: TextCapitalization.words,
            onSubmitted: _submit,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kEmojis.map((e) {
              final active = e == _emoji;
              return GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration:
                      active ? neuBoxAccent(radius: 11) : neuBoxOut(radius: 11),
                  child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 21))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _DialogButtons(
            confirmLabel: widget.confirmLabel,
            onConfirm: _submit,
            onCancel: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ─── Dialogue : suppression ──────────────────────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final String title, subtitle, confirmLabel;
  final VoidCallback onConfirm;
  const _DeleteDialog({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: kTextSecond, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: NeuButton(
                onTap: () => Navigator.pop(context),
                child: const Center(
                    child:
                        Text('Annuler', style: TextStyle(color: kTextSecond))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: kDangerSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                      child: Text(confirmLabel,
                          style: const TextStyle(
                              color: kDanger, fontWeight: FontWeight.w700))),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
