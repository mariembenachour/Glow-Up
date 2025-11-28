// pages/DermDashboardPage.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/demandeService.dart';
import '../ProfilPage.dart';
import 'DermRequestDetailPage.dart';

class DermDashboardPage extends StatefulWidget {
  final int dermatologueId;
  const DermDashboardPage({super.key, required this.dermatologueId});

  @override
  State<DermDashboardPage> createState() => _DermDashboardPageState();
}

class _DermDashboardPageState extends State<DermDashboardPage> {
  List<Map<String, dynamic>> demandes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDemandes();
  }

  Future<void> fetchDemandes() async {
    setState(() => isLoading = true);

    if (widget.dermatologueId <= 0) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : ID dermatologue invalide.")),
      );
      return;
    }

    try {
      final list = await DemandeService.getDemandesForDermatologue(widget.dermatologueId);

      if (!mounted) return;
      setState(() {
        demandes = list;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec du chargement des demandes : $e")),
      );
    }
  }

  Future<void> _changerEtat(int index, String nouvelEtat) async {
    final demandeId = demandes[index]["idDemande"];


    if (demandeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID de demande introuvable.")),
      );
      return;
    }

    try {
      final resp = await DemandeService.changerEtat(demandeId, nouvelEtat);

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        if (!mounted) return;
        setState(() => demandes[index]['etat'] = nouvelEtat);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("État mis à jour : $nouvelEtat")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur mise à jour : ${resp.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau : $e")),
      );
    }
  }

  String? getImageUrl(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    return "http://10.0.2.2:8080/uploads/$photo";
  }

  @override
  Widget build(BuildContext context) {
    final beige = Colors.brown.shade200;
    final marron = const Color(0xff5C4033);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Dashboard Dermato",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilPage(
                    userId: widget.dermatologueId,
                    userType: "dermatologue",
                  ),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchDemandes,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Déconnexion réussie.")),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/dashderm.jpg"),
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
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
            onRefresh: fetchDemandes,
            child: demandes.isEmpty
                ? Center(
              child: Text(
                "Aucune demande pour le moment",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 20),
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final d = demandes[index];

                // Champs sécurisés
                final titre = (d["titre"] ?? "Titre de la demande").toString();
                final description = (d["descriptionBesoins"] ?? "").toString();
                // Client toujours une Map grâce au service
                final Map<String, dynamic> clientMap =
                (d["client"] is Map<String, dynamic>)
                    ? d["client"]
                    : {"idUser": 0, "nom": "Inconnu"};
                final clientNom = (clientMap["nom"] ?? "Client Inconnu").toString();

                final etatRaw = (d["etat"] ?? "en attente").toString();
                final etat = etatRaw.toLowerCase();
                final etatDisplay = etat.isNotEmpty
                    ? "${etat[0].toUpperCase()}${etat.substring(1)}"
                    : "En attente";

                final rawPhoto = d["photoUrl"];
                String? photoUrl;

                if (rawPhoto != null && rawPhoto is String && rawPhoto.isNotEmpty) {
                  if (!rawPhoto.startsWith("http")) {
                    // 🔹 Le backend renvoie déjà "uploads/derma/43.png"
                    photoUrl = "http://10.0.2.2:8080/$rawPhoto";
                  } else {
                    photoUrl = rawPhoto;
                  }
                } else {
                  photoUrl = null;
                }

                // Couleur statut
                Color statutColor = etat.startsWith("accep")
                    ? Colors.green.shade700
                    : etat.startsWith("refus")
                    ? Colors.red.shade700
                    : Colors.orange.shade700;

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DermRequestDetailPage(
                          demande: d,
                          onEtatChange: (i, newEtat) {
                            _changerEtat(index, newEtat);
                          },
                        ),
                      ),
                    );
                    if (result == true) fetchDemandes();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: Colors.white.withOpacity(0.85),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titre,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: marron,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (description.isNotEmpty)
                                Text(
                                  "Description : $description",
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: marron.withOpacity(0.85),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),

                              Text(
                                "Client : $clientNom",
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: marron,
                                ),
                              ),
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


                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Statut : $etatDisplay",
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: statutColor,
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}