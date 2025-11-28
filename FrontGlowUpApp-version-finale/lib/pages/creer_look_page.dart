import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/look_service.dart';

class CreerLookPage extends StatefulWidget {
  final int idClient;
  final int idStyliste;
  final List<int> vetementsSelectionnes;

  const CreerLookPage({
    super.key,
    required this.idClient,
    required this.idStyliste,
    required this.vetementsSelectionnes,
  });

  @override
  State<CreerLookPage> createState() => _CreerLookPageState();
}

class _CreerLookPageState extends State<CreerLookPage> {
  final LookService _lookService = LookService();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _categorie = "Sport";

  final List<String> _categories = [
    "Sport",
    "Chic",
    "Casual",
    "Soirée",
    "Streetwear",
    "Rock",
    "Vintage"
  ];

  Future<void> _creerLook() async {
    if (_nomController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      await _lookService.createLook(
        nom: _nomController.text,
        categorie: _categorie,
        description: _descriptionController.text,
        favoris: false, // toujours false par défaut
        vetementIds: widget.vetementsSelectionnes,
        idClient: widget.idClient,
        idStyliste: widget.idStyliste,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Look créé avec succès !')),
      );

      Navigator.pop(context); // Retour au dressing
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un look"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom du look'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _categorie,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _categorie = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _creerLook,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: const Text('Créer le look',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
