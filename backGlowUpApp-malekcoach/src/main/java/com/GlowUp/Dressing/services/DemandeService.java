package com.GlowUp.Dressing.services;

import com.GlowUp.Dressing.entities.*;
import com.GlowUp.Dressing.repositories.*;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
@Service
public class DemandeService {

	@Autowired
    private DemandeRepository demandeRepository;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private StylisteRepository stylisteRepository;

    @Autowired
    private CoachRepository coachRepository;

    @Autowired
    private DermatologueRepository dermatologueRepository;

    @Autowired
    private NotificationService NotificationService;

    // ---------------------------------------------------
    // 🚀 Envoi de demande (avec ou sans images)
    // ---------------------------------------------------
    @Transactional
    public Demande envoyerDemande(Demande demande, MultipartFile[] images) {

        // Vérifier client
        if (demande.getClient() == null || demande.getClient().getIdUser() == 0) {
            throw new IllegalArgumentException("Client manquant");
        }

        Client client = clientRepository.findById(demande.getClient().getIdUser())
                .orElseThrow(() -> new IllegalArgumentException("Client introuvable"));
        demande.setClient(client);

        // Styliste
        if (demande.getStyliste() != null && demande.getStyliste().getIdUser() != 0) {
            stylisteRepository.findById(demande.getStyliste().getIdUser())
                    .ifPresent(demande::setStyliste);
        }

        // Coach
        if (demande.getCoach() != null && demande.getCoach().getIdUser() != 0) {
            coachRepository.findById(demande.getCoach().getIdUser())
                    .ifPresent(demande::setCoach);
        }

        // Dermatologue
        if (demande.getDermatologue() != null && demande.getDermatologue().getIdUser() != 0) {
            dermatologueRepository.findById(demande.getDermatologue().getIdUser())
                    .ifPresent(demande::setDermatologue);
        }

        // État par défaut
        demande.setEtat("en attente");

        // Sauvegarde initiale
        Demande saved = demandeRepository.save(demande);

        // Gestion des images
        if (images != null && images.length > 0) {
            String uploadsDir = "uploads/derma/";
            File dir = new File(uploadsDir);
            if (!dir.exists()) dir.mkdirs();

            for (MultipartFile img : images) {
                if (img != null && !img.isEmpty()) {
                    try {
                        String finalName = img.getOriginalFilename(); // ou UUID + "_" + originalName si tu veux
                        Path path = Paths.get(uploadsDir + finalName);
                        Files.write(path, img.getBytes());

                        // 🔹 Enregistre le chemin relatif complet
                        saved.setPhotoUrl(uploadsDir + finalName); // → "uploads/derma/image.png"
                    } catch (IOException e) {
                        throw new RuntimeException("Erreur lors de la sauvegarde d'image", e);
                    }
                }
            }

            saved = demandeRepository.save(saved);
        }

        // Notification
        NotificationService.envoyerNotification(
                client,
                "Votre demande a été envoyée avec succès !"
        );

        return saved;
    }
    
    public List<Demande> getDemandes() {
        return demandeRepository.findAll();
    }
    
    // Méthode pour lister les demandes d'un Coach (Nouvelle exigence)
    public List<Demande> getDemandesByCoachId(int coachId) {
        return demandeRepository.findByCoach_IdUser(coachId);
    }
    public List<Demande> getDemandesByDermatologue(int dermatologueId) {
        return demandeRepository.findByDermatologue_IdUser(dermatologueId);
    }
    // Méthode existante pour lister les demandes d'un Styliste
    public List<Demande> getDemandesByStylisteId(int stylisteId) {
        return demandeRepository.findByStyliste_IdUser(stylisteId);
    }

    @Transactional
    public Demande changerEtat(int id, String etat) {
        Demande demande = demandeRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Demande non trouvée avec l'ID: " + id));

        demande.setEtat(etat);
        Demande updatedDemande = demandeRepository.save(demande);

        Client client = demande.getClient();

        String professionnel = "le professionnel";
        if (demande.getStyliste() != null) {
            professionnel = "le styliste";
        } else if (demande.getCoach() != null) {
            professionnel = "le coach";
        }else if (demande.getDermatologue() != null) {
            professionnel = "le dermatologue";
        }

        String titre = demande.getTitre() != null ? demande.getTitre() : "Votre demande";

        String message = "Votre demande : " + titre + " a été " + etat.toLowerCase() + " par " + professionnel + ".";

        NotificationService.envoyerNotification(client, message);

        return updatedDemande;
    }

    
    public void deleteDemande(int id) {
        demandeRepository.deleteById(id);
    }
}