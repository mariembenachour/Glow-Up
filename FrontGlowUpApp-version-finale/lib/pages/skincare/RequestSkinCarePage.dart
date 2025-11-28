import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'DermatologistsListPage.dart'; // Assurez-vous que ce fichier existe

class RequestSkinCarePage extends StatefulWidget {
  final int clientId;
  final int dermatologueId;

  const RequestSkinCarePage({
    super.key,
    required this.clientId,
    required this.dermatologueId,
  });

  @override
  State<RequestSkinCarePage> createState() => _RequestSkinCarePageState();
}

class _RequestSkinCarePageState extends State<RequestSkinCarePage> {
  final _formKey = GlobalKey<FormState>();
  String titre = '';
  String description = '';
  List<XFile> images = [];
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // 📸 Prendre photo ou choisir depuis la galerie
  Future<void> _pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images.add(picked));
  }

  Future<void> _takePhoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => images.add(picked));
  }

  // 🗑 Supprimer une image
  void _removeImage(XFile image) {
    setState(() => images.remove(image));
  }

  // 🔹 Envoyer la demande au backend
  Future<void> envoyerDemande() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      var uri = Uri.parse('http://10.0.2.2:8080/api/demandes/multipart');
      var request = http.MultipartRequest('POST', uri);

      // --- 1. JSON de la demande envoyé en MultipartFile.fromString ---
      final demandeMap = {
        "titre": titre,
        "descriptionBesoins": description,
        "client": {"idUser": widget.clientId},
        "dermatologue": {"idUser": widget.dermatologueId},
      };

      request.files.add(http.MultipartFile.fromString(
        'demande', // Correspond à @RequestPart("demande")
        jsonEncode(demandeMap),
        contentType: MediaType('application', 'json'),
      ));

      // --- 2. Ajouter les images ---
      for (var img in images) {
        final mimeType = lookupMimeType(img.path) ?? 'image/jpeg';
        final mediaType = mimeType.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          'images', // Correspond à @RequestPart("images")
          img.path,
          contentType: MediaType(mediaType[0], mediaType[1]),
        ));
      }

      // --- 3. Envoyer la requête ---
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Demande envoyée ✅")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DermatologistsListPage(clientId: widget.clientId),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur API : ${streamedResponse.statusCode}\n$responseBody")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/demandedermclient.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xff5C4033), size: 30),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DermatologistsListPage(clientId: widget.clientId),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Nouvelle Demande de Soins",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff5C4033),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Titre de la demande",
                              labelStyle: GoogleFonts.poppins(color: Colors.brown[700]),
                              filled: true,
                              fillColor: Colors.brown[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Entrez un titre" : null,
                            onSaved: (v) => titre = v ?? '',
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: "Description de vos besoins (symptômes, historique...)",
                              alignLabelWithHint: true,
                              labelStyle: GoogleFonts.poppins(color: Colors.brown[700]),
                              filled: true,
                              fillColor: Colors.brown[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Décrivez vos besoins" : null,
                            onSaved: (v) => description = v ?? '',
                          ),
                          const SizedBox(height: 20),
                          Text("Photos (Optionnel)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.brown[700])),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _takePhoto,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("Prendre photo"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffC69C6D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _pickImageFromGallery,
                                icon: const Icon(Icons.photo_library),
                                label: const Text("Galerie"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffC69C6D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: images.map((image) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(File(image.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(image),
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isLoading ? null : envoyerDemande,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff5C4033),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                                : Text(
                              "Envoyer la demande",
                              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}