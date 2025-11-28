// lib/pages/stylistes.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/demandeService.dart'; // <-- Vérifie le bon chemin vers ton service

class StylistesPage extends StatefulWidget {
  final int clientId; // ID du client connecté
  const StylistesPage({super.key, required this.clientId});

  @override
  State<StylistesPage> createState() => _StylistesPageState();
}

class _StylistesPageState extends State<StylistesPage> {
  List<Map<String, dynamic>> stylistes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStylists();
  }

  Future<void> fetchStylists() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/stylistes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> listeStyliste = data
            .where((user) =>
        (user['role'] == 'STYLISTE' ||
            (user['role']?.toString().toUpperCase() == 'STYLISTE')))
            .map<Map<String, dynamic>>((e) => {
          "idUser": e['idUser'] ?? e['id'] ?? e['idUtilisateur'],
          "nom": e['nom'] ?? '',
          "specialite": e['specialite'] ?? 'Non précisée',
        })
            .where((m) => m['idUser'] != null)
            .toList();

        setState(() {
          stylistes = listeStyliste;
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

  void _ouvrirPopupDemande(BuildContext context, Map<String, dynamic> styliste) {
    final _formKey = GlobalKey<FormState>();
    String titre = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Envoyer une demande à ${styliste['nom']}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.pinkAccent),
        ),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Titre", border: OutlineInputBorder()),
              validator: (value) =>
              value == null || value.isEmpty ? "Entrez un titre" : null,
              onSaved: (value) => titre = value ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Description", border: OutlineInputBorder()),
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
                  style: TextStyle(color: Colors.pinkAccent))),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);

                try {
                  // ✅ Appel correct de la méthode statique du service
                  final response = await DemandeService.envoyerDemande(
                    titre: titre,
                    description: description,
                    clientId: widget.clientId,
                    stylisteId: styliste['idUser'],
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
          title: Text("Nos stylistes",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.pinkAccent),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stylistes.isEmpty
          ? Center(
          child: Text("Aucun styliste trouvé",
              style: GoogleFonts.poppins()))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: stylistes.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85),
          itemBuilder: (context, index) {
            final s = stylistes[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 6)
                  ]),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s['nom'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(s['specialite'],
                        style: GoogleFonts.lato(
                            color: Colors.grey[700])),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () =>
                            _ouvrirPopupDemande(context, s),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent),
                        child: const Text("Demande",
                            style: TextStyle(color: Colors.white))),
                  ]),
            );
          },
        ),
      ),
    );
  }
}
