import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mondrawer.dart';
import 'Dressing.dart';
import 'Stylistes.dart';
import '../services/NotificationService.dart';
import 'mes_looks_page.dart';

class HomePage extends StatefulWidget {
  final int idClient;
  const HomePage({super.key, required this.idClient});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> notifications = [];
  bool hasNewNotification = false;

  @override
  void initState() {
    super.initState();

  }





  // 🌸 Fenêtre de confirmation de déconnexion stylée
  Future<void> _confirmLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.pink[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Colors.pinkAccent),
            SizedBox(width: 8),
            Text(
              "Déconnexion",
              style: TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Souhaitez-vous vraiment vous déconnecter ?",
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Se déconnecter",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const MyDrawer(),
      body: Builder(
        builder: (context) => Stack(
          children: [
            // 🌈 Fond dégradé
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4), Color(0xFFFF1744)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 🌸 Contenu principal
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/logo1.png',
                            fit: BoxFit.contain, height: 150, width: 150),
                        const SizedBox(height: 30),
                        Text(
                          "Bienvenue dans ton univers stylé 💋",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: width < 600 ? 28 : 40,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Explore ton dressing, crée ton look et exprime ton élégance.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: width < 600 ? 16 : 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StylistesPage(clientId: widget.idClient),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Explorer nos stylistes",
                            style: TextStyle(color: Colors.pink, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset('images/dressing.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          "Notre mission 💫",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: width < 600 ? 26 : 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "T’aider à révéler ta personnalité à travers ton style. "
                              "Notre plateforme te guide pour harmoniser tes tenues, "
                              "organiser ton dressing et libérer ta créativité vestimentaire.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontSize: width < 600 ? 16 : 18,
                              color: Colors.white70,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.white.withOpacity(0.2),
                    child: Text(
                      "© 2025 Glow Up — Tous droits réservés 💄",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // 🔝 Nouveau menu en deux lignes
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    // 🌸 Ligne 1 : Drawer + notif + retour + déconnexion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ≡ Menu Drawer
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),

                          const SizedBox(width: 0),


                          // ⬅ Retour
                          IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/choix',
                              )
                          ),

                          // 🚪 Déconnexion
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                            onPressed: () => _confirmLogout(context),
                            tooltip: "Déconnexion",
                          ),
                        ],
                      ),
                    ),

                    // 💅 Ligne 2 : Mon Dressing / Mes Looks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/Dressing',
                              arguments: {'idClient': widget.idClient},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Mon Dressing",
                              style: TextStyle(color: Colors.pink)),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MesLooksClientPage(idClient: widget.idClient),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Mes Looks",
                              style: TextStyle(color: Colors.pink)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}