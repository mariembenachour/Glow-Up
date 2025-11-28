import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'RoutineDetailPage.dart';
import '../../services/RoutineService.dart';

class MyRoutinesPage extends StatefulWidget {
  final int clientId;

  const MyRoutinesPage({super.key, required this.clientId});

  @override
  State<MyRoutinesPage> createState() => _MyRoutinesPageState();
}

class _MyRoutinesPageState extends State<MyRoutinesPage> {
  final RoutineService service = RoutineService();

  List<Map<String, dynamic>> routines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    setState(() => isLoading = true);
    try {
      final data = await service.getRoutinesByUser(widget.clientId);

      // On garde directement les routines
      routines = List<Map<String, dynamic>>.from(data);

      print("Routines chargées : ${routines.length}");
    } catch (e) {
      print("Erreur fetch routines: $e");
      routines = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Mes Routines",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5C4033),
          ),
        ),
      ),
      body: Stack(
        children: [
          // IMAGE DE FOND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/mesroutiness.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // GRADIENT léger
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // CONTENU
          isLoading
              ? const Center(
            child:
            CircularProgressIndicator(color: Color(0xff5C4033)),
          )
              : routines.isEmpty
              ? Center(
            child: Text(
              "Aucune routine trouvée",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xff5C4033),
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RoutineDetailPage(routine: routine),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⭐ TITRE DE LA ROUTINE
                      Text(
                        routine["titre"] ?? "Routine sans titre",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xff5C4033),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ⭐ HEURE DU SOIN
                      Text(
                        routine["soinTime"] ?? "",
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.brown[600],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ⭐ DESCRIPTION
                      Text(
                        routine["description"] ?? "",
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.brown[800],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ⭐ PRODUITS
                      if (routine["produits"] != null &&
                          (routine["produits"] as List).isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                            (routine["produits"] as List).length,
                            itemBuilder: (context, imgIndex) {
                              final produit =
                              routine["produits"][imgIndex];
                              return Container(
                                margin: const EdgeInsets.only(
                                    right: 8),
                                child: Image.network(
                                  "http://10.0.2.2:8080${produit["imageUrl"]}",
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}