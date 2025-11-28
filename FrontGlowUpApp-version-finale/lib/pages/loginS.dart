import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class InscriptionStyliste extends StatefulWidget {
  const InscriptionStyliste({super.key});

  @override
  State<InscriptionStyliste> createState() => _InscriptionStylisteState();
}

class _InscriptionStylisteState extends State<InscriptionStyliste> {
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  final specialiteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'images/stylistebg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Inscription Styliste",
                      style: TextStyle(
                        fontSize: width < 600 ? 26 : 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nomController,
                              decoration: InputDecoration(
                                hintText: "Nom complet",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer votre nom complet";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "Email",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer votre email";
                                }
                                if (!value.contains('@')) {
                                  return "Email invalide";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: mdpController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Mot de passe",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer un mot de passe";
                                }
                                if (value.length < 6) {
                                  return "Mot de passe trop court (min 6 caractères)";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: specialiteController,
                              decoration: InputDecoration(
                                hintText: "Spécialité",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer votre spécialité";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: Colors.pinkAccent,
                                  shadowColor: Colors.pink,
                                  elevation: 6,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final styliste = {
                                      "nom": nomController.text.trim(),
                                      "email": emailController.text.trim(),
                                      "mdp": mdpController.text.trim(),
                                      "role": "STYLISTE",
                                      "specialite": specialiteController.text.trim(),
                                    };
                                    try {
                                      await AuthService.registerStyliste(styliste);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Inscription réussie 💇‍♀"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushReplacementNamed(context, '/');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  "S'inscrire",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}