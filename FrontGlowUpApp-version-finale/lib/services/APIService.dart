import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ⚠️ ATTENTION : Si vous utilisez un téléphone physique, revenez à l'IP locale (192.168.1.xxx).
// Si vous êtes sur un émulateur Android, utilisez 10.0.2.2.
class ApiService {

  static const String baseUrl = "http://10.0.2.2:8080";

  static const String dressingApiPath = "/dressings/monDressing";

  static const String clientApiPath = "/clients";
  // -------------------------

  // --- 1. GESTION DU DRESSING ---

  /// Tente de récupérer l'ID du dressing pour [idClient] ou le crée si inexistant.
  static Future<int?> getOrCreateDressing(int idClient) async {
    final url = Uri.parse('$baseUrl$dressingApiPath/$idClient');

    if (idClient <= 0) {
      debugPrint("Erreur critique: ID Client est invalide ($idClient). Annulation de l'appel API.");
      return null;
    }

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint("Réponse 200 de getOrCreateDressing: $data");

        // L'API Spring renvoie l'objet complet. On extrait la clé 'idDressing'
        final int? idDressing = data['idDressing'] is int
            ? data['idDressing']
            : null;

        if (idDressing != null) {
          return idDressing;
        }

        debugPrint("Erreur GET/200: La clé 'idDressing' n'a pas pu être extraite ou n'est pas un entier. Réponse: $data");
        return null;

      } else {
        debugPrint("Échec de getOrCreateDressing. Statut: ${response.statusCode}. Corps: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Erreur réseau getOrCreateDressing: $e");
      return null;
    }
  }

  // --- 2. GESTION DES VÊTEMENTS (CRUD) ---

  /// Récupère la liste des vêtements pour un dressing donné.
  static Future<List<Map<String, dynamic>>> getVetements(int idDressing) async {
    final url = Uri.parse('$baseUrl/vetements/dressing/$idDressing');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Le body est une liste de Map<String, dynamic>
        return List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      }
      debugPrint("Échec de getVetements. Statut: ${response.statusCode}. Corps: ${response.body}");
      return [];
    } catch (e) {
      debugPrint("Erreur réseau getVetements: $e");
      return [];
    }
  }

  // AJOUTER (POST multipart/form-data)
  // ✅ CORRIGÉ : L'URL est maintenant /vetements/dressing/{idDressing} (sans /multipart)
  // Retourne le vêtement créé (Map) ou null en cas d'échec
  static Future<Map<String, dynamic>?> ajouterVetement(
      int idDressing,
      String nom,
      String couleur,
      String saison,
      String taille,
      String type,
      File imageFile) async {

    var request = http.MultipartRequest(
      'POST',
      // CORRECTION DU CHEMIN : Suppression de '/multipart' pour correspondre à Spring
      Uri.parse('$baseUrl/vetements/dressing/$idDressing'),
    );

    request.fields['nom'] = nom;
    request.fields['couleur'] = couleur;
    request.fields['saison'] = saison;
    request.fields['taille'] = taille;
    request.fields['type'] = type;

    try {
      // Le contrôleur Spring attend le champ 'image'
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        return json.decode(respStr) as Map<String, dynamic>;
      }
      final respStr = await response.stream.bytesToString();
      debugPrint("Échec ajouterVetement. Statut: ${response.statusCode}. Corps: $respStr");
      return null;
    } catch (e) {
      debugPrint("Erreur réseau ajouterVetement: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> modifierVetement(
      int idVetement,
      String nom,
      String couleur,
      String saison,
      String taille,
      String type,
      File? nouvelleImage,
      String? deleteImageFlag) async {

    var request = http.MultipartRequest(
      'PUT',
      // CORRECTION DU CHEMIN : Correspondance avec @PutMapping("/modifier/{id}") de Spring
      Uri.parse('$baseUrl/vetements/modifier/$idVetement'),
    );

    request.fields['nom'] = nom;
    request.fields['couleur'] = couleur;
    request.fields['saison'] = saison;
    request.fields['taille'] = taille;
    request.fields['type'] = type;

    if (nouvelleImage != null) {
      // Le contrôleur Spring attend le champ 'image'
      request.files.add(await http.MultipartFile.fromPath('image', nouvelleImage.path));
    }

    // Le backend Spring attend le champ 'supprimerImage' avec la valeur "true"
    if (deleteImageFlag == 'DELETE_IMAGE_REQUEST') {
      request.fields['supprimerImage'] = 'true';
    } else {
      // Envoyer "false" si la suppression n'est pas demandée (bonne pratique)
      request.fields['supprimerImage'] = 'false';
    }
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return json.decode(respStr) as Map<String, dynamic>;
      }
      final respStr = await response.stream.bytesToString();
      debugPrint("Échec modifierVetement. Statut: ${response.statusCode}. Corps: $respStr");
      return null;
    } catch (e) {
      debugPrint("Erreur réseau modifierVetement: $e");
      return null;
    }
  }

  static Future<bool> supprimerVetement(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/vetements/$id'));
      if (response.statusCode != 200) {
        debugPrint("Échec suppression. Statut: ${response.statusCode}. Corps: ${response.body}");
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erreur réseau supprimerVetement: $e");
      return false;
    }
  }

  // --- 3. GESTION DES CLIENTS (ajouté pour la complétude) ---

  /// Récupère les détails complets d'un client par son ID.
  static Future<Map<String, dynamic>?> getClientDetails(int idClient) async {
    final url = Uri.parse('$baseUrl$clientApiPath/$idClient');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data;
      }

      debugPrint("Échec de getClientDetails. Statut: ${response.statusCode}. Corps: ${response.body}");
      return null;

    } catch (e) {
      debugPrint("Erreur réseau getClientDetails: $e");
      return null;
    }
  }
  //Récupérer la liste des coachs
  static Future<List<dynamic>> fetchCoachs() async {
    final response = await http.get(Uri.parse("$baseUrl/coachs"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement des coachs");
    }
  }
  static Future<List<dynamic>> fetchProgrammes(int idClient) async {
    final response = await http.get(Uri.parse("$baseUrl/programmes/$idClient"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors du chargement des programmes");
    }
  }
  // 🔹 Envoyer une demande à un coach
  static Future<http.Response> envoyerDemande({
    required String titre,
    required String description,
    required int clientId,
    required int coachId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/demandes');

    final body = json.encode({
      "titre": titre,
      "descriptionBesoins": description,
      "etat": "en attente",
      "client": {"idUser": clientId},
      "coach": {"idUser": coachId}
    });

    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return resp;
  }


}
