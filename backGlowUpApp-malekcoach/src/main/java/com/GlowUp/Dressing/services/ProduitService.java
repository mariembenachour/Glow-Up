package com.GlowUp.Dressing.services;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.GlowUp.Dressing.entities.Produit_SkinCare;
import com.GlowUp.Dressing.repositories.ProduitRepository;

@Service
public class ProduitService {

    @Autowired
    private ProduitRepository produitRepository;

    /**
     * Ajouter un produit avec upload d'une seule image
     */
    public Produit_SkinCare ajouterProduitAvecImage(
            String nom,
            String description,
            String type,
            MultipartFile imageFile
    ) throws IOException {

        Produit_SkinCare produit = new Produit_SkinCare();
        produit.setNom(nom);
        produit.setDescription(description);
        produit.setType(type);

        // 🔹 1) On sauvegarde le produit (sans image au début)
        produit = produitRepository.save(produit);

        // 🔹 2) Gestion de l'image
        if (imageFile != null && !imageFile.isEmpty()) {

            // 📁 Chemin où enregistrer
            Path uploadDir = Paths.get("uploads/produits");

            // 📁 Créer dossier si n'existe pas
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            // 📌 Nettoyage du nom original
            String originalName = imageFile.getOriginalFilename();
            if (originalName == null) originalName = "image.png";

            originalName = originalName.replace("\\", "").replace("/", "");

            // 📌 Génération d’un nom unique
            String filename = UUID.randomUUID() + "_" + originalName;

            Path filePath = uploadDir.resolve(filename);

            // 🟢 Copie réelle du fichier dans ton projet
            Files.copy(imageFile.getInputStream(), filePath);

            // 🌍 URL accessible depuis Flutter
            String imageUrl = "/uploads/produits/" + filename;

            // On met à jour le produit
            produit.setImageUrl(imageUrl);
        }

        // 🔹 3) Sauvegarder le produit final
        return produitRepository.save(produit);
    }
    public Produit_SkinCare modifierProduit(
            int id,
            String nom,
            String description,
            String type,
            MultipartFile imageFile
    ) throws IOException {
        Produit_SkinCare produit = produitRepository.findById(id).orElseThrow(
            () -> new RuntimeException("Produit introuvable")
        );

        produit.setNom(nom);
        produit.setDescription(description);
        produit.setType(type);

        // Gestion de l'image si fournie
        if (imageFile != null && !imageFile.isEmpty()) {
            Path uploadDir = Paths.get("uploads/produits/");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String originalName = imageFile.getOriginalFilename() != null
                    ? imageFile.getOriginalFilename()
                    : "image";

            String filename = UUID.randomUUID() + "_" +
                    originalName.replace("\\", "").replace("/", "_");

            Path filePath = uploadDir.resolve(filename);
            Files.copy(imageFile.getInputStream(), filePath);

            produit.setImageUrl("/uploads/produits/" + filename);
        }

        return produitRepository.save(produit);
    }

    // CRUD normal
    public Produit_SkinCare getProduitById(int id) {
        return produitRepository.findById(id).orElse(null);
    }

    public java.util.List<Produit_SkinCare> getAllProduits() {
        return produitRepository.findAll();
    }

    public void deleteProduit(int id) {
        produitRepository.deleteById(id);
    }
}
