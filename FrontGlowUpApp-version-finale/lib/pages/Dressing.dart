import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/APIService.dart';

class DressingPage extends StatefulWidget {
  final int idClient;

  const DressingPage({super.key, required this.idClient});

  @override
  State<DressingPage> createState() => _DressingPageState();
}

class _DressingPageState extends State<DressingPage> {
  List<Map<String, dynamic>> _vetementsData = [];
  final ImagePicker _picker = ImagePicker();

  int? _idDressing;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialiserDressingEtChargerVetements();
  }

  Future<void> _initialiserDressingEtChargerVetements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final idClient = widget.idClient;

      final idDressing = await ApiService.getOrCreateDressing(idClient);

      if (idDressing != null) {
        _idDressing = idDressing;
        await _chargerVetements();
      } else {
        _errorMessage =
        "Erreur: Le dressing n'a pas pu être créé ou récupéré.";
      }
    } catch (e) {
      _errorMessage = "Erreur de connexion: $e";
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _chargerVetements() async {
    if (_idDressing == null) {
      setState(() {
        _errorMessage = "ID Dressing manquant.";
      });
      return;
    }

    try {
      var data = await ApiService.getVetements(_idDressing!);
      if (mounted) {
        setState(() {
          _vetementsData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erreur de chargement: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _supprimerVetement(int index) async {
    final vetement = _vetementsData[index];
    final int idVetement =
        vetement['idVetement'] ?? vetement['id'] ?? 0;

    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer"),
        content: Text("Supprimer '${vetement['nom']}' ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      bool success = await ApiService.supprimerVetement(idVetement);

      if (success && mounted) {
        setState(() => _vetementsData.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Vêtement supprimé."),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _ouvrirFormulaire({Map<String, dynamic>? vetementPourModification}) async {
    if (_idDressing == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Dressing non initialisé."),
          backgroundColor: Colors.orange));
      return;
    }

    final bool isModification = vetementPourModification != null;

    File? _image;
    final _formKey = GlobalKey<FormState>();

    String _nom = vetementPourModification?['nom'] ?? '';
    String _couleur = vetementPourModification?['couleur'] ?? '';
    String _saison = vetementPourModification?['saison'] ?? 'Printemps';
    String _taille = vetementPourModification?['taille'] ?? 'M';
    String _type = vetementPourModification?['type'] ?? '';
    String? _imageUrl = vetementPourModification?['image'] ??
        vetementPourModification?['imageUrl'];
    String? _deleteImageFlag;

    final List<String> _saisons = ['Printemps', 'Été', 'Automne', 'Hiver'];
    final List<String> _tailles = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    Future<void> _choisirImage(ImageSource source, setStateDialog) async {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setStateDialog(() {
          _image = File(picked.path);
          _imageUrl = null;
          _deleteImageFlag = null;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.pink[50],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              isModification ? "Modifier $_nom" : "Ajouter",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.pinkAccent),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final source =
                        await showModalBottomSheet<ImageSource>(
                          context: context,
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text("Galerie"),
                                  onTap: () => Navigator.pop(
                                      context, ImageSource.gallery)),
                              ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text("Caméra"),
                                  onTap: () => Navigator.pop(
                                      context, ImageSource.camera)),
                            ],
                          ),
                        );

                        if (source != null) {
                          await _choisirImage(source, setStateDialog);
                        }
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(20)),
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ? Image.network(_imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image))
                            : const Center(
                            child: Icon(Icons.add_a_photo,
                                size: 40, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      initialValue: _nom,
                      decoration:
                      const InputDecoration(labelText: "Nom"),
                      onSaved: (v) => _nom = v ?? '',
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "Obligatoire" : null,
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      initialValue: _couleur,
                      decoration:
                      const InputDecoration(labelText: "Couleur"),
                      onSaved: (v) => _couleur = v ?? '',
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "Obligatoire" : null,
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      decoration:
                      const InputDecoration(labelText: "Saison"),
                      value: _saison,
                      items: _saisons
                          .map((s) => DropdownMenuItem(
                          value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) =>
                          setStateDialog(() => _saison = v ?? 'Printemps'),
                      onSaved: (v) => _saison = v ?? 'Printemps',
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      decoration:
                      const InputDecoration(labelText: "Taille"),
                      value: _taille,
                      items: _tailles
                          .map((t) => DropdownMenuItem(
                          value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setStateDialog(() => _taille = v ?? 'M'),
                      onSaved: (v) => _taille = v ?? 'M',
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      initialValue: _type,
                      decoration:
                      const InputDecoration(labelText: "Type"),
                      onSaved: (v) => _type = v ?? '',
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "Obligatoire" : null,
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        _formKey.currentState!.save();

                        Map<String, dynamic>? result;

                        if (isModification) {
                          result = await ApiService.modifierVetement(
                            vetementPourModification!['idVetement'] ??
                                vetementPourModification['id'],
                            _nom,
                            _couleur,
                            _saison,
                            _taille,
                            _type,
                            _image,
                            _deleteImageFlag,
                          );
                        } else {
                          if (_image == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Image obligatoire"),
                                    backgroundColor: Colors.orange));
                            return;
                          }

                          result = await ApiService.ajouterVetement(
                            _idDressing!,
                            _nom,
                            _couleur,
                            _saison,
                            _taille,
                            _type,
                            _image!,
                          );
                        }

                        if (result != null) {
                          await _chargerVetements();
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: Text(
                          isModification ? "Modifier" : "Ajouter",
                          style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: Center(child: Text(_errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Dressing",
            style: TextStyle(
                color: Colors.white,
                fontSize: width < 380 ? 14 : 18)),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: _vetementsData.isEmpty
          ? Center(
        child: Text(
          "Aucun vêtement.\nCliquez sur +",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 18, color: Colors.pink),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vetementsData.length,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: width < 600 ? 2 : 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final vet = _vetementsData[index];

          final String imageUrl =
              vet['image'] ?? vet['imageUrl'] ?? "";

          return GestureDetector(
            onTap: () => _ouvrirFormulaire(
                vetementPourModification: vet),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(imageUrl,
                        fit: BoxFit.cover)
                        : const Center(child: Text("No image")),

                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            _supprimerVetement(index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => _ouvrirFormulaire(),
        child: const Icon(Icons.add),
      ),
    );
  }
}