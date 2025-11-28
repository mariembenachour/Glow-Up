package com.GlowUp.Dressing.services;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Coach;
import com.GlowUp.Dressing.entities.ProgrammeSportif;
import com.GlowUp.Dressing.repositories.ClientRepository;
import com.GlowUp.Dressing.repositories.CoachRepository;
import com.GlowUp.Dressing.repositories.ProgrammeSportifRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProgrammeSportifService {

    private final ProgrammeSportifRepository programmeRepository;
    private final CoachRepository coachRepository;
    private final ClientRepository clientRepository;

    public ProgrammeSportifService(ProgrammeSportifRepository programmeRepository, 
                            CoachRepository coachRepository,
                            ClientRepository clientRepository) {
        this.programmeRepository = programmeRepository;
        this.coachRepository = coachRepository;
        this.clientRepository = clientRepository;
    }

    
    @Transactional
    public ProgrammeSportif creerProgramme(Integer coachId, ProgrammeSportif programmeDetails) {
        Coach coach = coachRepository.findById(coachId)
                .orElseThrow(() -> new EntityNotFoundException("Coach non trouvé lors de la création du programme."));

        programmeDetails.setCoach(coach);
        programmeDetails.setClient(null); // Le programme est créé sans être attribué

        // Gérer la relation bidirectionnelle avec les Séances
        if (programmeDetails.getSeances() != null) {
            programmeDetails.getSeances().forEach(seance -> seance.setProgrammeSportif(programmeDetails));
        }

        return programmeRepository.save(programmeDetails);
    }

    /**
     * US 4 (Attribution): Affecte un programme créé à un client.
     */
    @Transactional
    public ProgrammeSportif attribuerProgramme(Integer programmeId, Integer clientId) {
        ProgrammeSportif programme = programmeRepository.findById(programmeId)
                .orElseThrow(() -> new EntityNotFoundException("Programme non trouvé avec l'ID: " + programmeId));

        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new EntityNotFoundException("Client non trouvé avec l'ID: " + clientId));

        // Lier le programme à l'entité Client
        programme.setClient(client);
        return programmeRepository.save(programme);
    }

    /**
     * US 4 (Consultation): Récupère tous les programmes attribués à un client.
     * Nécessite une méthode findByClient_IdUser dans ProgrammeSportifRepository.
     */
    public List<ProgrammeSportif> listerProgrammesClient(Integer clientId) {
        // Supposition de la méthode de recherche dans le Repository
        return programmeRepository.findByClient_IdUser(clientId); 
    }
}