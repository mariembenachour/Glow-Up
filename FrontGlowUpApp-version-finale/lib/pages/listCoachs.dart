// lib/pages/listCoachPage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glowupf/services/APIService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/demandeService.dart';

class ListCoachPage extends StatefulWidget {
  final int idClient;
  const ListCoachPage({super.key, required this.idClient});

  @override
  State<ListCoachPage> createState() => _ListCoachPageState();
}

class _ListCoachPageState extends State<ListCoachPage> {
  List<Map<String, dynamic>> coachs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoachs();
  }

  Future<void> fetchCoachs() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/coachs'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> listeCoach = data
            .where((user) =>
        (user['role'] == 'COACH' ||
            (user['role']?.toString().toUpperCase() == 'COACH')))
            .map<Map<String, dynamic>>((e) => {
          "idUser": e['idUser'] ?? e['id'] ?? e['idUtilisateur'],
          "nom": e['nom'] ?? '',
          "domaine": e['domaine'] ?? 'Non précisé',
        })
            .where((m) => m['idUser'] != null)
            .toList();

        setState(() {
          coachs = listeCoach;
          isLoading = false;
        });
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  void _ouvrirPopupDemande(BuildContext context, Map<String, dynamic> coach) {
    final _formKey = GlobalKey<FormState>();
    String titre = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Envoyer une demande à ${coach['nom']}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
        ),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) =>
              value == null || value.isEmpty ? "Entrez un titre" : null,
              onSaved: (value) => titre = value ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty
                  ? "Entrez une description"
                  : null,
              onSaved: (value) => description = value ?? '',
            ),
          ]),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler",
                  style: TextStyle(color: Color(0xFF6C63FF)))),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C63FF)),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);

                try {
                  final response = await ApiService.envoyerDemande(
                    titre: titre,
                    description: description,
                    clientId: widget.idClient,
                    coachId: coach['idUser'],
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Demande envoyée !"),
                        backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Erreur envoi: ${response.statusCode} ${response.body}")));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur réseau: $e")));
                }
              }
            },
            child:
            const Text("Envoyer", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nos coachs",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/coachs.jpg"), // 🔹 ton image ici
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.5), // assombrit l'image
          child: isLoading
              ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
              : coachs.isEmpty
              ? Center(
              child: Text("Aucun coach trouvé",
                  style: GoogleFonts.poppins(color: Colors.white)))
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: coachs.length,
            itemBuilder: (context, index) {
              final c = coachs[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF6C63FF), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF6C63FF),
                          child: Icon(Icons.person,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(c['nom'],
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                            Text(
                                "Domaine : ${c['domaine'] ?? 'Non précisé'}",
                                style: GoogleFonts.lato(
                                    color: Colors.white70,
                                    fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _ouvrirPopupDemande(context, c),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Demande",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
