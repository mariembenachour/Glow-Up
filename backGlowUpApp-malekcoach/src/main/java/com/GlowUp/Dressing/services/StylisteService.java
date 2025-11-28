package com.GlowUp.Dressing.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.GlowUp.Dressing.entities.Styliste;
import com.GlowUp.Dressing.repositories.StylisteRepository;


@Service
public class StylisteService {

    @Autowired
    private StylisteRepository stylisteRepository;
    public Styliste ajouterStyliste(Styliste styliste) {
        return stylisteRepository.save(styliste);
    }
    public Styliste getStylisteById(int id) {
        return stylisteRepository.findById(id).orElse(null);
    }
    public List<Styliste> getAllStyliste() {
        return stylisteRepository.findAll();
    }
    
}
