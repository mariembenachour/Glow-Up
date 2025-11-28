import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/produit_service.dart';

class AjouterModifierProduitPage extends StatefulWidget {
  final Map? produit; // Pour modification
  const AjouterModifierProduitPage({super.key, this.produit});

  @override
  State<AjouterModifierProduitPage> createState() =>
      _AjouterModifierProduitPageState();
}

class _AjouterModifierProduitPageState
    extends State<AjouterModifierProduitPage> {
  final ProduitService service = ProduitService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();

  File? imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.produit != null) {
      nomCtrl.text = widget.produit!["nom"] ?? "";
      descCtrl.text = widget.produit!["description"] ?? "";
      typeCtrl.text = widget.produit!["type"] ?? "";
    }
  }

  // 📸 Sélection d’image
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  // 💾 Validation + enregistrement
  void enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    bool ok;

    if (widget.produit != null) {
      ok = await service.modifierProduit(
        widget.produit!["id"],
        nomCtrl.text,
        descCtrl.text,
        typeCtrl.text,
        imageFile?.path,
      );
    } else {
      ok = await service.ajouterProduit(
        nomCtrl.text,
        descCtrl.text,
        typeCtrl.text,
        imageFile?.path,
      );
    }

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Produit enregistré !")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(widget.produit != null ? "Modifier produit" : "Ajouter produit"),
        backgroundColor: Colors.brown.withOpacity(0.7),
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg-prod.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // ===================== TEXTFIELDS =====================
                        _styledField(
                          controller: nomCtrl,
                          label: "Nom du produit",
                          icon: Icons.label,
                          validator: (v) =>
                          v!.isEmpty ? "Le nom est obligatoire" : null,
                        ),

                        const SizedBox(height: 12),

                        _styledField(
                          controller: descCtrl,
                          label: "Description",
                          icon: Icons.description,
                          validator: (v) =>
                          v!.length < 10 ? "Description trop courte" : null,
                        ),

                        const SizedBox(height: 12),

                        _styledField(
                          controller: typeCtrl,
                          label: "Type",
                          icon: Icons.category,
                          validator: (v) =>
                          v!.isEmpty ? "Le type est obligatoire" : null,
                        ),

                        const SizedBox(height: 25),

                        // ===================== IMAGE PICKER =====================
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 170,
                            decoration: BoxDecoration(
                              color: Colors.brown.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.brown.withOpacity(0.3),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: imageFile != null
                                  ? Image.file(imageFile!, fit: BoxFit.cover)
                                  : widget.produit?["imageUrl"] != null
                                  ? Image.network(
                                "http://10.0.2.2:8080${widget.produit!["imageUrl"]}",
                                fit: BoxFit.cover,
                              )
                                  : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        color: Colors.brown, size: 30),
                                    const SizedBox(height: 6),
                                    Text("Choisir une image",
                                        style: TextStyle(
                                          color: Colors.brown.shade700,
                                          fontSize: 14,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ===================== BOUTON ENREGISTRER =====================
                        ElevatedButton(
                          onPressed: enregistrer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C4033),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            "Enregistrer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================
  // WIDGET CHAMP STYLÉ (marron/beige, icône, label flottant)
  // ========================================================
  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown.shade700),
        filled: true,
        fillColor: const Color(0xFFF6EEDC),
        labelStyle: TextStyle(color: Colors.brown.shade700),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF5C4033), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
          BorderSide(color: Colors.brown.withOpacity(0.3), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
