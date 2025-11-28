import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class InscriptionCoach extends StatefulWidget {
  const InscriptionCoach({super.key});

  @override
  State<InscriptionCoach> createState() => _InscriptionCoachState();
}

class _InscriptionCoachState extends State<InscriptionCoach> {
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  String? domaine; // 🔹 variable pour stocker le domaine sélectionné

  final List<String> domaines = [
    "Musculation",
    "Yoga",
    "Cardio",
    "CrossFit",
    "Fitness général",
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'images/coach.webp',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.3),
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
                      "Inscription Coach",
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
                              decoration: const InputDecoration(
                                hintText: "Nom complet",
                                filled: true,
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
                              decoration: const InputDecoration(
                                hintText: "Email",
                                filled: true,
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
                              decoration: const InputDecoration(
                                hintText: "Mot de passe",
                                filled: true,
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

                            // 🔹 Liste déroulante pour le domaine
                            DropdownButtonFormField<String>(
                              value: domaine,
                              hint: const Text("Sélectionnez votre domaine"),
                              items: domaines.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  domaine = newValue;
                                });
                              },
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez sélectionner un domaine";
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
                                  backgroundColor: Colors.blueAccent,
                                  shadowColor: Colors.blue,
                                  elevation: 6,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final coach = {
                                      "nom": nomController.text.trim(),
                                      "email": emailController.text.trim(),
                                      "mdp": mdpController.text.trim(),
                                      "role": "COACH",
                                      "domaine": domaine ?? "",
                                    };

                                    try {
                                      await AuthService.registerCoach(coach);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Inscription réussie 🎉"),
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