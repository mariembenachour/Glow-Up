import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = "http://10.0.2.2:8080";

  // Récupérer les notifications d’un utilisateur
  static Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final url = Uri.parse("$baseUrl/notifications/utilisateur/$userId");
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Erreur lors du chargement des notifications");
    }
  }

  static Future<void> marquerCommeLue(int notifId) async {
    final url = Uri.parse("$baseUrl/notifications/$notifId/lue");
    final resp = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (resp.statusCode != 200) {
      throw Exception("Impossible de marquer comme lue");
    }
  }

}