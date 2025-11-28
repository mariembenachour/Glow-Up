package com.GlowUp.Dressing.contollers;

import com.GlowUp.Dressing.entities.Vetement;
import com.GlowUp.Dressing.services.VetementService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.Optional; // Ajouté pour la gestion des entités optionnelles

@RestController
@RequestMapping("/vetements")
public class VetementController {

    private static final String IMAGE_UPLOAD_DIR = "imagesU/";

    @Autowired
    private VetementService vetementService;

    // --- Fonctions de lecture (READ) ---
    
    @GetMapping
    public List<Vetement> getAllVetements() {
        return vetementService.getAllVetements();
    }

    @GetMapping("/{id}")
    public Vetement getVetementById(@PathVariable int id) {
        return vetementService.getVetementById(id);
    }

    @GetMapping("/nom/{nom}")
    public List<Vetement> getVetementsByNom(@PathVariable String nom) {
        return vetementService.getVetementsByNom(nom);
    }

    @GetMapping("/dressing/{idDressing}")
    public List<Vetement> getVetementsByDressing(@PathVariable int idDressing) {
        return vetementService.getVetementsByDressing(idDressing);
    }

    // --- Fonction d'ajout (CREATE) ---

    @PostMapping("/dressing/{idDressing}")
    public Vetement ajouterVetement(
            @RequestParam("nom") String nom,
            @RequestParam("couleur") String couleur,
            @RequestParam("saison") String saison,
            @RequestParam("taille") String taille,
            @RequestParam("type") String type,
            @RequestParam("image") MultipartFile imageFile,
            @PathVariable int idDressing
    ) throws IOException {

        String imageUrl = null;

        if (!imageFile.isEmpty()) {
            String fileName = UUID.randomUUID() + "_" + imageFile.getOriginalFilename();
            Path path = Paths.get(IMAGE_UPLOAD_DIR + fileName);
            Files.createDirectories(path.getParent());
            Files.write(path, imageFile.getBytes());

            imageUrl = "http://10.0.2.2:8080/" + IMAGE_UPLOAD_DIR + fileName;
        }

        Vetement vetement = new Vetement();
        vetement.setNom(nom);
        vetement.setCouleur(couleur);
        vetement.setSaison(saison);
        vetement.setTaille(taille);
        vetement.setType(type);
        vetement.setImage(imageUrl);

        return vetementService.ajouterVetement(vetement, idDressing);
    }

    // --- 🎯 FONCTION DE MODIFICATION CORRIGÉE (UPDATE) ---

    @PutMapping("/modifier/{id}") // 🚨 CORRIGÉ: Le chemin correspond à celui utilisé dans Flutter
    public ResponseEntity<Vetement> modifierVetement(
            @PathVariable int id,
            // 🚨 CORRIGÉ: Tous les champs sont maintenant des @RequestParam pour gérer multipart
            @RequestParam("nom") String nom,
            @RequestParam("couleur") String couleur,
            @RequestParam("saison") String saison,
            @RequestParam("taille") String taille,
            @RequestParam("type") String type,
            // L'image est OPTIONNELLE (required = false)
            @RequestParam(value = "image", required = false) MultipartFile imageFile,
            // Le flag de suppression est OPTIONNEL
            @RequestParam(value = "supprimerImage", required = false) String supprimerImageFlag
    ) throws IOException {
        
        Vetement existingVetement = vetementService.getVetementById(id);
        if (existingVetement == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        // 1. Mise à jour des champs de texte
        existingVetement.setNom(nom);
        existingVetement.setCouleur(couleur);
        existingVetement.setSaison(saison);
        existingVetement.setTaille(taille);
        existingVetement.setType(type);
        
        String oldImageUrl = existingVetement.getImage(); // Garde l'ancienne URL

        // 2. Logique de gestion de l'image
        if (imageFile != null && !imageFile.isEmpty()) {
            // A. Nouvelle image soumise : Supprimer l'ancienne si elle existe
            if (oldImageUrl != null && !oldImageUrl.isEmpty()) {
                supprimerFichierImage(oldImageUrl);
            }
            
            // Sauvegarder la nouvelle image
            String fileName = UUID.randomUUID() + "_" + imageFile.getOriginalFilename();
            Path path = Paths.get(IMAGE_UPLOAD_DIR + fileName);
            Files.createDirectories(path.getParent());
            Files.write(path, imageFile.getBytes());
            
            String newImageUrl = "http://10.0.2.2:8080/" + IMAGE_UPLOAD_DIR + fileName;
            existingVetement.setImage(newImageUrl);
            
        } else if (supprimerImageFlag != null && supprimerImageFlag.equals("true")) {
            // B. Demande de suppression explicite : Supprimer l'ancienne image
            if (oldImageUrl != null && !oldImageUrl.isEmpty()) {
                supprimerFichierImage(oldImageUrl);
            }
            existingVetement.setImage(null); // Réinitialiser l'URL en DB
            
        } 
        // C. Sinon (pas de nouveau fichier et pas de demande de suppression), l'ancienne URL est conservée.

        // 3. Sauvegarde en service
        Vetement updatedVetement = vetementService.modifierVetement(id, existingVetement);
        return new ResponseEntity<>(updatedVetement, HttpStatus.OK);
    }

    // --- Fonction utilitaire pour la suppression de fichier ---
    private void supprimerFichierImage(String imageUrl) {
        try {
            // Extrait le nom du fichier du chemin complet (http://10.0.2.2:8080/imagesU/filename.jpg)
            String fileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
            Path filePath = Paths.get(IMAGE_UPLOAD_DIR + fileName);
            
            if (Files.exists(filePath)) {
                Files.delete(filePath);
                System.out.println("Ancienne image supprimée : " + filePath.toAbsolutePath());
            } else {
                 System.out.println("Fichier image non trouvé pour suppression : " + filePath.toAbsolutePath());
            }
        } catch (Exception e) {
            System.err.println("Erreur lors de la suppression de l'image : " + e.getMessage());
            // L'erreur de suppression de fichier ne doit pas empêcher la mise à jour de la DB
        }
    }
    
    // --- Fonction de suppression (DELETE) ---

    @DeleteMapping("/{id}")
    public void supprimerVetement(@PathVariable int id) {
        // Logique pour supprimer aussi le fichier si nécessaire (basée sur l'URL en DB)
        // Ceci est une amélioration suggérée, mais je conserve l'appel direct au service pour le moment.
        vetementService.supprimerVetement(id);
    }
}