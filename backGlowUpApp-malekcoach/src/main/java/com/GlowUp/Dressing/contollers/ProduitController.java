package com.GlowUp.Dressing.contollers;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.GlowUp.Dressing.entities.Produit_SkinCare;
import com.GlowUp.Dressing.services.ProduitService;

@RestController
@RequestMapping("/api/produits")
@CrossOrigin(origins = "*")
public class ProduitController {

    @Autowired
    private ProduitService produitService;

    @PostMapping("/add")
    public Produit_SkinCare ajouterProduit(
            @RequestParam String nom,
            @RequestParam String description,
            @RequestParam String type,
            @RequestParam(required = false) MultipartFile image
    ) throws IOException {
        return produitService.ajouterProduitAvecImage(nom, description, type, image);
    }
    // Modifier un produit
    @PutMapping("/update/{id}")
    public Produit_SkinCare modifierProduit(
            @PathVariable int id,
            @RequestParam String nom,
            @RequestParam String description,
            @RequestParam String type,
            @RequestParam(required = false) MultipartFile image
    ) throws IOException {
        return produitService.modifierProduit(id, nom, description, type, image);
    }

    // GET : liste des produits
    @GetMapping
    public List<Produit_SkinCare> getAllProduits() {
        return produitService.getAllProduits();
    }

    // GET : un produit
    @GetMapping("/{id}")
    public ResponseEntity<Produit_SkinCare> getProduitById(@PathVariable int id) {
        Produit_SkinCare produit = produitService.getProduitById(id);
        return (produit != null)
                ? ResponseEntity.ok(produit)
                : ResponseEntity.notFound().build();
    }

    // DELETE : supprimer produit
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduit(@PathVariable int id) {
        Produit_SkinCare produit = produitService.getProduitById(id);
        if (produit != null) {
            produitService.deleteProduit(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
