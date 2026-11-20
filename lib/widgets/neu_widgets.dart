import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─── NeuCard ──────────────────────────────────────────────────────────────
class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  const NeuCard(
      {super.key, required this.child, this.padding, this.radius = 16});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: neuBoxOut(radius: radius),
        child: child,
      );
}

// ─── NeuButton ────────────────────────────────────────────────────────────
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? color;
  final double radius;
  final EdgeInsets? padding;
  const NeuButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color,
    this.radius = 14,
    this.padding,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isAccent = widget.color != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: _pressed
            ? neuBoxIn(radius: widget.radius)
            : (isAccent
                ? neuBoxAccent(radius: widget.radius)
                : neuBoxOut(radius: widget.radius)),
        child: DefaultTextStyle(
          style: TextStyle(
            color: isAccent && !_pressed ? Colors.white : kTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── NeuIconButton : petit bouton carré (retour, modifier, supprimer) ─────
class NeuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const NeuIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = kTextSecond,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          decoration: neuBoxOut(radius: 10),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ─── NeuFab ───────────────────────────────────────────────────────────────
class NeuFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const NeuFab({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: neuBoxAccent(radius: 16),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      );
}

// ─── NeuChip ──────────────────────────────────────────────────────────────
class NeuChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  const NeuChip({super.key, required this.label, this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        decoration: neuBoxOutSmall(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: kDangerChip, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: kDanger),
                ),
              ),
            ],
          ],
        ),
      );
}

// ─── NeuTextField ─────────────────────────────────────────────────────────
class NeuTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLength;
  final bool autofocus;
  final VoidCallback? onSubmitted;
  const NeuTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength = 40,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  State<NeuTextField> createState() => _NeuTextFieldState();
}

class _NeuTextFieldState extends State<NeuTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: Container(
        decoration: _focused
            ? neuBoxIn(radius: 14).copyWith(boxShadow: neuShadowFocus)
            : neuBoxIn(radius: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
          onSubmitted: (_) => widget.onSubmitted?.call(),
          style: const TextStyle(color: kTextPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: kTextSecond, fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ─── EmojiAvatar ──────────────────────────────────────────────────────────
class EmojiAvatar extends StatelessWidget {
  final String emoji;
  final double size;
  const EmojiAvatar({super.key, required this.emoji, this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: neuBoxOut(radius: size / 2),
        child:
            Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.5))),
      );
}

// ─── SectionTitle ─────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                color: kTextSecond,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
      );
}

// ─── EmptyState ───────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  const EmptyState(
      {super.key, required this.emoji, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style: const TextStyle(color: kTextSecond, fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      );
}

// ─── NeuProgressBar ───────────────────────────────────────────────────────
class NeuProgressBar extends StatelessWidget {
  final double ratio;
  final Color color;
  const NeuProgressBar({super.key, required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        height: 6,
        decoration: neuBoxIn(radius: 3),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: ratio.clamp(0.0, 1.0),
          child: Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
        ),
      );
}

// ─── NeuTabBar : sélecteur d'onglets ──────────────────────────────────────
class NeuTabBar extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const NeuTabBar(
      {super.key,
      required this.labels,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: neuBoxIn(radius: 14),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: labels.asMap().entries.map((e) {
          final active = e.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: active ? Colors.white : kTextSecond,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── NeuBottomNav : barre de navigation du bas ────────────────────────────
class NeuBottomNav extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const NeuBottomNav({
    super.key,
    required this.icons,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kBackgroundClear, kBackground],
                  stops: [0, 0.2],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: neuBoxOut(radius: 20),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: icons[i],
                        label: labels[i],
                        active: i == selected,
                        onTap: () => onChanged(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = active ? kAccent : kTextSecond;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: active ? neuBoxIn(radius: 14) : const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: couleur),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(
                    color: couleur, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── NeuPage : en-tête fixe, la liste défile dessous ──────────────────────
const double kHeaderHeight = 56; // hauteur du contenu de l'en-tête
const double kHeaderFade = 18; // dégradé sous l'en-tête

class NeuPage extends StatelessWidget {
  final Widget header;
  final double headerHeight;
  final Widget? fab;

  /// Construit la liste : donner [padding] à son ListView.
  final Widget Function(EdgeInsets padding) builder;

  const NeuPage({
    super.key,
    required this.header,
    required this.builder,
    this.headerHeight = kHeaderHeight,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context);
    final zone = inset.top + headerHeight;
    final total = zone + kHeaderFade;
    final bas = inset.bottom + 16 + (fab != null ? 72 : 0);

    return Stack(
      children: [
        Positioned.fill(
          child: builder(EdgeInsets.fromLTRB(16, zone + 4, 16, bas)),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: total,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [kBackground, kBackground, kBackgroundClear],
                  stops: [0, zone / total, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: inset.top,
          left: 16,
          right: 16,
          height: headerHeight,
          child: Align(alignment: Alignment.centerLeft, child: header),
        ),
        if (fab != null)
          Positioned(right: 16, bottom: inset.bottom + 16, child: fab!),
      ],
    );
  }
}

// ─── PageTitle : titre des en-têtes ───────────────────────────────────────
class PageTitle extends StatelessWidget {
  final String text;
  const PageTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: kTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5));
}
