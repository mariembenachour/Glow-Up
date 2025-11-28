import 'package:flutter/material.dart';
import '../services/auth_service.dart' show AuthService, LoginResult;
import 'home.dart';
import 'EspaceStylist.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg-auth.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // 🔹 Légère couche rose/rouge par-dessus l'image
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x99FF6F91),
                Color(0x99FF4E50),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),

          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Image.asset('images/logo1.png', height: 80, width: 80),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.pinkAccent),
                            hintText: "Adresse email",
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: mdpController,
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent),
                            hintText: "Mot de passe",
                            suffixIcon: IconButton(
                              icon: Icon(
                                isVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.pinkAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                            ),
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
                              backgroundColor: const Color(0xFFFF4E50),
                              shadowColor: Colors.pinkAccent,
                              elevation: 6,
                            ),
                            onPressed: () async {
                              final email = emailController.text.trim();
                              final mdp = mdpController.text.trim();

                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Veuillez entrer votre adresse email")),
                                );
                                return;
                              }
                              if (!email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Adresse email invalide (manque @)")),
                                );
                                return;
                              }
                              if (mdp.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Veuillez entrer votre mot de passe")),
                                );
                                return;
                              }

                              try {
                                final LoginResult? result = await AuthService.login(email, mdp);

                                if (result != null) {
                                  final int userId = result.idUser;
                                  final String role = result.role.trim().toUpperCase();
                                  print("🔹 Rôle récupéré : $role | ID : $userId");

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Connexion réussie 💕")),
                                  );

                                  if (role == 'CLIENT') {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/choix',
                                      arguments: {'idClient': userId},
                                    );
                                  } else if (role == 'STYLISTE') {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/stylisteHome',
                                      arguments: {'idStyliste': userId},
                                    );
                                  } else if (role == 'COACH') {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/coachs',
                                      arguments: {'idCoach': userId},
                                    );
                                  } else if (role == 'DERMATOLOGUE') {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/dermatologistDashboard',
                                      arguments: {'idDermato': userId},
                                    );
                                  } else {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                      arguments: {'idClient': userId},
                                    );
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erreur : ${e.toString()}")),
                                );
                              }
                            },

                            child: const Text(
                              "Se connecter",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Pas encore de compte ? ", style: TextStyle(color: Colors.black87)),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/choixRole');
                              },
                              child: const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
