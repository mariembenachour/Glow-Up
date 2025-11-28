package com.GlowUp.Dressing.contollers;


import com.GlowUp.Dressing.entities.Coach;
import com.GlowUp.Dressing.entities.ProgrammeSportif;
import com.GlowUp.Dressing.entities.Styliste;
import com.GlowUp.Dressing.services.CoachService; // Votre service de façade
import com.GlowUp.Dressing.services.ProgrammeSportifService; // Le service qui gère l'attribution

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/coachs") 
public class CoachController {

    private final CoachService coachService;
    private final ProgrammeSportifService programmeService; // Nécessaire pour l'attribution

    // Injection des services par constructeur
    public CoachController(CoachService coachService, ProgrammeSportifService programmeService) {
        this.coachService = coachService;
        this.programmeService = programmeService;
    }
    @GetMapping
    public List<Coach> getAllCoachs() {
        return coachService.getAllCoach();
    }

   
    @PostMapping("/{coachId}/programmes")
    @ResponseStatus(HttpStatus.CREATED) // Retourne un code 201 en cas de succès
    public ProgrammeSportif creerProgramme(
            @PathVariable Integer coachId, // Récupère l'ID du coach depuis l'URL
            @RequestBody ProgrammeSportif programmeDetails) { // Récupère le corps JSON du programme
        
        return coachService.creerProgrammeParCoach(coachId, programmeDetails);
    }
    
  
    @PutMapping("/attribuer/{programmeId}/{clientId}")
    public ProgrammeSportif attribuerProgramme(
            @PathVariable Integer programmeId, 
            @PathVariable Integer clientId) {
        
        return programmeService.attribuerProgramme(programmeId, clientId);
    }
    
    @PostMapping("/register")
    public Coach addStyliste(@RequestBody Coach coach) {
        return coachService.ajouterCoach(coach);
    }
    @GetMapping("/programmes/client/{clientId}")
    public List<ProgrammeSportif> getProgrammesByClient(@PathVariable Integer clientId) {
        return programmeService.listerProgrammesClient(clientId);
    }
}