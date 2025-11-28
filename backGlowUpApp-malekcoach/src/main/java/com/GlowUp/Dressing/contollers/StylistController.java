package com.GlowUp.Dressing.contollers;


import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Styliste;
import com.GlowUp.Dressing.services.StylisteService;

@RestController
@RequestMapping("/stylistes")
public class StylistController {

    @Autowired
    private StylisteService stylisteService;

    @GetMapping
    public List<Styliste> getAllStylistes() {
        return stylisteService.getAllStyliste();
    }
    @GetMapping("/{id}")
    public Styliste getStylisteById(@PathVariable int id) {
        return stylisteService.getStylisteById(id);
    }

    @PostMapping("/register")
    public Styliste addStyliste(@RequestBody Styliste styliste) {
        return stylisteService.ajouterStyliste(styliste);
    }

}
