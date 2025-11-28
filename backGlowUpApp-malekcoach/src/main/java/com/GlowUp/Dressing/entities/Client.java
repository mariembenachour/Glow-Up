package com.GlowUp.Dressing.entities;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import jakarta.persistence.*;
@Entity
@DiscriminatorValue("CLIENT")
public class Client extends Utilisateur {

    private float taille;
    private String typeDePeau;
    private float poids;
    private String objectifSportif;

    public Client() {
		super();
	}
    
	@OneToMany(mappedBy = "client", cascade = CascadeType.ALL)
	@JsonIgnoreProperties("client")
    private List<Demande> demandes;

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference("client-programmes")
    private List<ProgrammeSportif> programmesSportifs;

    @ManyToOne
    @JoinColumn(name = "dermatologue_id")
    @JsonIgnoreProperties("clients") // pour éviter les boucles infinies
    private Dermatologue dermatologue;

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference("client-routines")   // ✅ permet de sérialiser les routines comme objets complets
    private List<Routine_SkinCare> routines = new ArrayList<>();
    // Getters et Setters
    public float getTaille() { return taille; }
    public void setTaille(float taille) { this.taille = taille; }

    public String getTypeDePeau() { return typeDePeau; }
    public void setTypeDePeau(String typeDePeau) { this.typeDePeau = typeDePeau; }

    public float getPoids() { return poids; }
    public void setPoids(float poids) { this.poids = poids; }

    public String getObjectifSportif() { return objectifSportif; }
    public void setObjectifSportif(String objectifSportif) { this.objectifSportif = objectifSportif; }

    public List<Demande> getDemandes() { return demandes; }
    public void setDemandes(List<Demande> demandes) { this.demandes = demandes; }

    public List<ProgrammeSportif> getProgrammesSportifs() { return programmesSportifs; }
    public void setProgrammesSportifs(List<ProgrammeSportif> programmesSportifs) { this.programmesSportifs = programmesSportifs; }

    public List<Routine_SkinCare> getRoutines() { return routines; }
    public void setRoutines(List<Routine_SkinCare> routines) { this.routines = routines; }
}
