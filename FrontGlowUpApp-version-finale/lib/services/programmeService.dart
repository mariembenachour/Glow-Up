import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgrammeService {
  static const String baseUrl = "http://10.0.2.2:8080";

  // Lister les programmes attribués à un client
  static Future<List<Map<String, dynamic>>> getProgrammesByClient(int clientId) async {
    final url = Uri.parse("$baseUrl/api/programmes/client/$clientId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception("Erreur récupération programmes: ${response.statusCode}");
    }
  }
  static Future<Map<String, dynamic>> creerProgramme({
    required int coachId,
    required String objectif,
  }) async {
    final url = Uri.parse('$baseUrl/coachs/$coachId/programmes');

    final body = jsonEncode({
      "objectif": objectif,
      "duree": DateTime.now().toIso8601String(),
      "seances": []
    });

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (resp.statusCode == 201) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Erreur création programme: ${resp.statusCode}');
    }
  }
  // Attribuer un programme à un client
  static Future<Map<String, dynamic>> attribuerProgramme(int programmeId, int clientId) async {
    final url = Uri.parse("$baseUrl/api/programmes/$programmeId/attribuer/$clientId");
    final response = await http.put(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur attribution programme: ${response.statusCode}");
    }
  }


}
