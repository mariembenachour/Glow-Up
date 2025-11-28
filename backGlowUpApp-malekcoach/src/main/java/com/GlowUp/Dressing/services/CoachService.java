package com.GlowUp.Dressing.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Coach;
import com.GlowUp.Dressing.entities.ProgrammeSportif;
import com.GlowUp.Dressing.entities.Styliste;
import com.GlowUp.Dressing.repositories.CoachRepository;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Service
public class CoachService {
	private final ProgrammeSportifService programmeService; 
    private final CoachRepository coachRepository;

    public CoachService(ProgrammeSportifService programmeService, CoachRepository coachRepository) {
        this.programmeService = programmeService;
        this.coachRepository = coachRepository;
    }
    public Coach ajouterCoach(Coach coach) {
        return coachRepository.save(coach);
    }
    @Transactional
    public ProgrammeSportif creerProgrammeParCoach(Integer coachId, ProgrammeSportif programmeDetails) {
        // S'assurer que le Coach existe pour la transaction
        if (!coachRepository.existsById(coachId)) {
            throw new EntityNotFoundException("Le Coach avec l'ID " + coachId + " n'existe pas.");
        }
        // Délégation de la création au ProgrammeService
        return programmeService.creerProgramme(coachId, programmeDetails);
    }
    public List<Coach> getAllCoach() {
        return coachRepository.findAll();
    }
}