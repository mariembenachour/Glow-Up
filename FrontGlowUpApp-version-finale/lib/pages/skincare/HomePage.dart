import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'DermatologistsListPage.dart';
import 'MyRoutinesPage.dart';

class SkinCareHomePage extends StatelessWidget {
  final int clientId; // ID du client connecté

  const SkinCareHomePage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/choix',
              arguments: {"idClient": clientId},
            );
          },
        ),
        actions: [
          // 🔹 Bouton Déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Déconnexion réussie ✅")),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/skincare_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dégradé léger
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Boutons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton Dermatologues
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.medical_services,
                        size: 28, color: Color(0xff5C4033)),
                    label: Text(
                      "Liste des dermatologues",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff5C4033),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DermatologistsListPage(clientId: clientId),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // Bouton Routines
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.list_alt,
                        size: 28, color: Color(0xff5C4033)),
                    label: Text(
                      "Voir mes routines",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff5C4033),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyRoutinesPage(clientId: clientId),
                        ),
                      );
                    },
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