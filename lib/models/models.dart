// ─── Outils de texte pour les aliments ───────────────────────────────────────
const _accentsFrom = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿ';
const _accentsTo = 'aaaaaceeeeiiiinooooouuuuyy';

/// Nettoie un aliment saisi : espaces superflus retirés.
String cleanFood(String food) => food.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Clé de comparaison : minuscules, sans accents.
/// "Épinards" et "epinards" donnent la même clé.
String foodKey(String food) {
  final texte = cleanFood(food).toLowerCase();
  final resultat = StringBuffer();
  for (final lettre in texte.split('')) {
    final position = _accentsFrom.indexOf(lettre);
    resultat.write(position == -1 ? lettre : _accentsTo[position]);
  }
  return resultat.toString();
}

// ─── Modèle : Personne ───────────────────────────────────────────────────────
class Person {
  String id;
  String name;
  String emoji; // avatar emoji
  List<String> dislikedFoods;

  Person({
    required this.id,
    required this.name,
    required this.emoji,
    List<String>? dislikedFoods,
  }) : dislikedFoods = dislikedFoods ?? [];

  /// Vrai si cet aliment (casse/accents ignorés) est déjà dans la liste.
  bool containsFood(String food) {
    final key = foodKey(food);
    return dislikedFoods.any((f) => foodKey(f) == key);
  }

  // ─── Sérialisation JSON (tolérante aux champs manquants) ─────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'dislikedFoods': dislikedFoods,
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: (json['emoji'] as String?) ?? '🙂',
        dislikedFoods:
            List<String>.from((json['dislikedFoods'] as List?) ?? []),
      );
}

// ─── Modèle : Famille ────────────────────────────────────────────────────────
class Family {
  String id;
  String name;
  List<Person> members;

  Family({
    required this.id,
    required this.name,
    List<Person>? members,
  }) : members = members ?? [];

  /// Aliment -> noms des personnes qui ne l'aiment pas.
  /// Les variantes (casse, accents) sont regroupées sous un seul aliment.
  Map<String, List<String>> get dislikedFoodsByFood {
    final Map<String, String> displayNames = {}; // clé -> libellé affiché
    final Map<String, List<String>> personsByKey = {};

    for (final person in members) {
      final keys = person.dislikedFoods.map(foodKey).toSet();
      for (final food in person.dislikedFoods) {
        final key = foodKey(food);
        displayNames.putIfAbsent(key, () => food);
      }
      for (final key in keys) {
        personsByKey.putIfAbsent(key, () => []).add(person.name);
      }
    }

    return {
      for (final entry in personsByKey.entries)
        displayNames[entry.key]!: entry.value,
    };
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((p) => p.toJson()).toList(),
      };

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json['id'] as String,
        name: json['name'] as String,
        members: ((json['members'] as List?) ?? [])
            .map((m) => Person.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
