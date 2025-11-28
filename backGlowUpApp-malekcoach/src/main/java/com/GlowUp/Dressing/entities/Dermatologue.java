package com.GlowUp.Dressing.entities;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;

@Entity
public class Dermatologue extends Utilisateur{            
    private String adresseCabinet; 
    @OneToMany(mappedBy = "dermatologue", cascade = CascadeType.ALL)
    private List<Routine_SkinCare> routines = new ArrayList<>();
    @OneToMany(mappedBy = "dermatologue", cascade = CascadeType.ALL)
    @JsonIgnoreProperties("dermatologue")
    private List<Demande> demandes = new ArrayList<>();

	
	public Dermatologue(String adresseCabinet, List<Routine_SkinCare> routines, List<Demande> demandes) {
		super();
		this.adresseCabinet = adresseCabinet;
		this.routines = routines;
		this.demandes = demandes;
	}
	public Dermatologue() {
		super();
	}
	
	public List<Demande> getDemandes() {
		return demandes;
	}
	public void setDemandes(List<Demande> demandes) {
		this.demandes = demandes;
	}
	public String getAdresseCabinet() {
		return adresseCabinet;
	}
	public void setAdresseCabinet(String adresseCabinet) {
		this.adresseCabinet = adresseCabinet;
	}
	public List<Routine_SkinCare> getRoutines() {
		return routines;
	}
	public void setRoutines(List<Routine_SkinCare> routines) {
		this.routines = routines;
	}
    
}