package com.GlowUp.Dressing.contollers;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Styliste;
import com.GlowUp.Dressing.entities.Coach;
import com.GlowUp.Dressing.entities.Dermatologue; // 🆕 AJOUT : Import du Dermatologue
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.repositories.ClientRepository;
import com.GlowUp.Dressing.repositories.StylisteRepository;
import com.GlowUp.Dressing.repositories.CoachRepository;
import com.GlowUp.Dressing.repositories.DermatologueRepository; // 🆕 AJOUT : Import du Repository
import com.GlowUp.Dressing.services.UtilisateurService;

@RestController
@RequestMapping("/api/utilisateurs")
public class UtilisateurController {

    private final UtilisateurService utilisateurService;
    private final ClientRepository clientRepository;
    private final StylisteRepository stylisteRepository;
    private final CoachRepository coachRepository;
    private final DermatologueRepository dermatologueRepository; // 🆕 AJOUT : Déclaration du Repository

    // Injection par constructeur
    @Autowired
    public UtilisateurController(UtilisateurService utilisateurService, 
                                 ClientRepository clientRepository, 
                                 StylisteRepository stylisteRepository,
                                 CoachRepository coachRepository,
                                 DermatologueRepository dermatologueRepository) { // 🆕 AJOUT : Injection
        this.utilisateurService = utilisateurService;
        this.clientRepository = clientRepository;
        this.stylisteRepository = stylisteRepository;
        this.coachRepository = coachRepository;
        this.dermatologueRepository = dermatologueRepository; // 🆕 AJOUT : Initialisation
    }

    // --- Endpoints CRUD de base (Utilisateur) ---

    @GetMapping
    public List<Utilisateur> getAllUtilisateurs() {
        return utilisateurService.getAll();
    }

    @GetMapping("/{id}")
    public Utilisateur getUtilisateurById(@PathVariable int id) {
        return utilisateurService.getById(id);
    }

    @PutMapping("/mdp/{id}")
    public ResponseEntity<?> modifierMotDePasse(
            @PathVariable int id, 
            @RequestBody Map<String, String> body) {

        String ancienMdp = body.get("ancienMdp");
        String nouveauMdp = body.get("nouveauMdp");

        boolean success = utilisateurService.modifierMdpAvecAncien(id, ancienMdp, nouveauMdp);
        if(success){
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                 .body("Ancien mot de passe incorrect");
        }
    }

    @DeleteMapping("/{id}")
    public void deleteUtilisateur(@PathVariable int id) {
        utilisateurService.delete(id);
    }

    // --- Endpoints d'Inscription (Héritage) ---

    @PostMapping("/client")
    public Client ajouterClient(@RequestBody Client client) {
        return clientRepository.save(client);
    }

    @PostMapping("/styliste")
    public Styliste ajouterStyliste(@RequestBody Styliste styliste) {
        return stylisteRepository.save(styliste);
    }
    
    @PostMapping("/coach")
    public Coach ajouterCoach(@RequestBody Coach coach) {
        return coachRepository.save(coach);
    }
    
    /**
     * Endpoint pour ajouter un Dermatologue (inscription)
     * POST /api/utilisateurs/dermatologue
     */
    @PostMapping("/dermatologue") // 🆕 AJOUT : Endpoint pour le Dermatologue
    public Dermatologue ajouterDermatologue(@RequestBody Dermatologue dermatologue) {
        return dermatologueRepository.save(dermatologue);
    }
}