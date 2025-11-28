import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'CalendrierProPage.dart';
import 'ClientProgrammesPage.dart';
import 'ProfilPage.dart';
import 'listCoachs.dart';

class HomeSalle extends StatefulWidget {
  final int idClient;

  const HomeSalle({super.key, required this.idClient});

  @override
  State<HomeSalle> createState() => _HomeSalleState();
}

class _HomeSalleState extends State<HomeSalle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // Bleu nuit
      drawer: Drawer(
        backgroundColor: const Color(0xFF0B1120),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004AAD), Color(0xFF0A84FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Logo circulaire
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('images/logo sport.png'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),

                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.white),
              title: Text("Programmes", style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MesProgrammesPage(clientId: widget.idClient),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: Text("Mon profil", style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilPage(userId: widget.idClient, userType: "client"),
                  ),
                );
              },
            ),

          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        elevation: 0,
        iconTheme:
        const IconThemeData(color: Colors.white), // ✅ rend les tirets blancs
        title: Text(
          "Fitness",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 26),
            tooltip: "Retour",
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/choix', (route) => false);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Se déconnecter",
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 SECTION HERO
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF004AAD), Color(0xFF0A84FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/sport1.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Prêt pour ton challenge ?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ton corps est ton arme — entraîne-toi avec passion 💥",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListCoachPage(idClient: widget.idClient),
                        ),
                      );
                    },
                    child: Text(
                      "explorer nos coachs",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF004AAD),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 SECTION PROGRAMME DU JOUR
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF11163A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [

                  const SizedBox(height: 15),
                  Text(
                    "Ton programme du jour",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MesProgrammesPage(clientId: widget.idClient),
                        ),
                      );
                    },

                    child: Text(
                      "Voir mon programme complet",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset('images/sport.png'),
            const SizedBox(height: 40),
            Text(
              "💙 Reste motivé, reste fort 💪",
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "© 2025 GlowUp Fitness - Tous droits réservés",
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Déconnexion",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Souhaitez-vous vraiment vous déconnecter ?",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            Text("Annuler", style: GoogleFonts.poppins(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text(
              "Se déconnecter",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
