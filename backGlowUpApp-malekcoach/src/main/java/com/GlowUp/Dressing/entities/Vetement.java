package com.GlowUp.Dressing.entities;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "vetement")
public class Vetement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int idVetement;
    private String nom;
    private String couleur;
    private String saison;
    private String taille;
    private String type;
    @JsonBackReference
	@ManyToOne
    @JoinColumn(name = "id_dressing") 
    private Dressing_Virtuel dressingVirtuel;
    @ManyToMany(mappedBy = "vetements")
    @JsonIgnoreProperties("vetements") // empêche la boucle infinie
    private List<Look> looks;

	public Vetement(int idVetement, String nom, String couleur, String saison, String image,
			String taille,String type,Dressing_Virtuel dressingVirtuel, List<Look> looks) {
		super();
		this.idVetement = idVetement;
		this.nom = nom;
		this.couleur = couleur;
		this.saison = saison;
		this.image = image;
		this.taille=taille;
		this.type=type;
		this.dressingVirtuel = dressingVirtuel;
		this.looks = looks;
	}
	 public String getTaille() {
			return taille;
		}
		public void setTaille(String taille) {
			this.taille = taille;
		}
		public String getType() {
			return type;
		}
		public void setType(String type) {
			this.type = type;
		}
		private String image;
	    
	    public Vetement() {
			super();
		}
	public int getIdVetement() {
		return idVetement;
	}
	public void setIdVetement(int idVetement) {
		this.idVetement = idVetement;
	}
	public String getNom() {
		return nom;
	}
	public void setNom(String nom) {
		this.nom = nom;
	}
	public String getCouleur() {
		return couleur;
	}
	public void setCouleur(String couleur) {
		this.couleur = couleur;
	}
	public String getSaison() {
		return saison;
	}
	public void setSaison(String saison) {
		this.saison = saison;
	}
	public String getImage() {
		return image;
	}
	public void setImage(String image) {
		this.image = image;
	}
	public Dressing_Virtuel getDressingVirtuel() {
		return dressingVirtuel;
	}
	public void setDressingVirtuel(Dressing_Virtuel dressingVirtuel) {
		this.dressingVirtuel = dressingVirtuel;
	}
	public List<Look> getLooks() {
		return looks;
	}
	public void setLooks(List<Look> looks) {
		this.looks = looks;
	} 
}