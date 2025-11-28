package com.GlowUp.Dressing.entities;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "look")
public class Look {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int idLook;

    private String nom;
    private String categorie; 
    private String description;
    private boolean favoris = false; // par défaut false

    @ManyToOne
    @JoinColumn(name = "idClient")
    @JsonBackReference(value = "client-look")
    private Client client;

    @ManyToOne
    @JoinColumn(name = "idStyliste")
    @JsonBackReference(value = "styliste-look")
    private Styliste styliste;

    @ManyToMany
    @JoinTable(
        name = "look_vetement",
        joinColumns = @JoinColumn(name = "idLook"),
        inverseJoinColumns = @JoinColumn(name = "idVetement")
    )
    @JsonIgnoreProperties("looks") // empêche boucle avec Vetement
    private List<Vetement> vetements;

    public Look() {}

    public Look(String nom, String categorie, String description, boolean favoris, Client client,
                Styliste styliste, List<Vetement> vetements) {
        this.nom = nom;
        this.categorie = categorie;
        this.description = description;
        this.favoris = favoris;
        this.client = client;
        this.styliste = styliste;
        this.vetements = vetements;
    }

    // --- Getters & Setters ---
    public int getIdLook() { return idLook; }
    public void setIdLook(int idLook) { this.idLook = idLook; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getCategorie() { return categorie; }
    public void setCategorie(String categorie) { this.categorie = categorie; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isFavoris() { return favoris; }
    public void setFavoris(boolean favoris) { this.favoris = favoris; }

    public List<Vetement> getVetements() { return vetements; }
    public void setVetements(List<Vetement> vetements) { this.vetements = vetements; }

    public Styliste getStyliste() { return styliste; }
    public void setStyliste(Styliste styliste) { this.styliste = styliste; }

    public Client getClient() { return client; }
    public void setClient(Client client) { this.client = client; }
}