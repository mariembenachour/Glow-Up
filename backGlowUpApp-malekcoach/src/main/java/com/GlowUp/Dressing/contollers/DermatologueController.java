package com.GlowUp.Dressing.contollers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Dermatologue;
import com.GlowUp.Dressing.entities.Routine_SkinCare;
import com.GlowUp.Dressing.services.DermatologueService;

@RestController
@RequestMapping("/dermato")
public class DermatologueController {

    @Autowired
    private DermatologueService dermatologueService;

    // créer routine
    @PostMapping("/creerRoutine/{idDermato}")
    public Routine_SkinCare creerRoutine(
            @PathVariable int idDermato,
            @RequestBody Routine_SkinCare routine) {

        return dermatologueService.creerRoutine(idDermato, routine);
    }
    @GetMapping
    public List<Dermatologue> getAllDermatologues() {
        return dermatologueService.getAllDermatologues();
    }

}
