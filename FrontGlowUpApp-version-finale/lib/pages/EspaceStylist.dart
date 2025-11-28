import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/demandeService.dart';
import '../services/NotificationService.dart';
import 'DressingPage.dart';
import 'ProfilPage.dart';

class EspaceStylistePage extends StatefulWidget {
  final int stylisteId;

  const EspaceStylistePage({super.key, required this.stylisteId});

  @override
  State<EspaceStylistePage> createState() => _EspaceStylistePageState();
}

class _EspaceStylistePageState extends State<EspaceStylistePage> {
  List<Map<String, dynamic>> demandes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDemandes();
  }

  Future<void> fetchDemandes() async {

    if (widget.stylisteId <= 0) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur : ID Styliste invalide.")),
        );
      }
      return;
    }

    try {
      final list = await DemandeService.getDemandesForStyliste(widget.stylisteId);

      if (mounted) {
        setState(() {
          demandes = list;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec du chargement des demandes : $e")),
        );
      }
    }
  }

  Future<void> _changerEtat(int demandeId, String nouvelEtat, int? clientId) async {
    // 🔒 Contrôles anti-erreurs
    if (demandeId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : ID demande invalide.")),
      );
      return;
    }

    if (nouvelEtat.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : état vide.")),
      );
      return;
    }

    final safeClientId = clientId ?? 0;

    try {
      final resp = await DemandeService.changerEtat(demandeId, nouvelEtat);

      if (resp.statusCode == 200 || resp.statusCode == 204) {

        if (mounted) {
          setState(() {
            final idx = demandes.indexWhere(
                    (d) => (d['idDemande'] ?? d['id'] ?? d['demandeId']) == demandeId
            );
            if (idx != -1) demandes[idx]['etat'] = nouvelEtat;
          });
        }

        if (safeClientId > 0) {
          String message = (nouvelEtat.toLowerCase().contains("accept"))
              ? "Demande acceptée : votre look est en préparation 👗"
              : "Votre demande a été refusée ❌";

          // NotificationService.envoyerNotif(safeClientId.toString(), message);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("État mis à jour avec succès.")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur serveur : ${resp.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur réseau : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/stylistedemandes.webp"), // 👉 ton image ici
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Important pour voir l'image
        appBar: AppBar(
          title: Text("Espace Styliste", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.pinkAccent.withOpacity(0.85),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilPage(
                      userId: widget.stylisteId,
                      userType: "styliste",
                    ),
                  ),
                );
              },
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

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : demandes.isEmpty
            ? Center(
          child: Text(
            "Aucune demande reçue.",
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: demandes.length,
          itemBuilder: (context, index) {
            final d = demandes[index];

            // 🔒 Extraction sécurisée
            final id = d['idDemande'] ?? d['id'] ?? d['demandeId'] ?? 0;

            final titre = (d['titre'] ?? d['Titre'] ?? '').toString().trim();
            final desc = (d['descriptionBesoins'] ?? d['description'] ?? '').toString().trim();

            // 🔒 Saisie vide → message au styliste
            final safeTitre = titre.isEmpty ? "Titre non fourni" : titre;
            final safeDesc = desc.isEmpty ? "Pas de description" : desc;

            final etat = (d['etat'] ?? 'en attente').toString().toLowerCase();

            int? clientId;
            String clientNom = 'Inconnu';

            final client = d['client'];
            if (client != null) {
              clientId = client['idUser'] ?? client['id'];
              clientNom = client['nom'] ?? "Inconnu";
            }

            Color statutColor;
            switch (etat) {
              case 'acceptée':
              case 'acceptee':
                statutColor = Colors.green;
                break;
              case 'refusée':
              case 'refusee':
                statutColor = Colors.red;
                break;
              default:
                statutColor = Colors.orange;
            }

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(safeTitre, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    Text(safeDesc, style: GoogleFonts.lato(fontSize: 14)),
                    const SizedBox(height: 8),

                    Text("Client : $clientNom",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Statut : ${etat[0].toUpperCase()}${etat.substring(1)}",
                          style: GoogleFonts.poppins(
                            color: statutColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 🔵 Si en attente → afficher boutons
                        if (etat == 'en attente')
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _changerEtat(id, "Acceptée", clientId),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Accepter", style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _changerEtat(id, "Refusée", clientId),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                child: const Text("Refuser", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )

                        // 🔵 Si acceptée → bouton dressing
                        else if (etat.contains("accept"))
                          ElevatedButton(
                            onPressed: (clientId != null && clientId > 0)
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DressingStylistePage(
                                    idClient: clientId!,
                                    idStyliste: widget.stylisteId,
                                  ),
                                ),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                            child: const Text("Accéder au dressing", style: TextStyle(color: Colors.white)),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),),
    );
  }
}