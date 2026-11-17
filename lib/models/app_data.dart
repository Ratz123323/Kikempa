import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

// ─── AppData : ChangeNotifier (état global simple) ───────────────────────────
class AppData extends ChangeNotifier {
  AppData({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;
  List<Family> _families = [];
  Future<void> _saveQueue = Future.value();

  /// Lecture seule : on modifie uniquement via les méthodes ci-dessous.
  List<Family> get families => UnmodifiableListView(_families);

  // ─── Chargement / sauvegarde ─────────────────────────────────────────────
  Future<void> load() async {
    _families = await _storage.readFamilies();
    notifyListeners();
  }

  /// Notifie l'interface puis sauvegarde (les sauvegardes sont mises en file).
  void _commit() {
    notifyListeners();
    _saveQueue = _saveQueue
        .then((_) => _storage.writeFamilies(_families))
        .catchError((Object e) {
      debugPrint('Sauvegarde échouée : $e');
    });
  }

  // ─── Sauvegarde / restauration manuelle (prêt pour une future fonction) ──
  String exportJson() => _storage.encode(_families);

  bool importJson(String raw) {
    final imported = _storage.decode(raw);
    if (imported == null) return false;
    _families = imported;
    _commit();
    return true;
  }

  // ─── Recherches ──────────────────────────────────────────────────────────
  Family? familyById(String id) {
    for (final family in _families) {
      if (family.id == id) return family;
    }
    return null;
  }

  Person? personById(String familyId, String personId) {
    final family = familyById(familyId);
    if (family == null) return null;
    for (final person in family.members) {
      if (person.id == personId) return person;
    }
    return null;
  }

  /// Aliment -> nombre de personnes (toutes familles) qui ne l'aiment pas.
  Map<String, int> get foodCounts {
    final noms = <String, String>{}; // clé -> libellé affiché
    final nombres = <String, int>{}; // clé -> nombre de personnes

    for (final family in _families) {
      for (final person in family.members) {
        for (final food in person.dislikedFoods) {
          noms.putIfAbsent(foodKey(food), () => food);
        }
        for (final cle in person.dislikedFoods.map(foodKey).toSet()) {
          nombres[cle] = (nombres[cle] ?? 0) + 1;
        }
      }
    }

    return {
      for (final entry in nombres.entries) noms[entry.key]!: entry.value,
    };
  }

  // ─── Familles ────────────────────────────────────────────────────────────
  /// Retourne false si le nom est vide ou déjà utilisé par une autre famille.
  bool addFamily(String name) {
    final clean = name.trim();
    if (clean.isEmpty || _familyNameExists(clean)) return false;
    _families.add(Family(id: _uuid.v4(), name: clean));
    _commit();
    return true;
  }

  bool _familyNameExists(String name, {String? exceptId}) {
    final key = foodKey(name);
    return _families.any((f) => f.id != exceptId && foodKey(f.name) == key);
  }

  bool updateFamilyName(String familyId, String newName) {
    final family = familyById(familyId);
    final clean = newName.trim();
    if (family == null || clean.isEmpty) return false;
    if (_familyNameExists(clean, exceptId: familyId)) return false;
    family.name = clean;
    _commit();
    return true;
  }

  void deleteFamily(String familyId) {
    _families.removeWhere((f) => f.id == familyId);
    _commit();
  }

  // ─── Personnes ───────────────────────────────────────────────────────────
  /// Retourne false si le prénom est vide ou déjà utilisé dans cette famille.
  bool addPerson(String familyId, String name, String emoji) {
    final family = familyById(familyId);
    final clean = name.trim();
    if (family == null || clean.isEmpty) return false;
    if (_personNameExists(family, clean)) return false;
    family.members.add(Person(id: _uuid.v4(), name: clean, emoji: emoji));
    _commit();
    return true;
  }

  bool _personNameExists(Family family, String name, {String? exceptId}) {
    final key = foodKey(name);
    return family.members
        .any((p) => p.id != exceptId && foodKey(p.name) == key);
  }

  bool updatePerson(
      String familyId, String personId, String name, String emoji) {
    final family = familyById(familyId);
    final person = personById(familyId, personId);
    final clean = name.trim();
    if (family == null || person == null || clean.isEmpty) return false;
    if (_personNameExists(family, clean, exceptId: personId)) return false;
    person.name = clean;
    person.emoji = emoji;
    _commit();
    return true;
  }

  void deletePerson(String familyId, String personId) {
    final family = familyById(familyId);
    if (family == null) return;
    family.members.removeWhere((p) => p.id == personId);
    _commit();
  }

  // ─── Aliments non appréciés ──────────────────────────────────────────────
  /// Retourne false si l'aliment est vide ou déjà présent.
  bool addDislikedFood(String familyId, String personId, String food) {
    final person = personById(familyId, personId);
    if (person == null) return false;
    final clean = cleanFood(food);
    if (clean.isEmpty || person.containsFood(clean)) return false;
    person.dislikedFoods.add(clean);
    _commit();
    return true;
  }

  void removeDislikedFood(String familyId, String personId, String food) {
    final person = personById(familyId, personId);
    if (person == null) return;
    person.dislikedFoods.remove(food);
    _commit();
  }
}
