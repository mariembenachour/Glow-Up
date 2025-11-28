package com.GlowUp.Dressing.contollers;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Produit_SkinCare;
import com.GlowUp.Dressing.entities.Routine_SkinCare;
import com.GlowUp.Dressing.repositories.ProduitRepository;
import com.GlowUp.Dressing.services.ProduitService;
import com.GlowUp.Dressing.services.RoutineService;

@RestController
@RequestMapping("/api/routines")
public class RoutineController {

    @Autowired
    private RoutineService routineService;
    @Autowired
    private ProduitRepository produitRepository;
    @PostMapping("/utilisateur/{utilisateurId}/dermatologue/{dermatologueId}/complete")
    @ResponseStatus(HttpStatus.CREATED)
    public Routine_SkinCare creerRoutineComplete(
            @PathVariable int utilisateurId,
            @PathVariable int dermatologueId,
            @RequestBody Map<String, Object> payload) {

        String titre = (String) payload.get("titre");
        String description = (String) payload.get("description");
        String soinTime = (String) payload.get("soinTime");

        // 🔐 Sécurisation extraction produits
        List<Integer> produitIds = new ArrayList<>();

        Object rawProduits = payload.get("produits");
        if (rawProduits instanceof List<?>) {
            produitIds = ((List<?>) rawProduits)
                    .stream()
                    .filter(Objects::nonNull)
                    .map(id -> (Integer) id)     // safe cast
                    .collect(Collectors.toList());
        }

        List<Produit_SkinCare> produits = produitRepository.findAllById(produitIds);

        // ✅ Appel avec dermatologueId ajouté
        return routineService.creerRoutineComplete(
                utilisateurId,
                dermatologueId,
                titre,
                description,
                soinTime,
                produits
        );
    }


    @GetMapping("/utilisateur/{utilisateurId}")
    public List<Routine_SkinCare> getRoutinesByUtilisateur(@PathVariable int utilisateurId) {
        return routineService.getRoutinesByUtilisateur(utilisateurId);
    }

    
    // Supprimer une routine
    @DeleteMapping("/{routineId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteRoutine(@PathVariable int routineId) {
        routineService.deleteRoutine(routineId);
    }

    // Ajouter des produits à une routine
    @PutMapping("/{routineId}/produits")
    public Routine_SkinCare ajouterProduits(
            @PathVariable int routineId,
            @RequestBody List<Produit_SkinCare> produits) {

        return routineService.ajouterProduits(routineId, produits);
    }

    // Modifier une routine
    @PutMapping("/{routineId}")
    public Routine_SkinCare modifierRoutine(
            @PathVariable int routineId,
            @RequestBody Routine_SkinCare routineDetails) {

        return routineService.modifierRoutine(
                routineId,
                routineDetails.getTitre(),
                routineDetails.getDescription(),
                routineDetails.getSoinTime()
        );
    }
}