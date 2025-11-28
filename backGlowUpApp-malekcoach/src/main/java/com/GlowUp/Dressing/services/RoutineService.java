package com.GlowUp.Dressing.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Dermatologue;
import com.GlowUp.Dressing.entities.Produit_SkinCare;
import com.GlowUp.Dressing.entities.Routine_SkinCare;
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.repositories.RoutineRepository;
import com.GlowUp.Dressing.repositories.UtilisateurRepository;

@Service
public class RoutineService {

    @Autowired
    private RoutineRepository routineRepository;

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private NotificationService notificationService;

    public Routine_SkinCare creerRoutineComplete(
            int utilisateurId, 
            int dermatologueId,
            String titre, 
            String description, 
            String soinTime, 
            List<Produit_SkinCare> produits) {

        // 🔹 Charger le client
        Utilisateur user = utilisateurRepository.findById(utilisateurId).orElse(null);
        if (user == null || !(user instanceof Client)) {
            return null;
        }
        Client client = (Client) user;

        // 🔹 Charger le dermatologue
        Utilisateur derm = utilisateurRepository.findById(dermatologueId).orElse(null);
        if (derm == null || !(derm instanceof Dermatologue)) {
            return null; // dermatologue introuvable
        }
        Dermatologue dermatologue = (Dermatologue) derm;

        // 🔹 Créer la routine
        Routine_SkinCare routine = new Routine_SkinCare();
        routine.setTitre(titre);
        routine.setDescription(description);
        routine.setSoinTime(soinTime);
        routine.setClient(client);
        routine.setDermatologue(dermatologue); // ✔️ IMPORTANT : correction !

        // 🔹 Ajouter produits
        if (produits != null) {
            for (Produit_SkinCare produit : produits) {
                produit.setRoutine(routine);
            }
            routine.setProduits(produits);
        }

        // 🔹 Ajouter dans la liste du client
        client.getRoutines().add(routine);
        dermatologue.getRoutines().add(routine);

        // 🔹 Sauvegarder
        routine = routineRepository.save(routine);

        // 🔹 Notification
        notificationService.envoyerNotification(client, 
            "Nouvelle routine disponible : " + titre);

        return routine;
    }

    public List<Routine_SkinCare> getRoutinesByUtilisateur(Integer utilisateurId) {
        Utilisateur user = utilisateurRepository.findById(utilisateurId).orElse(null);
        if (user != null && user instanceof Client) {
            Client client = (Client) user; 
            return client.getRoutines();   
        }
        return null; 
    }
 

    public void deleteRoutine(Integer routineId) {
        routineRepository.deleteById(routineId);
    }

    public Routine_SkinCare ajouterProduits(Integer routineId, List<Produit_SkinCare> produits) {
    	Routine_SkinCare routine = routineRepository.findById(routineId).orElse(null);
        if (routine != null) {
            for (Produit_SkinCare p : produits) {
                p.setRoutine(routine);
            }
            routine.setProduits(produits);
            return routineRepository.save(routine);
        }
        return null;
    }
    public Routine_SkinCare modifierRoutine(Integer routineId, String titre, String description, String soinTime) {
        Routine_SkinCare routine = routineRepository.findById(routineId).orElse(null);
        if (routine != null) {
            if (titre != null && !titre.isEmpty()) {
                routine.setTitre(titre);
            }
            if (description != null && !description.isEmpty()) {
                routine.setDescription(description);
            }
            if (soinTime != null && !soinTime.isEmpty()) {
                routine.setSoinTime(soinTime);
            }
            return routineRepository.save(routine);
        }
        return null;
    }

}