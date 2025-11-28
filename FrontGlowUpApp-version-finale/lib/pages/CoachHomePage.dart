// lib/screens/CoachHomePage.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/demandeService.dart';
import '../services/ProgrammeService.dart';
import 'AgendaCoachPage.dart';
import 'ProfilPage.dart';

class CoachHomePage extends StatefulWidget {
  final int coachId;

  const CoachHomePage({super.key, required this.coachId});

  @override
  State<CoachHomePage> createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  List<Map<String, dynamic>> demandes = [];
  bool isLoading = true;

  static const String etatEnAttente = "en attente";
  static const String etatAcceptee = "acceptee";
  static const String etatRefusee = "refusee";

  @override
  void initState() {
    super.initState();
    fetchDemandes();
  }

  Future<void> fetchDemandes() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final list = await DemandeService.getDemandesForCoach(widget.coachId);
      final normalizedList = list.map((d) {
        final map = Map<String, dynamic>.from(d);
        String etatRaw = (map["etat"] ?? etatEnAttente).toString().toLowerCase();
        if (etatRaw.contains("accept")) etatRaw = etatAcceptee;
        else if (etatRaw.contains("refus")) etatRaw = etatRefusee;
        else if (etatRaw.contains("attente")) etatRaw = etatEnAttente;
        map["etat"] = etatRaw;
        return map;
      }).toList();

      if (!mounted) return;
      setState(() {
        demandes = normalizedList;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur chargement demandes : $e")),
      );
    }
  }

  /// Change l'état d'une demande puis, si acceptée, gère la création / ouverture du programme.
  Future<void> changerEtat(int demandeId, String nouvelEtat, int? clientId) async {
    try {
      final resp = await DemandeService.changerEtat(demandeId, nouvelEtat);
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        if (!mounted) return;
        setState(() {
          final idx = demandes.indexWhere((d) =>
          (d["idDemande"] ?? d["id"] ?? d["demandeId"]) == demandeId);
          if (idx != -1) demandes[idx]["etat"] = nouvelEtat;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("État mis à jour ✅")),
        );

        if (nouvelEtat == etatAcceptee) {
          // Si accepté → gérer programme (vérifier si existe, sinon créer/attribuer), puis ouvrir la page
          if (clientId == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Client introuvable pour création de programme.")),
            );
            return;
          }

          final prog = await _handleProgrammeCreation(clientId);
          if (prog == null) return;

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgrammeCreatorPage(
                clientId: clientId,
                demandeId: demandeId,
                coachId: widget.coachId,
                programmeData: prog,
              ),
            ),
          );

          await fetchDemandes();
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur API: ${resp.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  /// Vérifie si un programme existe pour le client, sinon crée + attribue, et renvoie le programme.
  Future<Map<String, dynamic>?> _handleProgrammeCreation(int clientId) async {
    try {
      // 1) Cherche les programmes existants du client
      final progs = await ProgrammeService.getProgrammesByClient(clientId);
      if (progs.isNotEmpty) {
        return progs.first;
      }

      // 2) Aucun programme → crée un nouveau programme pour le coach
      final created = await ProgrammeService.creerProgramme(
        coachId: widget.coachId,
        objectif: "Programme auto-généré",
      );

      // 3) Attribue au client (attention aux clés id)
      final progId = created["idProgramme"] ?? created["id"];
      if (progId == null) {
        // Si l'API renvoie un format inattendu, on tente de renvoyer l'objet créé sans attribution
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de récupérer l'ID du programme créé.")),
        );
        return null;
      }

      await ProgrammeService.attribuerProgramme(progId, clientId);

      // 4) On récupère (optionnel) le programme finalisé depuis l'API pour être sûr du format
      final reloaded = await ProgrammeService.getProgrammesByClient(clientId);
      if (reloaded.isNotEmpty) return reloaded.first;

      // sinon retourne l'objet créé initial
      return created;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur création/attribution programme: $e")),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleuFonce = const Color(0xFF001F3F);
    final bleuClair = const Color(0xFF3A6EA5);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Espace Coach",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: bleuFonce,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Déconnexion réussie.")),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/demnades.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
                child: Center(
                  child: Text(
                    "Menu",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text("Changer Mot De Passe", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilPage(userId: widget.coachId, userType: "coach"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "images/demandesbody.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // OVERLAY NOIR LÉGER
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          // CONTENU
          isLoading
              ? Center(child: CircularProgressIndicator(color: bleuClair))
              : demandes.isEmpty
              ? Center(
            child: Text(
              "Aucune demande reçue.",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: demandes.length,
            itemBuilder: (context, i) {
              final d = demandes[i];
              final demandeId = d["idDemande"] ?? d["id"] ?? d["demandeId"];
              final etat = (d["etat"] ?? etatEnAttente).toString();
              final client = (d["client"] is Map)
                  ? Map<String, dynamic>.from(d["client"])
                  : <String, dynamic>{};
              final clientNom = client["nom"] ?? "Inconnu";
              final clientId = client["id"] ?? client["idUser"] ?? client["idUtilisateur"];
              Color statutColor = etat == etatAcceptee
                  ? Colors.greenAccent
                  : etat == etatRefusee
                  ? Colors.redAccent
                  : Colors.orangeAccent;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITRE
                            Text(
                              d["titre"] ?? "Sans titre",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // DESCRIPTION
                            Text(
                              d["descriptionBesoins"] ?? "",
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 10),


                            // CLIENT
                            Text(
                              "Client : $clientNom",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // STATUT + BOUTONS
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Statut : ${etat.toUpperCase()}",
                                    style: GoogleFonts.poppins(
                                      color: statutColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (etat == etatEnAttente) ...[
                                  _glassButton(
                                    label: "Accepter",
                                    color: Colors.greenAccent,
                                    onTap: () => changerEtat(demandeId, etatAcceptee, clientId),
                                  ),
                                  const SizedBox(width: 8),
                                  _glassButton(
                                    label: "Refuser",
                                    color: Colors.redAccent,
                                    onTap: () => changerEtat(demandeId, etatRefusee, clientId),
                                  ),
                                ] else if (etat == etatAcceptee) ...[
                                  _glassButton(
                                    label: "Créer Programme",
                                    color: bleuClair,
                                    onTap: () async {
                                      if (clientId == null) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Client introuvable.")),
                                        );
                                        return;
                                      }

                                      final prog = await _handleProgrammeCreation(clientId);
                                      if (prog == null) return;

                                      if (!mounted) return;
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProgrammeCreatorPage(
                                            clientId: clientId,
                                            demandeId: demandeId,
                                            coachId: widget.coachId,
                                            programmeData: prog,
                                          ),
                                        ),
                                      );
                                      await fetchDemandes();
                                    },
                                  ),
                                ],
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== BOUTON GLASS ====================
  Widget _glassButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}