package com.GlowUp.Dressing.entities;

import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.DiscriminatorColumn;
import jakarta.persistence.DiscriminatorType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "dtype", discriminatorType = DiscriminatorType.STRING)
@Table(name = "utilisateur", uniqueConstraints = @UniqueConstraint(columnNames = "email"))
public class Utilisateur {

    @Id
    @GeneratedValue
    (strategy = GenerationType.IDENTITY)
    private int idUser;
    private String nom;
    private String email;
    private String mdp;
    private String role;
    
    
	public Utilisateur() {
		super();
	}
	
	public Utilisateur(int idUser, String nom, String email, String mdp, String role) {
		super();
		this.idUser = idUser;
		this.nom = nom;
		this.email = email;
		this.mdp = mdp;
		this.role = role;
	}

	public String getRole() {
		return role;
	}
	public void setRole(String role) {
		this.role = role;
	}

	@OneToMany(mappedBy = "destinataire", cascade = CascadeType.ALL, orphanRemoval = true)
	private List<Notification> notifications;
    
	
	public List<Notification> getNotifications() {
		return notifications;
	}
	public void setNotifications(List<Notification> notifications) {
		this.notifications = notifications;
	}
	public int getIdUser() {
		return idUser;
	}
	public void setIdUser(int idUser) {
		this.idUser = idUser;
	}
	public String getNom() {
		return nom;
	}
	public void setNom(String nom) {
		this.nom = nom;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getMdp() {
		return mdp;
	}
	public void setMdp(String mdp) {
		this.mdp = mdp;
	} 
}
