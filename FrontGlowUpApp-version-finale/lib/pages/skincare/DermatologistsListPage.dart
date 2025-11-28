import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/DermatologueService.dart';
import 'RequestSkinCarePage.dart';

class DermatologistsListPage extends StatefulWidget {
  final int clientId;

  const DermatologistsListPage({super.key, required this.clientId});

  @override
  State<DermatologistsListPage> createState() => _DermatologistsListPageState();
}

class _DermatologistsListPageState extends State<DermatologistsListPage> {
  List<dynamic> dermatos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerDermatologues();
  }

  void chargerDermatologues() async {
    try {
      final liste = await DermatologueService.getDermatologues();
      setState(() {
        dermatos = liste ?? [];
        isLoading = false;
      });

      if (liste == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors du chargement des dermatologues")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Dermatologues",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5C4033),
            fontSize: 22,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/listederm.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.brown.shade100.withOpacity(0.15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
            itemCount: dermatos.length,
            itemBuilder: (context, index) {
              final d = dermatos[index];
              final nom = d['nom'] ?? "Nom inconnu";
              final adresse = d['adresseCabinet'] ?? "adresse Cabinet inconnue";

              // Sécurisation de l'ID (int ou String)
              final dynamic rawId = d['idUser'];
              final dermatologueId = (rawId is int)
                  ? rawId
                  : (rawId != null ? int.tryParse(rawId.toString()) : null);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  border: Border.all(
                    color: Colors.brown.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color(0xff5C4033),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Adresse Cabinet : $adresse",
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.brown[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: dermatologueId != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestSkinCarePage(
                              clientId: widget.clientId,
                              dermatologueId: dermatologueId,
                            ),
                          ),
                        );
                      }
                          : null,
                      child: Text(
                        "Envoyer demande",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5C4033),
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}