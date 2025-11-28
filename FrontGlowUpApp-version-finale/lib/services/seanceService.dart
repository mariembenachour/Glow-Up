// lib/services/SeanceService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SeanceService {
  static const String baseApi = "http://10.0.2.2:8080/api";

// ---------- CRÉER UNE SÉANCE ----------
  static Future<Map<String, dynamic>> creerSeanceClient({
    required int programmeId,
    required String description,
    required DateTime dateDeb,
    required DateTime dateFin,
    List? files,
  }) async {
    final url = Uri.parse("$baseApi/seances/programme/$programmeId");

    // Format correct exigé par ton backend
    String formatDate(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
            "${d.month.toString().padLeft(2, '0')}-"
            "${d.day.toString().padLeft(2, '0')}T"
            "${d.hour.toString().padLeft(2, '0')}:"
            "${d.minute.toString().padLeft(2, '0')}";

    var request = http.MultipartRequest("POST", url);
    request.fields["description"] = description;
    request.fields["heureDebut"] = formatDate(dateDeb);
    request.fields["heureFin"] = formatDate(dateFin);
    request.fields["createur"] = "CLIENT";
    if (files != null && files.isNotEmpty) {
      for (var img in files) {
        request.files.add(await http.MultipartFile.fromPath("files", img.path));
      }
    }

    final resp = await request.send();
    final body = await resp.stream.bytesToString();

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(body);
    } else {
      throw Exception("Erreur création séance: ${resp.statusCode} - $body");
    }
  }
  // Récupérer les séances d’un programme
  static Future<List<Map<String, dynamic>>> getSeancesByProgramme(int programmeId) async {
    final url = Uri.parse("$baseApi/seances/programme/$programmeId");
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    } else {
      throw Exception("Erreur récupération séances: ${resp.statusCode}");
    }
  }


  // Marquer comme complète
  static Future<Map<String, dynamic>> completerSeance(int seanceId) async {
    final url = Uri.parse("$baseApi/seances/$seanceId/completer");
    final response = await http.put(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur marquer complète: ${response.statusCode} ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> creerSeanceCoach(
      Map<String, dynamic> seanceData,
      int programmeId,
      List<XFile> images
      ) async {
    var uri = Uri.parse("$baseApi/seances/programme/$programmeId");
    var request = http.MultipartRequest("POST", uri);

    // Champs texte
    request.fields["description"] = seanceData["description"];
    request.fields["heureDebut"] = seanceData["heureDebut"];
    request.fields["heureFin"] = seanceData["heureFin"];
    request.fields["createur"] = "COACH";


    // Images
    for (var img in images) {
      print("Envoi image: ${img.path}");
      request.files.add(await http.MultipartFile.fromPath("images", img.path));
    }

    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr);
    } else {
      throw Exception("Erreur serveur: ${response.statusCode}");
    }
  }
// ---------- MODIFIER UNE SÉANCE ----------
  static Future<Map<String, dynamic>> modifierSeance({
    required int id,
    required String description,
    required DateTime dateDeb,
    required DateTime dateFin,
  }) async {
    final url = Uri.parse("$baseApi/seances/$id");

    String formatDate(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
            "${d.month.toString().padLeft(2, '0')}-"
            "${d.day.toString().padLeft(2, '0')}T"
            "${d.hour.toString().padLeft(2, '0')}:"
            "${d.minute.toString().padLeft(2, '0')}";

    final body = jsonEncode({
      "description": description,
      "heureDebut": formatDate(dateDeb),
      "heureFin": formatDate(dateFin),
    });

    final resp = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception("Erreur modification séance: ${resp.statusCode}");
    }
  }

  // ---------- SUPPRIMER UNE SÉANCE ----------
  static Future<void> supprimerSeance(int id) async {
    final url = Uri.parse("$baseApi/seances/$id");

    final resp = await http.delete(url);

    if (resp.statusCode != 200) {
      throw Exception("Erreur suppression séance: ${resp.statusCode}");
    }
  }


}