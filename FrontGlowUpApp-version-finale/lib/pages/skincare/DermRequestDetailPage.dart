import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ProduitsRoutinePage.dart';

class DermRequestDetailPage extends StatefulWidget {
  final Map<String, dynamic> demande;
  final Function(int, String) onEtatChange;

  const DermRequestDetailPage({
    super.key,
    required this.demande,
    required this.onEtatChange,
  });

  @override
  State<DermRequestDetailPage> createState() => _DermRequestDetailPageState();
}

class _DermRequestDetailPageState extends State<DermRequestDetailPage> {
  late String etat;

  @override
  void initState() {
    super.initState();
    etat = widget.demande["etat"] ?? "en attente";
  }

  void changerEtat(String nouvelEtat) {
    setState(() {
      etat = nouvelEtat;
    });
    widget.onEtatChange(widget.demande["idDemande"], nouvelEtat);
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.demande["client"] ?? {};
    final String? photoUrl = widget.demande["photoUrl"];
    const Color marron = Color(0xff5C4033);

    Color statutColor;
    switch (etat) {
      case "acceptee":
        statutColor = Colors.green.shade700;
        break;
      case "refusee":
        statutColor = Colors.red.shade700;
        break;
      default:
        statutColor = Colors.orange.shade700;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.demande["titre"] ?? "Détail demande",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: marron,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/reqdermdetail.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(22),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Client : ${client["nom"] ?? "—"}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: marron,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Email : ${client["email"] ?? "—"}",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.brown.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Type de peau : ${client["typeDePeau"] ?? "—"}",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.brown.shade800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (client["image"] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            client["image"],
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        "Description : ${widget.demande["descriptionBesoins"] ?? "—"}",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.brown.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (photoUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              height: 180,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  "Image non disponible",
                                  style: GoogleFonts.lato(color: marron),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "État : ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: marron,
                            ),
                          ),
                          Text(
                            etat,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statutColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Boutons selon état
                      if (etat == "en attente") ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => changerEtat("acceptee"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  "Accepter",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => changerEtat("refusee"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  "Refuser",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ] else if (etat == "acceptee") ...[
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GestionProduitsPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: marron,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              "Créer routine",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}