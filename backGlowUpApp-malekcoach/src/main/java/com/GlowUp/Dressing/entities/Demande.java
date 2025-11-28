package com.GlowUp.Dressing.entities;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import jakarta.persistence.*;
@Entity
public class Demande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int idDemande;

    private String titre;
    private String descriptionBesoins;
    private String etat;
    private String photoUrl;

    @ManyToOne(fetch = FetchType.EAGER)
	@JoinColumn(name = "client_id", referencedColumnName = "id_user")
    @JsonIgnoreProperties({"demandes","notifications"})
    private Client client;

    @ManyToOne
    @JoinColumn(name = "styliste_id")
    private Styliste styliste;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "dermatologue_id", referencedColumnName = "id_user")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "demandes"})
    private Dermatologue dermatologue;
    
    @OneToOne
    private Look lookCree;
    
    @JsonBackReference
    @ManyToOne
    @JoinColumn(name = "coach_id")
    @JsonIgnoreProperties({"demandes"})
    private Coach coach;

    public Demande() {}

   
    public String getPhotoUrl() {
		return photoUrl;
	}


	public void setPhotoUrl(String photoUrl) {
		this.photoUrl = photoUrl;
	}


	public Dermatologue getDermatologue() {
		return dermatologue;
	}


	public void setDermatologue(Dermatologue dermatologue) {
		this.dermatologue = dermatologue;
	}


	public Demande(int idDemande, String titre, String descriptionBesoins, String etat, String photoUrl, Client client,
			Styliste styliste, Dermatologue dermatologue, Look lookCree, Coach coach) {
		super();
		this.idDemande = idDemande;
		this.titre = titre;
		this.descriptionBesoins = descriptionBesoins;
		this.etat = etat;
		this.photoUrl = photoUrl;
		this.client = client;
		this.styliste = styliste;
		this.dermatologue = dermatologue;
		this.lookCree = lookCree;
		this.coach = coach;
	}


	// Getters et Setters
    public int getIdDemande() { return idDemande; }
    public void setIdDemande(int idDemande) { this.idDemande = idDemande; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getDescriptionBesoins() { return descriptionBesoins; }
    public void setDescriptionBesoins(String descriptionBesoins) { this.descriptionBesoins = descriptionBesoins; }

    public String getEtat() { return etat; }
    public void setEtat(String etat) { this.etat = etat; }

    public Client getClient() { return client; }
    public void setClient(Client client) { this.client = client; }

    public Styliste getStyliste() { return styliste; }
    public void setStyliste(Styliste styliste) { this.styliste = styliste; }

    public Look getLookCree() { return lookCree; }
    public void setLookCree(Look lookCree) { this.lookCree = lookCree; }

    public Coach getCoach() { return coach; }
    public void setCoach(Coach coach) { this.coach = coach; }
}