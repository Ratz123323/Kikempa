import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const _kStorageKey = 'families_data';
const _kBackupKey = 'families_data_backup';
const kSchemaVersion = 1;

/// Seul endroit qui sait COMMENT les données sont stockées.
/// Pour changer de stockage plus tard (SQLite, cloud...), on ne touche qu'ici.
class StorageService {
  Future<List<Family>> readFamilies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) return [];

    final families = decode(raw);
    if (families == null) {
      // Données illisibles : on les garde de côté au lieu de les écraser.
      await prefs.setString(_kBackupKey, raw);
      return [];
    }
    return families;
  }

  Future<void> writeFamilies(
      List<Family> families, TriPersonnes tri, List<String> ordre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, encode(families, tri, ordre));
  }

  Future<List<String>> readOrdre() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    return raw == null ? [] : decodeOrdre(raw);
  }

  Future<TriPersonnes> readTri() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    return raw == null ? TriPersonnes.famille : decodeTri(raw);
  }

  String encode(List<Family> families, TriPersonnes tri, List<String> ordre) =>
      jsonEncode({
        'version': kSchemaVersion,
        'triPersonnes': tri.name,
        'ordrePersonnes': ordre,
        'families': families.map((f) => f.toJson()).toList(),
      });

  /// Tri enregistré dans le texte (par famille si absent ou illisible).
  TriPersonnes decodeTri(String raw) {
    try {
      final nom = jsonDecode(raw)['triPersonnes'];
      return TriPersonnes.values.firstWhere((t) => t.name == nom);
    } catch (_) {
      return TriPersonnes.famille;
    }
  }

  /// Ordre manuel des personnes (liste vide si absent ou illisible).
  List<String> decodeOrdre(String raw) {
    try {
      return List<String>.from(jsonDecode(raw)['ordrePersonnes'] as List);
    } catch (_) {
      return [];
    }
  }

  /// Accepte l'ancien format (liste simple) et le nouveau (avec version).
  /// Retourne null si le texte est illisible.
  List<Family>? decode(String raw) {
    try {
      final data = jsonDecode(raw);
      final List list = data is List ? data : (data['families'] as List);
      return list
          .map((e) => Family.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
