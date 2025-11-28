package com.GlowUp.Dressing.contollers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.services.ClientService;

@RestController
@RequestMapping("/clients")
public class ClientController {

    @Autowired
    private ClientService clientService;

    @PostMapping("/register")
    public Utilisateur register(@RequestBody Client utilisateur) {
        return clientService.ajouterClient(utilisateur);
    }
    @GetMapping
    public List<Client> getAllClients() {
        return clientService.getAllClients();
    }
    @GetMapping("/{id}")
    public Client getClientById(@PathVariable int id) {
        return clientService.getClientById(id);
    }
    @PostMapping
    public Client addClient(@RequestBody Client client) {
        return clientService.ajouterClient(client);
    }
    @DeleteMapping("/{id}")
    public void deleteClient(@PathVariable int id) {
        clientService.deleteById(id);
    }
    @PutMapping("/{id}/objectif")
    public Client mettreAJourObjectif(
            @PathVariable Integer id, 
            @RequestParam String nouvelObjectif) {
                return clientService.mettreAJourObjectif(id, nouvelObjectif); 
    }
}