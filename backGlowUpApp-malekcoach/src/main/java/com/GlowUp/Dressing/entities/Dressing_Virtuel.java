package com.GlowUp.Dressing.entities;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;

@Entity
public class Dressing_Virtuel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int idDressing;
    private String nomDressing;
    
    public Dressing_Virtuel() {
		super();
	}
    @JsonManagedReference
	@OneToMany(mappedBy = "dressingVirtuel", cascade = CascadeType.ALL)
    private List<Vetement> vetements;
    @OneToOne
    private Client client;
  
	public Dressing_Virtuel(int idDressing, String nomDressing, List<Vetement> vetements, Client client) {
		super();
		this.idDressing = idDressing;
		this.nomDressing = nomDressing;
		this.vetements = vetements;
		this.client = client;
	}
	public int getIdDressing() {
		return idDressing;
	}
	public void setIdDressing(int idDressing) {
		this.idDressing = idDressing;
	}
	public String getNomDressing() {
		return nomDressing;
	}
	public void setNomDressing(String nomDressing) {
		this.nomDressing = nomDressing;
	}
	public List<Vetement> getVetements() {
		return vetements;
	}
	public void setVetements(List<Vetement> vetements) {
		this.vetements = vetements;
	}
	public Client getClient() {
		return client;
	}
	public void setClient(Client client) {
		this.client = client;
	}
}