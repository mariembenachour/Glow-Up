package com.GlowUp.Dressing.contollers;


import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Dressing_Virtuel;
import com.GlowUp.Dressing.services.ClientService;
import com.GlowUp.Dressing.services.DressingVirtuelService;

@RestController
@RequestMapping("/dressings")
public class DressingVirtuelController {

    @Autowired
    private DressingVirtuelService dressingService;
    @Autowired
    private ClientService clientService;

  
    @GetMapping("/{id}")
    public Dressing_Virtuel getDressingById(@PathVariable int id) {
        return dressingService.getDressingById(id);
    }

    @PostMapping
    public Dressing_Virtuel creerDressing(@RequestBody Dressing_Virtuel dressing) {
        return dressingService.creerDressing(dressing);
    }

    @DeleteMapping("/{id}")
    public void deleteDressing(@PathVariable int id) {
        dressingService.deleteDressing(id);
    }
    @GetMapping("/monDressing/{idClient}")
    public Dressing_Virtuel getOrCreateDressing(@PathVariable int idClient) {
        Dressing_Virtuel dressing = dressingService.getDressingByClient(idClient);
        if (dressing == null) {
            Client client = clientService.getClientById(idClient);
            dressing = new Dressing_Virtuel();
            dressing.setClient(client);
            dressing.setNomDressing("Mon Dressing");
            dressing = dressingService.creerDressing(dressing);
        }
        return dressing;
    }

    }