package com.GlowUp.Dressing.contollers;


import com.GlowUp.Dressing.entities.ProgrammeSportif;
import com.GlowUp.Dressing.services.ProgrammeSportifService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/programmes") 
public class ProgrammeSportifController {

    private final ProgrammeSportifService programmeSportifService;

    public ProgrammeSportifController(ProgrammeSportifService programmeSportifService) {
        this.programmeSportifService = programmeSportifService;
    }


    @GetMapping("/client/{clientId}")
    public List<ProgrammeSportif> getProgrammesByClient(@PathVariable Integer clientId) {
        return programmeSportifService.listerProgrammesClient(clientId);
    }
 
    @PutMapping("/{programmeId}/attribuer/{clientId}")
    public ProgrammeSportif attribuerProgramme(
            @PathVariable Integer programmeId, 
            @PathVariable Integer clientId) {
        
        return programmeSportifService.attribuerProgramme(programmeId, clientId);
    }
    

}