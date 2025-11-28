package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Dressing_Virtuel;
import com.GlowUp.Dressing.entities.Vetement;
@Repository
public interface VetementRepository extends JpaRepository<Vetement, Integer> {
	List<Vetement> findByDressingVirtuel_IdDressing(int idDressing);
    List<Vetement> findByNom(String nom);
}