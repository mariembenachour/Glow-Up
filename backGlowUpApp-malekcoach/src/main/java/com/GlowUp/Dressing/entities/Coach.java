package com.GlowUp.Dressing.entities;

import java.util.HashSet;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
@Entity
public class Coach extends Utilisateur {

    private String domaine;

    @OneToMany(mappedBy = "coach", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private Set<Demande> demandes = new HashSet<>();

    
    @OneToMany(mappedBy = "coach", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private Set<ProgrammeSportif> programmes = new HashSet<>();

    public Coach() {}

    public Coach(int idUser, String nom, String email, String mdp, String domaine, String role) {
        super(idUser, nom, email, mdp, role);
        this.domaine = domaine;
    }

    public String getDomaine() {
        return domaine;
    }

    public void setDomaine(String domaine) {
        this.domaine = domaine;
    }

    public Set<ProgrammeSportif> getProgrammes() {
        return programmes;
    }

    public void setProgrammes(Set<ProgrammeSportif> programmes) {
        this.programmes = programmes;
    }

    public Set<Demande> getDemandes() {
        return demandes;
    }

    public void setDemandes(Set<Demande> demandes) {
        this.demandes = demandes;
    }
}