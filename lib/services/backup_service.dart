import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

const _nomFichier = 'kikempa_sauvegarde.json';

/// Ouvre le partage du téléphone avec un fichier .json contenant les données.
Future<void> exporterSauvegarde(String json) async {
  final fichier = XFile.fromData(
    Uint8List.fromList(utf8.encode(json)),
    mimeType: 'application/json',
  );
  await SharePlus.instance.share(
    ShareParams(files: [fichier], fileNameOverrides: [_nomFichier]),
  );
}

/// Retourne le texte du fichier choisi, ou null si l'utilisateur annule.
Future<String?> choisirSauvegarde() async {
  final resultat = await FilePicker.pickFiles(withData: true);
  if (resultat == null) return null;
  final octets = resultat.files.single.bytes;
  if (octets == null) return null;
  return utf8.decode(octets, allowMalformed: true);
}