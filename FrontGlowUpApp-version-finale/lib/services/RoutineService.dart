import 'dart:convert';
import 'package:http/http.dart' as http;

class RoutineService {
  final String baseUrl = "http://10.0.2.2:8080/api/routines";

  Future<Map?> creerRoutineComplete(
      int utilisateurId,
      String titre,
      String description,
      String soinTime,
      List<int> produitIds,
      ) async {
    final url = Uri.parse("$baseUrl/utilisateur/$utilisateurId/complete");

    final body = jsonEncode({
      "titre": titre,
      "description": description,
      "soinTime": soinTime,
      "produits": produitIds,
    });

    final response = await http.post(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } else {
      print("Erreur backend : ${response.body}");
      return null;
    }

  }
  Future<List> getRoutinesByUser(int utilisateurId) async {
    final url = Uri.parse("$baseUrl/utilisateur/$utilisateurId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Erreur get routines : ${response.body}");
      return [];
    }
  }


  Future<bool> deleteRoutine(int routineId) async {
    final url = Uri.parse("$baseUrl/$routineId");

    final response = await http.delete(url);
    return response.statusCode == 204;
  }

  Future<Map?> ajouterProduits(int routineId, List<int> produitIds) async {
    final url = Uri.parse("$baseUrl/$routineId/produits");

    final body = jsonEncode(produitIds); // ⚡ envoyer juste les IDs

    final response = await http.put(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Erreur ajout produits : ${response.body}");
      return null;
    }
  }

  Future<Map?> modifierRoutine(
      int routineId, String titre, String description, String soinTime) async {
    final url = Uri.parse("$baseUrl/$routineId");

    final body = jsonEncode({
      "titre": titre,
      "description": description,
      "soinTime": soinTime,
    });

    final response = await http.put(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Erreur modification routine : ${response.body}");
      return null;
    }
  }
}