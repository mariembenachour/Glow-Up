import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/// 🔹 Service pour appeler l'API Dermatologue
class DermatologueService {
  static const String baseUrl = "http://10.0.2.2:8080/api/utilisateurs/dermatologue";

  static Future<Map<String, dynamic>?> ajouterDermatologue(Map<String, dynamic> dermatologue) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dermatologue),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      print("Erreur ajouterDermatologue: ${response.body}");
      return null;
    } catch (e) {
      print("Erreur réseau ajouterDermatologue: $e");
      return null;
    }
  }
}

class InscriptionDermatoPage extends StatefulWidget {
  const InscriptionDermatoPage({super.key});

  @override
  State<InscriptionDermatoPage> createState() => _InscriptionDermatoPageState();
}

class _InscriptionDermatoPageState extends State<InscriptionDermatoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final dermatologue = {
        "nom": _nomController.text.trim(),
        "email": _emailController.text.trim(),
        "mdp": _mdpController.text.trim(),
        "role": "DERMATOLOGUE",
        "adresseCabinet": _adresseController.text.trim(),
      };

      final result = await DermatologueService.ajouterDermatologue(dermatologue);

      setState(() => _isLoading = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie ! 💖"), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/'); // Redirection vers la première page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'inscription"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff5C4033)),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? "Veuillez entrer $label" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Inscription Dermatologue",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: const Color(0xff5C4033),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🌸 Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/inscripderm.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 🌫️ Overlay pour lisibilité
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.brown.shade100.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 📝 Formulaire
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.brown.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.brown.shade100.withOpacity(0.3),
                      child: Icon(Icons.person,
                          size: 60, color: const Color(0xff5C4033)),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nomController, "Nom complet", Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField(_emailController, "Email", Icons.email,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    _buildTextField(_mdpController, "Mot de passe", Icons.lock,
                        obscureText: true),
                    const SizedBox(height: 15),
                    _buildTextField(_adresseController, "Adresse du cabinet", Icons.location_on),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const CircularProgressIndicator(color: Color(0xff5C4033))
                        : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5C4033),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Colors.brown.withOpacity(0.3),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          "S'inscrire",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
