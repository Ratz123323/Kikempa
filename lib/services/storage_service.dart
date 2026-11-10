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

  Future<void> writeFamilies(List<Family> families) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, encode(families));
  }

  String encode(List<Family> families) => jsonEncode({
        'version': kSchemaVersion,
        'families': families.map((f) => f.toJson()).toList(),
      });

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
