package com.GlowUp.Dressing.entities;
import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int idNotification;
    private String message;
    private String etat;
    @ManyToOne
    @JoinColumn(name = "destinataire_id_user")
    @JsonIgnore
    private Utilisateur destinataire;
    public Notification() {
		super();
	}
	public Notification(int idNotification, String message, String etat, Utilisateur destinataire) {
		super();
		this.idNotification = idNotification;
		this.message = message;
		this.etat = etat;
		this.destinataire = destinataire;
	}
	public int getIdNotification() {
		return idNotification;
	}
	public void setIdNotification(int idNotification) {
		this.idNotification = idNotification;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public String getEtat() {
		return etat;
	}
	public void setEtat(String etat) {
		this.etat = etat;
	}
	public Utilisateur getDestinataire() {
		return destinataire;
	}
	public void setDestinataire(Utilisateur destinataire) {
		this.destinataire = destinataire;
	}
	
	
	
    
}
