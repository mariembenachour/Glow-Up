package com.GlowUp.Dressing.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Dermatologue;
import com.GlowUp.Dressing.entities.Produit_SkinCare;
import com.GlowUp.Dressing.entities.Routine_SkinCare;
import com.GlowUp.Dressing.repositories.DermatologueRepository;
import com.GlowUp.Dressing.repositories.RoutineRepository;

@Service
public class DermatologueService {

    @Autowired
    private DermatologueRepository dermatologueRepository;

    @Autowired
    private RoutineRepository routineRepository;

    public Routine_SkinCare creerRoutine(int dermatologueId, Routine_SkinCare routine) {
        Dermatologue dermato = dermatologueRepository.findById(dermatologueId).orElse(null);
        if (dermato == null) return null;
        routine.setDermatologue(dermato);
        for (Produit_SkinCare p : routine.getProduits()) {
            p.setRoutine(routine);
        }
        return routineRepository.save(routine);
    }
    public List<Dermatologue> getAllDermatologues() {
        return dermatologueRepository.findAll();
    }

}
