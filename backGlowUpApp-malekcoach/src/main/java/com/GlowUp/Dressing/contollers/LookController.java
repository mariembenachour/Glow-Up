package com.GlowUp.Dressing.contollers;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.GlowUp.Dressing.entities.Look;
import com.GlowUp.Dressing.services.LookService;

@RestController
@RequestMapping("/looks")
public class LookController {

    @Autowired
    private LookService lookService;

    @GetMapping
    public List<Look> getAllLooks() {
        return lookService.getAllLooks();
    }

    @GetMapping("/{id}")
    public Look getLookById(@PathVariable int id) {
        return lookService.getLookById(id);
    }

    @PostMapping
    public Look creerLook(
            @RequestBody Look look,
            @RequestParam List<Integer> vetementIds,
            @RequestParam Integer idClient,
            @RequestParam Integer idStyliste) {

        return lookService.creerLook(look, vetementIds, idClient, idStyliste);
    }

    @GetMapping("/client/{idUser}")
    public List<Look> getLooksByClient(@PathVariable int idUser) {
        return lookService.getLooksByClientId(idUser);
    }

    @GetMapping("/categorie/{categorie}")
    public List<Look> getLooksByCategorie(@PathVariable String categorie) {
        return lookService.getLooksByCategorie(categorie);
    }
    @PutMapping("/{idLook}/favoris")
    public ResponseEntity<?> updateFavoris(@PathVariable int idLook, @RequestBody Map<String, Boolean> body) {
        try {
            Look look = lookService.getLookById(idLook);
            if (look == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Look introuvable");
            }

            Boolean favoris = body.get("favoris");
            if (favoris == null) {
                return ResponseEntity.badRequest().body("Valeur du champ 'favoris' manquante");
            }

            look.setFavoris(favoris);
            lookService.updateLook(look);

            return ResponseEntity.ok(look);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erreur serveur : " + e.getMessage());
        }
    }




    @DeleteMapping("/{id}")
    public void deleteLook(@PathVariable int id) {
        lookService.deleteLook(id);
    }
    @GetMapping("/favoris")
    public List<Look> getLooksFavoris() {
        return lookService.getLooksFavoris();
    }
    @PutMapping
    public Look updateLook(@RequestBody Look look) {
        return lookService.updateLook(look);
    }
}