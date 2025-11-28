import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class InscriptionClient extends StatefulWidget {
  const InscriptionClient({super.key});

  @override
  State<InscriptionClient> createState() => _InscriptionClientState();
}

class _InscriptionClientState extends State<InscriptionClient> {
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  final tailleController = TextEditingController();
  final poidsController = TextEditingController();
  final objectifController = TextEditingController();
  String? typePeau;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'images/femme.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.25)
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
                      "Inscription Client",
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
                              controller: tailleController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Taille (cm)",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer votre taille";
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return "Valeur invalide";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: poidsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Poids (kg)",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer votre poids";
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return "Valeur invalide";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: typePeau,
                              hint: const Text("Type de peau"),
                              items: const [
                                DropdownMenuItem(value: "MIXTE", child: Text("Mixte")),
                                DropdownMenuItem(value: "SECHE", child: Text("Sèche")),
                                DropdownMenuItem(value: "NORMALE", child: Text("Normale")),
                                DropdownMenuItem(value: "GRASSE", child: Text("Grasse")),
                              ],
                              onChanged: (val) => setState(() => typePeau = val),
                              dropdownColor: Colors.white,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez sélectionner votre type de peau";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // 🔹 Objectif sportif optionnel (pas de validator)
                            TextFormField(
                              controller: objectifController,
                              decoration: InputDecoration(
                                hintText: "Objectif sportif (optionnel)",
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
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
                                    final client = {
                                      "nom": nomController.text.trim(),
                                      "email": emailController.text.trim(),
                                      "mdp": mdpController.text.trim(),
                                      "role": "CLIENT",
                                      "taille": double.tryParse(tailleController.text.trim()) ?? 0.0,
                                      "poids": double.tryParse(poidsController.text.trim()) ?? 0.0,
                                      "typeDePeaux": typePeau,
                                      "objectifSportif": objectifController.text.trim(),
                                    };
                                    try {
                                      await AuthService.registerClient(client);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Inscription réussie 💖"),
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
                                  style: TextStyle(color: Colors.white, fontSize: 16),
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