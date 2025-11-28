import 'dart:convert';
import 'package:http/http.dart' as http;

class DermatologueService {
  static const String baseUrl = "http://10.0.2.2:8080";

  /// 🔹 Ajouter un dermatologue
  static Future<Map<String, dynamic>?> ajouterDermatologue(
      Map<String, dynamic> dermatologue) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/utilisateurs/dermatologue"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dermatologue),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      print("Erreur ajouterDermatologue: ${response.body}");
      return null;
    } catch (e) {
      print("Erreur réseau ajouterDermatologue: $e");
      return null;
    }
  }

  /// 🔹 Récupérer tous les dermatologues depuis la BD
  static Future<List<dynamic>?> getDermatologues() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/dermato"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // retourne LISTE DIRECTE (pas de modèle)
      }

      print("Erreur getDermatologues: ${response.body}");
      return null;
    } catch (e) {
      print("Erreur réseau getDermatologues: $e");
      return null;
    }
  }
}
