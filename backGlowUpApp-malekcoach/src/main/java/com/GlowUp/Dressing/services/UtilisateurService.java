package com.GlowUp.Dressing.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Notification;
import com.GlowUp.Dressing.entities.Routine_SkinCare;
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.repositories.RoutineRepository;
import com.GlowUp.Dressing.repositories.UtilisateurRepository;


@Service
public class UtilisateurService {

    @Autowired
    private UtilisateurRepository utilisateurRepository;
    @Autowired
    private RoutineRepository routineRepository;

    public Utilisateur inscrire(Utilisateur utilisateur) {
        return utilisateurRepository.save(utilisateur);
    }

    public Utilisateur getById(int id) {
        return utilisateurRepository.findById(id).orElse(null);
    }

    public List<Utilisateur> getAll() {
        return utilisateurRepository.findAll();
    }
    public Utilisateur login(String email, String password) {
        Utilisateur user = utilisateurRepository.findByEmail(email);
        if (user != null && user.getMdp().trim().equals(password.trim())) {
            return user;
        }
        return null;
    }

    public boolean modifierMdpAvecAncien(int id, String ancienMdp, String nouveauMdp) {
        Optional<Utilisateur> optUser = utilisateurRepository.findById(id);
        if(optUser.isPresent()) {
            Utilisateur user = optUser.get();
            if(user.getMdp().equals(ancienMdp)) { 
                user.setMdp(nouveauMdp);
                utilisateurRepository.save(user);
                return true;
            }
        }
        return false;
    }
    public void delete(int id) {
    	utilisateurRepository.deleteById(id);
    }
    public Client renseignerInfosPeau(int utilisateurId, String typePeau) {
        Utilisateur user = utilisateurRepository.findById(utilisateurId).orElse(null);
        if (user != null && user instanceof Client) {
            Client client = (Client) user;
            client.setTypeDePeau(typePeau);
            return utilisateurRepository.save(client);
        }
        return null;
    }
    public List<Notification> recevoirNotifications(int utilisateurId) {
        Utilisateur user = utilisateurRepository.findById(utilisateurId).orElse(null);
        if (user != null) {
            return user.getNotifications();
        }
        return null;
    }
   

}