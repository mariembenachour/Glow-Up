package com.GlowUp.Dressing.entities;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonFormat;

import jakarta.persistence.*;

@Entity
public class Seance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idSeance; 

    private String description; 

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime heureDebut;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime heureFin;

    private boolean estComplete = false; 

    @ManyToOne
    @JoinColumn(name = "programme_sportif_id", nullable = false)
    @JsonBackReference("programme-seances")
    private ProgrammeSportif programmeSportif;

    // ================= Liste d'images =================
    @ElementCollection
    @CollectionTable(name = "seance_images", joinColumns = @JoinColumn(name = "seance_id"))
    @Column(name = "url", length = 500)
    private List<String> images = new ArrayList<>();

    private String createur;
    
    public String getCreateur() {
		return createur;
	}

	public void setCreateur(String createur) {
		this.createur = createur;
	}

	public Seance() {
        super();
    }

    public Seance(Integer idSeance, String description, LocalDateTime heureDebut, LocalDateTime heureFin, 
                  ProgrammeSportif programmeSportif, boolean estComplete,String createur) {
        super();
        this.idSeance = idSeance;
        this.description = description;
        this.heureDebut = heureDebut;
        this.heureFin = heureFin;
        this.programmeSportif = programmeSportif;
        this.estComplete = estComplete; 
        this.createur=createur;
    }

    // ================= Getters et Setters =================
    public Integer getIdSeance() {
        return idSeance;
    }

    public void setIdSeance(Integer idSeance) {
        this.idSeance = idSeance;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getHeureDebut() {
        return heureDebut;
    }

    public void setHeureDebut(LocalDateTime heureDebut) {
        this.heureDebut = heureDebut;
    }

    public LocalDateTime getHeureFin() {
        return heureFin;
    }

    public void setHeureFin(LocalDateTime heureFin) {
        this.heureFin = heureFin;
    }

    public boolean isEstComplete() {
        return estComplete;
    }

    public void setEstComplete(boolean estComplete) {
        this.estComplete = estComplete;
    }

    public ProgrammeSportif getProgrammeSportif() {
        return programmeSportif;
    }

    public void setProgrammeSportif(ProgrammeSportif programmeSportif) {
        this.programmeSportif = programmeSportif;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }
}