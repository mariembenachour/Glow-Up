package com.GlowUp.Dressing.entities;

import java.util.ArrayList;
import java.util.List;

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

@Entity

public class Routine_SkinCare {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre;
    private String description;
    private String soinTime;

    @ManyToOne
    @JoinColumn(name = "dermatologue_id", nullable = true)
    private Dermatologue dermatologue;

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = true)
    @JsonBackReference("client-routines")   // ✅ évite boucle infinie côté Client
    private Client client;

    @OneToMany(mappedBy = "routine", cascade = CascadeType.ALL)
    @JsonManagedReference("routine-produits") // côté parent

    private List<Produit_SkinCare> produits;
;

    // 🔹 Constructeurs
    public Routine_SkinCare() {}

    public Routine_SkinCare(Long id, String titre, String description, String soinTime,
                            Dermatologue dermatologue, Client client, List<Produit_SkinCare> produits) {
        this.id = id;
        this.titre = titre;
        this.description = description;
        this.soinTime = soinTime;
        this.dermatologue = dermatologue;
        this.client = client;
        this.produits = produits;
    }

    // 🔹 Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getSoinTime() { return soinTime; }
    public void setSoinTime(String soinTime) { this.soinTime = soinTime; }

    public Dermatologue getDermatologue() { return dermatologue; }
    public void setDermatologue(Dermatologue dermatologue) { this.dermatologue = dermatologue; }

    public Client getClient() { return client; }
    public void setClient(Client client) { this.client = client; }

    public List<Produit_SkinCare> getProduits() { return produits; }
    public void setProduits(List<Produit_SkinCare> produits) { this.produits = produits; }
}
