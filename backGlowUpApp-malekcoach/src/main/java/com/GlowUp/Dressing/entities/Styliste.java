package com.GlowUp.Dressing.entities;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;

@Entity
@DiscriminatorValue("STYLISTE")
@PrimaryKeyJoinColumn(name = "id_user") // ⬅ LA CORRECTION CRITIQUE
public class Styliste extends Utilisateur { 
    private String specialite;
    

    public Styliste() {
		super();
	}

    @OneToMany(mappedBy = "styliste")
    @JsonManagedReference(value = "styliste-look")
    private List<Look> looks;
	
	@OneToMany(mappedBy = "client")
	@JsonIgnore 
	private List<Demande> demandes;

	public Styliste(int idUser, String nom, String email, String mdp, String specialite,String role) {
		super(idUser, nom, email, mdp,role);
		this.specialite = specialite;
	
	}

	public String getSpecialite() {
		return specialite;
	}

	public void setSpecialite(String specialite) {
		this.specialite = specialite;
	}

	public List<Look> getLooks() {
		return looks;
	}

	public void setLooks(List<Look> looks) {
		this.looks = looks;
	}
    
    
    }