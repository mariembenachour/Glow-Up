package com.GlowUp.Dressing.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Dressing_Virtuel;
import com.GlowUp.Dressing.repositories.DressingVirtuelRepository;


@Service
public class DressingVirtuelService {

    @Autowired
    private DressingVirtuelRepository dressingRepository;

    public Dressing_Virtuel creerDressing(Dressing_Virtuel dressing) {
        return dressingRepository.save(dressing);
    }

    public Dressing_Virtuel getDressingById(int id) {
        return dressingRepository.findById(id).orElse(null);
    }
    public void deleteDressing(int id) {
    	dressingRepository.deleteById(id);
    }
    public Dressing_Virtuel getDressingByClient(int idUser) {
        return dressingRepository.findByClient_IdUser(idUser);
    }

    }