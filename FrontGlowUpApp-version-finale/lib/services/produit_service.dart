import 'dart:convert';
import 'package:http/http.dart' as http;

class ProduitService {
  final String baseUrl = "http://10.0.2.2:8080/api/produits";

  // 🔹 GET : Récupérer tous les produits
  Future<List<dynamic>> getProduits() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Erreur lors de la récupération des produits : ${res.statusCode}");
    }
  }

  // 🔹 POST : Ajouter un produit + image
  Future<bool> ajouterProduit(
      String nom,
      String description,
      String type,
      String? imagePath,
      ) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/add"));
    request.fields["nom"] = nom;
    request.fields["description"] = description;
    request.fields["type"] = type;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath("image", imagePath));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  // 🔹 PUT : Modifier un produit existant
  Future<bool> modifierProduit(
      int id,
      String nom,
      String description,
      String type,
      String? imagePath,
      ) async {
    var request = http.MultipartRequest(
      "PUT",
      Uri.parse("$baseUrl/update/$id"), // Assurez-vous que le backend a ce endpoint PUT
    );

    request.fields["nom"] = nom;
    request.fields["description"] = description;
    request.fields["type"] = type;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath("image", imagePath));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  // 🔹 DELETE : Supprimer un produit
  Future<bool> deleteProduit(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    return res.statusCode == 204;
  }
}
