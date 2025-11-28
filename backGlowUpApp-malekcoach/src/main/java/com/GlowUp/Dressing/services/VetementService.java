package com.GlowUp.Dressing.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Dressing_Virtuel;
import com.GlowUp.Dressing.entities.Look;
import com.GlowUp.Dressing.entities.Vetement;
import com.GlowUp.Dressing.repositories.DressingVirtuelRepository;
import com.GlowUp.Dressing.repositories.VetementRepository;

import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class VetementService {

    @Autowired
    private VetementRepository vetementRepository;

    @Autowired
    private DressingVirtuelRepository dressingRepository;

 
    public Vetement ajouterVetement(Vetement vetement, int idDressing) {
        Optional<Dressing_Virtuel> dressingOpt = dressingRepository.findById(idDressing);
        if (dressingOpt.isPresent()) {
            vetement.setDressingVirtuel(dressingOpt.get());
            return vetementRepository.save(vetement);
        }
        return null;
    }


    public Vetement modifierVetement(int id, Vetement updatedVetement) {
        Optional<Vetement> vOpt = vetementRepository.findById(id);
        
        if (vOpt.isPresent()) {
            Vetement vetement = vOpt.get();
            
            // Mise à jour des champs seulement s'ils sont présents dans la requête de mise à jour
            if (updatedVetement.getNom() != null) {
                vetement.setNom(updatedVetement.getNom());
            }
            if (updatedVetement.getCouleur() != null) {
                vetement.setCouleur(updatedVetement.getCouleur());
            }
            if (updatedVetement.getSaison() != null) {
                vetement.setSaison(updatedVetement.getSaison());
            }
            // 🎯 GESTION IMAGE : L'URL de l'image ne doit être mise à jour que si elle est envoyée
            if (updatedVetement.getImage() != null && !updatedVetement.getImage().isEmpty()) {
                vetement.setImage(updatedVetement.getImage());
            }
            if (updatedVetement.getTaille() != null) {
                vetement.setTaille(updatedVetement.getTaille());
            }
            if (updatedVetement.getType() != null) {
                vetement.setType(updatedVetement.getType());
            }
            
            // Note: Le dressing n'est pas modifié ici
            
            return vetementRepository.save(vetement);
        }
        return null;
    }

  
    @Transactional
    public void supprimerVetement(int idVetement) {
        Vetement vetement = vetementRepository.findById(idVetement)
            .orElseThrow(() -> new RuntimeException("Vêtement introuvable"));

       
        for (Look look : vetement.getLooks()) {
            look.getVetements().remove(vetement);
        }

        vetementRepository.delete(vetement);
    }

   
    public Vetement getVetementById(int id) {
        return vetementRepository.findById(id).orElse(null);
    }

   
    public List<Vetement> getAllVetements() {
        return vetementRepository.findAll();
    }
    
  
    public List<Vetement> getVetementsByDressing(int idDressing) {
        return vetementRepository.findByDressingVirtuel_IdDressing(idDressing);
    }

    // Note: getVetementsByNom est maintenu, mais non utilisé par le Flutter actuel
    public List<Vetement> getVetementsByNom(String nom) {
        return vetementRepository.findByNom(nom);
    }
}