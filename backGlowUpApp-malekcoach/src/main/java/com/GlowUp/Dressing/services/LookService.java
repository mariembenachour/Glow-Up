package com.GlowUp.Dressing.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Look;
import com.GlowUp.Dressing.entities.Styliste;
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.entities.Vetement;
import com.GlowUp.Dressing.repositories.LookRepository;
import com.GlowUp.Dressing.repositories.UtilisateurRepository;
import com.GlowUp.Dressing.repositories.VetementRepository;


@Service
public class LookService {

	@Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private VetementRepository vetementRepository;

    @Autowired
    private LookRepository lookRepository;

    public Look creerLook(Look look, List<Integer> vetementIds, Integer idClient, Integer idStyliste) {

        // 🔹 Récupérer le client
        Utilisateur client = utilisateurRepository.findById(idClient)
            .orElseThrow(() -> new RuntimeException("Client non trouvé avec id " + idClient));

        if (!"CLIENT".equalsIgnoreCase(client.getRole())) {
            throw new RuntimeException("L'utilisateur avec id " + idClient + " n'est pas un client !");
        }

        // 🔹 Récupérer le styliste
        Utilisateur styliste = utilisateurRepository.findById(idStyliste)
            .orElseThrow(() -> new RuntimeException("Styliste non trouvé avec id " + idStyliste));

        if (!"STYLISTE".equalsIgnoreCase(styliste.getRole())) {
            throw new RuntimeException("L'utilisateur avec id " + idStyliste + " n'est pas un styliste !");
        }

        // 🔹 Charger les vêtements
        List<Vetement> vetements = vetementRepository.findAllById(vetementIds);

        // 🔹 Associer tout au look
        look.setClient((Client) client);
        look.setStyliste((Styliste) styliste);
        look.setVetements(vetements);

        return lookRepository.save(look);
    }

    public Look getLookById(int id) {
        return lookRepository.findById(id).orElse(null);
    }
    public Look mettreAJourFavoris(int id, boolean favoris) {
        return lookRepository.findById(id).map(look -> {
            look.setFavoris(favoris);
            return lookRepository.save(look);
        }).orElse(null);
    }

    public List<Look> getLooksFavoris() {
        return lookRepository.findByFavorisTrue();
    }
    public List<Look> getLooksByClientId(int idUser) {
        return lookRepository.findByClient_IdUser(idUser);
    }

    
    public List<Look> getAllLooks() {
        return lookRepository.findAll();
    }

    public List<Look> getLooksByCategorie(String categorie) {
        return lookRepository.findByCategorie(categorie);
    }
    public void deleteLook(int id) {
    	  lookRepository.deleteById(id);
    }
    public Look updateLook(Look look) {
        Optional<Look> existingLookOpt = lookRepository.findById(look.getIdLook());

        if (existingLookOpt.isPresent()) {
            Look existingLook = existingLookOpt.get();

            existingLook.setNom(look.getNom());
            existingLook.setCategorie(look.getCategorie());
            existingLook.setDescription(look.getDescription());
            existingLook.setVetements(look.getVetements());
            return lookRepository.save(existingLook);
        }

        return null;
    }
}