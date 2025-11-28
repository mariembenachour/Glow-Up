import 'package:flutter/material.dart';
import 'package:glowupf/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilPage extends StatefulWidget {
  final int userId;
  final String userType;

  const ProfilPage({super.key, required this.userId, required this.userType});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ancienMdpController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();
  final TextEditingController _mdpConfirmController = TextEditingController();
  bool loading = false;

  Future<void> _changerMotDePasse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final success = await AuthService.modifierMotDePasse(
      widget.userId,
      _ancienMdpController.text,
      _mdpController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe modifié avec succès ✅")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : ancien mot de passe incorrect ou problème serveur")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Profil", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/changermdp.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6), // Fond semi-transparent
              borderRadius: BorderRadius.circular(25),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Modifier votre mot de passe",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ancien mot de passe
                  TextFormField(
                    controller: _ancienMdpController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Ancien mot de passe",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? "Veuillez saisir votre ancien mot de passe"
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Nouveau mot de passe
                  TextFormField(
                    controller: _mdpController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Nouveau mot de passe",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? "Veuillez saisir un mot de passe" : null,
                  ),
                  const SizedBox(height: 15),

                  // Confirmer mot de passe
                  TextFormField(
                    controller: _mdpConfirmController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Confirmer mot de passe",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                    v != _mdpController.text ? "Les mots de passe ne correspondent pas" : null,
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: loading ? null : _changerMotDePasse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.black45,
                      elevation: 5,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text(
                      "Modifier",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}