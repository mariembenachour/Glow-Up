package com.GlowUp.Dressing.entities;

import java.sql.Date;
import java.util.HashSet;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "idProgramme")
@Entity
public class ProgrammeSportif {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idProgramme; 
    private String objectif; 
    private Date duree; 
    
    @ManyToOne
    @JoinColumn(name = "coach_id", nullable = false)
    private Coach coach;
    
    @OneToMany(mappedBy = "programmeSportif", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference("programme-seances")
    private Set<Seance> seances = new HashSet<>();
    
    @ManyToOne
    @JoinColumn(name = "client_id", nullable = true)
    @JsonBackReference("client-programmes")
    private Client client;
	
	public ProgrammeSportif(Integer idProgramme, String objectif, Date duree, Coach coach, Set<Seance> seances,
			Client client) {
		super();
		this.idProgramme = idProgramme;
		this.objectif = objectif;
		this.duree = duree;
		this.coach = coach;
		this.seances = seances;
		this.client = client;
	}
	
	public Client getClient() {
		return client;
	}

	public void setClient(Client client) {
		this.client = client;
	}

	public ProgrammeSportif() {
		super();
	}
	public Integer getIdProgramme() {
		return idProgramme;
	}
	public void setIdProgramme(Integer idProgramme) {
		this.idProgramme = idProgramme;
	}
	public String getObjectif() {
		return objectif;
	}
	public void setObjectif(String objectif) {
		this.objectif = objectif;
	}
	public Date getDuree() {
		return duree;
	}
	public void setDuree(Date duree) {
		this.duree = duree;
	}
	public Coach getCoach() {
		return coach;
	}
	public void setCoach(Coach coach) {
		this.coach = coach;
	}
	public Set<Seance> getSeances() {
		return seances;
	}
	public void setSeances(Set<Seance> seances) {
		this.seances = seances;
	}
	
	
    
}