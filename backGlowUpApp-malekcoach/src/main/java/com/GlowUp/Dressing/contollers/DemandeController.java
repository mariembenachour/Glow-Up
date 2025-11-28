package com.GlowUp.Dressing.contollers;

import com.GlowUp.Dressing.entities.Demande;
import com.GlowUp.Dressing.services.DemandeService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/demandes")
public class DemandeController {
    @Autowired
    private DemandeService demandeService;
    private final ObjectMapper mapper = new ObjectMapper();
    @GetMapping
    public List<Demande> getAllDemandes() {
        return demandeService.getDemandes();
    }
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public Demande ajouterDemande(@RequestBody Demande demande) {
        return demandeService.envoyerDemande(demande, null);
    }
    @PostMapping(value = "/multipart", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Demande ajouterDemandeMultipart(
            @RequestPart("demande") String demandeJson,
            @RequestPart(value = "images", required = false) MultipartFile[] images
    ) {
        try {
            Demande demande = mapper.readValue(demandeJson, Demande.class);
            return demandeService.envoyerDemande(demande, images);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Erreur lors de l'envoi de la demande multipart : " + e.getMessage());
        }
    }

   
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDemande(@PathVariable int id) {
        demandeService.deleteDemande(id);
    }
    @GetMapping("/styliste/{id}")
    public List<Demande> getDemandesByStyliste(@PathVariable int id) {
        return demandeService.getDemandesByStylisteId(id);
    }

    @GetMapping("/coach/{id}")
    public List<Demande> getDemandesByCoach(@PathVariable int id) {
        return demandeService.getDemandesByCoachId(id);
    }

    @GetMapping("/dermatologue/{id}")
    public List<Demande> getDemandesByDermatologue(@PathVariable int id) {
        return demandeService.getDemandesByDermatologue(id);
    }

    // Changer l’état d’une demande
    @PutMapping("/etat/{id}")
    public ResponseEntity<?> changerEtatDemande(@PathVariable int id, @RequestBody Map<String, String> body) {
        String nouvelEtat = body.get("etat");
        demandeService.changerEtat(id, nouvelEtat);
        return ResponseEntity.ok().build();
    }
}