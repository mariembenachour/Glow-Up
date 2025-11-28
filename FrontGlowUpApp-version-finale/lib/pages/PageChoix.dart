import 'package:flutter/material.dart';
import 'package:glowupf/pages/skincare/HomePage.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔹 Import de tes pages
import '../pages/home.dart';       // <-- ton fichier pour le dressing
import '../pages/HomeSalle.dart';
import 'NotificationsPage.dart';
import 'ProfilPage.dart';  // <-- page du workout

class ChoixPage extends StatelessWidget {
  final int idClient;

  const ChoixPage({super.key, required this.idClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bienvenue 💖",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        actions: [
          // 🔹 Profil
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilPage(
                    userId: idClient,
                    userType: "client",
                  ),
                ),
              );
            },
          ),
          // 🔹 Déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Retour à la page d’accueil (AuthPage par exemple)
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Déconnexion réussie ✅")),
              );
            },
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bgchoix.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.pink.shade50.withOpacity(0.7)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choisissez votre espace",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 40),

              // 👜 Dressing
              _buildChoiceButton(
                context,
                icon: Icons.checkroom,
                label: "Mon Dressing Virtuel",
                color: Colors.pinkAccent,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomePage(idClient: idClient),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🏋 Workout
              _buildChoiceButton(
                context,
                icon: Icons.fitness_center,
                label: "Workout",
                color: Colors.deepPurpleAccent,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeSalle(idClient: idClient),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 💆 Skin care
              _buildChoiceButton(
                context,
                icon: Icons.spa,
                label: "Skin Care",
                color: Colors.teal,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SkinCareHomePage(clientId: idClient),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

     floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationsPage(userId: idClient),
            ),
          );
        },
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.notifications, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildChoiceButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 28),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(250, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 5,
      ),
    );
  }
}