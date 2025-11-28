import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// Définissez la base URL, comme dans ApiService
const String baseUrl = "http://10.0.2.2:8080";

// 🎯 CLASSE MODÈLE POUR LES RÉSULTATS DE CONNEXION
class LoginResult {
  final int idUser;
  final String role;
  final String token; // Token JWT (si utilisé par le backend)

  // ✅ CORRECTION DU CONSTRUCTEUR : 'this.this.role' remplacé par 'this.role'
  LoginResult({required this.idUser, required this.role, required this.token});
}


class AuthService {
  static const String baseUrlClient = "$baseUrl/clients";
  static const String baseUrlStyliste = "$baseUrl/stylistes";
  static const String baseUrlCoach = "$baseUrl/coachs";
  // Inscription Client (Gardée simple)
  static Future<Map<String, dynamic>> registerClient(Map<String, dynamic> client) async {
    final response = await http.post(
      Uri.parse('$baseUrlClient/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(client),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de l'inscription du client : ${response.body}");
    }
  }

  // Inscription Styliste
  static Future<Map<String, dynamic>> registerStyliste(Map<String, dynamic> styliste) async {
    final response = await http.post(
      Uri.parse('$baseUrlStyliste/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(styliste),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de l'inscription du styliste : ${response.body}");
    }
  }
// Inscription coach
  static Future<Map<String, dynamic>> registerCoach(Map<String, dynamic> coach) async {
    final response = await http.post(
      Uri.parse('$baseUrlCoach/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(coach),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de l'inscription du styliste : ${response.body}");
    }
  }

  // 🎯 FONCTION LOGIN : Renvoie LoginResult contenant l'ID, le rôle et le token
  static Future<LoginResult?> login(String email, String mdp) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "mdp": mdp}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // Le backend renvoie Map.of("token", token, "user", user)
        final userMap = data['user'] as Map<String, dynamic>?;
        final token = data['token'] as String? ?? ''; // Récupère le token

        if (userMap != null) {
          // Extraction des données de l'utilisateur
          final dynamic idValue = userMap['idUtilisateur'] ?? userMap['id'] ?? userMap['idUser'] ?? userMap['idclient'];
          final String role = userMap['role'] as String? ?? 'client'; // Supposons 'client' par défaut si le rôle n'est pas explicité

          if (idValue != null) {
            final int? idUser = idValue is int ? idValue : int.tryParse(idValue.toString());

            if (idUser != null && idUser > 0) {
              debugPrint("Connexion réussie. ID Utilisateur: $idUser, Rôle: $role");

              // Utilisation du constructeur corrigé
              return LoginResult(idUser: idUser, role: role, token: token);
            }
          }
          debugPrint("Erreur: ID utilisateur non trouvé ou invalide dans l'objet 'user'.");
          return null;
        }
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        debugPrint("Identifiants incorrects.");
        return null;
      } else {
        debugPrint("Échec de la connexion. Statut: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Erreur réseau lors de la connexion: $e");
      return null;
    }
    return null;
  }
  static Future<bool> modifierMotDePasse(int userId, String ancienMdp, String nouveauMdp) async {
    final url = Uri.parse("$baseUrl/api/utilisateurs/mdp/$userId");
    final body = jsonEncode({
      "ancienMdp": ancienMdp,
      "nouveauMdp": nouveauMdp,
    });

    try {
      final response = await http.put(url,
          headers: {"Content-Type": "application/json"}, body: body);

      debugPrint("Status code: ${response.statusCode}, body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erreur réseau: $e");
      return false;
    }
  }

}
