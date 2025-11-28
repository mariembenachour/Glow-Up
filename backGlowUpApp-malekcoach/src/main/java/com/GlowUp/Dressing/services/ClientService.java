package com.GlowUp.Dressing.services;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Client;
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.repositories.ClientRepository;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;


@Service
public class ClientService {

    @Autowired
    private ClientRepository clientRepository;

    public Client ajouterClient(Client utilisateur) {
        return clientRepository.save(utilisateur);
    }

    public Client getClientById(int id) {
        Optional<Client> clientOpt = clientRepository.findById(id);
        return clientOpt.orElse(null);
    }

    public List<Client> getAllClients() {
        return clientRepository.findAll();
    }
    public void deleteById(int id) {
        clientRepository.deleteById(id);
    }
    @Transactional
    public Client mettreAJourObjectif(Integer id, String nouvelObjectif) {
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Client non trouvé avec l'ID: " + id));
        client.setObjectifSportif(nouvelObjectif);
        return clientRepository.save(client);
    }
  
}