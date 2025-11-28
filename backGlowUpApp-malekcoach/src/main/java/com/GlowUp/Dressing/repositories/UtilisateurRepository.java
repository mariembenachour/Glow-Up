package com.GlowUp.Dressing.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Utilisateur;
@Repository
public interface UtilisateurRepository extends JpaRepository<Utilisateur, Integer> {
	Utilisateur findByEmail(String email);
}
