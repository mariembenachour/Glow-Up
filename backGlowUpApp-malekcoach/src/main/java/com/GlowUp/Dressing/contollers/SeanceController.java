package com.GlowUp.Dressing.contollers;

import com.GlowUp.Dressing.entities.Seance;
import com.GlowUp.Dressing.services.SeanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.http.MediaType;
@RestController
@RequestMapping("/api/seances")
public class SeanceController {

    private final SeanceService seanceService;

    @Autowired
    public SeanceController(SeanceService seanceService) {
        this.seanceService = seanceService;
    }

    // Créer une séance avec ou sans images
    @PostMapping(value = "/programme/{programmeId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> creerSeance(
            @PathVariable Integer programmeId,
            @RequestParam String description,
            @RequestParam String heureDebut,
            @RequestParam String heureFin,
            @RequestParam String createur,
            @RequestParam(required = false, name = "images") List<MultipartFile> images
    ) {
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime debut = LocalDateTime.parse(heureDebut, formatter);
            LocalDateTime fin = LocalDateTime.parse(heureFin, formatter);

            Seance seance = seanceService.creerSeanceAvecImages(programmeId, description, debut, fin,createur, images);
            System.out.println("Images reçues : " + (images != null ? images.size() : 0));

            return ResponseEntity.status(HttpStatus.CREATED).body(seance);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Erreur création séance: " + e.getMessage());
        }
    }






    // Upload supplémentaire d'images pour une séance existante
    @PostMapping("/{id}/images")
    public ResponseEntity<?> uploadImages(
            @PathVariable Integer id,
            @RequestParam List<MultipartFile> images
    ) {
        try {
            if (images != null && !images.isEmpty()) {
                for (MultipartFile file : images) {
                    seanceService.ajouterImage(id, file);
                }
            }
            return ResponseEntity.ok("Upload des images réussi ✅");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Erreur upload images: " + e.getMessage());
        }
    }

    // Récupérer toutes les séances d’un client
    @GetMapping("/client/{clientId}")
    public List<Seance> getSeancesByClient(@PathVariable Integer clientId) {
        return seanceService.getSeancesByClientId(clientId);
    }

    // Récupérer toutes les séances d’un programme
    @GetMapping("/programme/{programmeId}")
    public List<Seance> getSeancesByProgramme(@PathVariable Integer programmeId) {
        return seanceService.getSeancesByProgrammeId(programmeId);
    }

    // Planifier une séance (mettre à jour les heures)
    @PutMapping("/{id}/planifier")
    public Seance planifierSeance(
            @PathVariable Integer id,
            @RequestBody Map<String, String> dates) {

        LocalDateTime heureDebut = LocalDateTime.parse(dates.get("heureDebut"));
        LocalDateTime heureFin = LocalDateTime.parse(dates.get("heureFin"));

        return seanceService.planifierSeance(id, heureDebut, heureFin);
    }

    // Marquer une séance comme complète
    @PutMapping("/{id}/completer")
    public Seance marquerSeanceComplete(@PathVariable Integer id) {
        return seanceService.marquerSeanceComplete(id);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> modifierSeance(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body
    ) {
        try {
            String description = body.get("description");
            String debutStr = body.get("heureDebut");
            String finStr = body.get("heureFin");

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime heureDebut = debutStr != null ? LocalDateTime.parse(debutStr, formatter) : null;
            LocalDateTime heureFin = finStr != null ? LocalDateTime.parse(finStr, formatter) : null;

            Seance updatedSeance = seanceService.modifierSeance(id, description, heureDebut, heureFin);
            return ResponseEntity.ok(updatedSeance);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Erreur modification séance: " + e.getMessage());
        }
    }

    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> supprimerSeance(@PathVariable Integer id) {
        try {
            seanceService.supprimerSeance(id);
            return ResponseEntity.ok("Séance supprimée ✅");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Erreur suppression séance: " + e.getMessage());
        }
    }
}