package com.GlowUp.Dressing.entities;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")

public class Produit_SkinCare {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String nom;
    private String description;
    private String type;
    private String imageUrl;

    @ManyToOne
    @JoinColumn(name = "routine_id")
    @JsonBackReference("routine-produits") // côté enfant

    private Routine_SkinCare routine;

    // 🔹 Constructeurs
    public Produit_SkinCare() {}

    public Produit_SkinCare(int id, String nom, String description, String type, String imageUrl,
                            Routine_SkinCare routine) {
        this.id = id;
        this.nom = nom;
        this.description = description;
        this.type = type;
        this.imageUrl = imageUrl;
        this.routine = routine;
    }

    // 🔹 Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Routine_SkinCare getRoutine() { return routine; }
    public void setRoutine(Routine_SkinCare routine) { this.routine = routine; }
}
