import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DemandeService {
  // Gardez 10.0.2.2 pour l'émulateur Android.
  // Changez-le pour l'IP locale si vous utilisez un appareil physique.
  static const String baseUrl = 'http://10.0.2.2:8080/api/demandes';

  /// Envoi d'une demande
  static Future<http.Response> envoyerDemande({
    required String titre,
    required String description,
    required int clientId,
    int? stylisteId,
    int? coachId,
    int? dermatologueId,
    List<File>? images,
  }) async {

    // --- Cas Multipart : dermatologue AVEC images (Utilise la méthode V2 pour le 415) ---
    if (dermatologueId != null && images != null && images.isNotEmpty) {
      var uri = Uri.parse('$baseUrl/dermatologue');
      var request = http.MultipartRequest('POST', uri);

      // --- 1. Préparation de la partie JSON ('demande') ---
      final demandeMap = {
        "titre": titre,
        "descriptionBesoins": description,
        "client": {"idUser": clientId},
        "dermatologue": {"idUser": dermatologueId},
      };

      final demandeJsonString = json.encode(demandeMap);

      // FIX CLÉ : Envoi de la partie "demande" avec Content-Type: application/json
      // Ceci est nécessaire car le contrôleur Spring attend l'objet Demande ou une String avec ce Content-Type.
      request.files.add(http.MultipartFile.fromString(
        'demande', // Clé qui correspond à @RequestPart("demande")
        demandeJsonString,
        contentType: MediaType('application', 'json'),
      ));

      // --- 2. Ajout des parties Fichier ('images') ---
      for (var img in images) {
        final mimeType = lookupMimeType(img.path) ?? 'image/jpeg';
        final mediaType = mimeType.split('/');

        request.files.add(await http.MultipartFile.fromPath(
          'images', // Clé qui correspond à @RequestPart("images")
          img.path,
          contentType: MediaType(mediaType[0], mediaType[1]),
        ));
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);

    } else {
      // --- Cas JSON simple : Styliste, Coach ou Dermatologue sans images ---
      final body = json.encode({
        "titre": titre,
        "descriptionBesoins": description,
        "client": {"idUser": clientId},
        if (stylisteId != null) "styliste": {"idUser": stylisteId},
        if (coachId != null) "coach": {"idUser": coachId},
        if (dermatologueId != null) "dermatologue": {"idUser": dermatologueId},
      });

      // URL selon rôle
      final url = dermatologueId != null ? '$baseUrl/dermatologue/json' : baseUrl;

      return await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
    }
  }

  // --- GET toutes les demandes ---
  // CORRECTION : Ajout de 'async' pour la conformité de la signature Future
  static Future<List<Map<String, dynamic>>> getAllDemandes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erreur récupération demandes: ${response.statusCode}');
    }
  }

  // --- GET demandes par rôle ---
  static Future<List<Map<String, dynamic>>> getDemandesForCoach(int coachId) async {
    final response = await http.get(Uri.parse('$baseUrl/coach/$coachId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erreur récupération demandes: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getDemandesForStyliste(int stylisteId) async {
    final response = await http.get(Uri.parse('$baseUrl/styliste/$stylisteId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erreur récupération demandes: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getDemandesForDermatologue(int dermatologueId) async {
    if (dermatologueId <= 0) {
      throw Exception('ID dermatologue invalide');
    }

    final url = '$baseUrl/dermatologue/$dermatologueId';
    final resp = await http.get(Uri.parse(url));

    if (resp.statusCode != 200) {
      throw Exception('Échec du chargement des demandes. Statut: ${resp.statusCode}, Body: ${resp.body}');
    }

    final jsonData = json.decode(resp.body);

    // Accepte soit une liste, soit un objet avec clé "demandes"
    final List<dynamic> data = jsonData is List ? jsonData : (jsonData['demandes'] ?? []);

    return data.map<Map<String, dynamic>>((e) {
      final demande = e is Map<String, dynamic> ? e : {};

      // 🔒 Client : peut être un int ou un objet
      final clientRaw = demande['client'];
      final Map<String, dynamic> clientMap = {};
      if (clientRaw is Map) {
        clientMap.addAll(Map<String, dynamic>.from(clientRaw));
      } else if (clientRaw is int) {
        clientMap['idUser'] = clientRaw;
        clientMap['nom'] = 'Inconnu';
      } else {
        clientMap['idUser'] = 0;
        clientMap['nom'] = 'Inconnu';
      }

      // 🔒 Dermatologue : peut être un int ou un objet
      final dermRaw = demande['dermatologue'];
      final Map<String, dynamic> dermMap = {};
      if (dermRaw is Map) {
        dermMap.addAll(Map<String, dynamic>.from(dermRaw));
      } else if (dermRaw is int) {
        dermMap['idUser'] = dermRaw;
        dermMap['nom'] = 'Inconnu';
      } else {
        dermMap['idUser'] = 0;
        dermMap['nom'] = 'Inconnu';
      }

      // 🔹 Correction : transformer photoUrl en URL complète
      final rawPhoto = demande['photoUrl'];
      String? photoUrl;
      if (rawPhoto != null && rawPhoto is String && rawPhoto.isNotEmpty) {
        photoUrl = "http://10.0.2.2:8080/$rawPhoto";
      } else {
        photoUrl = null;
      }



      return {
        'idDemande': demande['idDemande'] ?? demande['id'] ?? 0,
        'titre': demande['titre'] ?? 'Sans titre',
        'descriptionBesoins': demande['descriptionBesoins'] ?? '',
        'etat': demande['etat'] ?? 'en attente',
        'photoUrl': photoUrl, // 🔹 URL complète
        'client': clientMap,
        'dermatologue': dermMap,
      };
    }).toList();
  }


  static Future<http.Response> changerEtat(int demandeId, String nouvelEtat) async {
    final url = '$baseUrl/etat/$demandeId';
    return await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"etat": nouvelEtat}),
    );
  }
}