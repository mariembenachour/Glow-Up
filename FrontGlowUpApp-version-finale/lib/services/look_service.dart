import 'dart:convert';
import 'package:http/http.dart' as http;

class LookService {
  static const String baseUrl = "http://10.0.2.2:8080/looks";

  Future<Map<String, dynamic>> createLook({
    required String nom,
    required String categorie,
    required String description,
    required bool favoris,
    required List<int> vetementIds,
    required int idClient,
    required int idStyliste,
  }) async {
    // 🔗 Construire l’URL avec tous les paramètres que Spring attend
    final queryParams = [
      for (final id in vetementIds) "vetementIds=$id",
      "idClient=$idClient",
      "idStyliste=$idStyliste",
    ].join("&");

    final url = Uri.parse("$baseUrl?$queryParams");

    // 📦 Corps JSON envoyé (on ajoute ici le client pour le garder côté Flutter)
    final body = jsonEncode({
      "nom": nom,
      "categorie": categorie,
      "description": description,
      "favoris": favoris,
      "client": {"idClient": idClient}, // 👈 ajouté
    });

    print("➡️ POST $url");
    print("📦 Body: $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("📥 Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
        "Erreur lors de la création du look : ${response.statusCode} ${response.body}",
      );
    }
  }
  Future<List<dynamic>> getLooksByClient(int idClient) async {
    final url = Uri.parse('$baseUrl/client/$idClient');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception("Erreur de décodage JSON : $e");
      }
    } else {
      throw Exception("Erreur serveur : ${response.statusCode}");
    }
  }

  Future<void> updateFavoris(int idLook, bool favoris) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$idLook/favoris"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"favoris": favoris}),
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la mise à jour du favori");
    }
  }

  Future<List<dynamic>> getAllLooks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Erreur lors du chargement des looks");
    }
  }

  Future<void> deleteLook(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erreur lors de la suppression du look");
    }
  }
}
