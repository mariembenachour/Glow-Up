package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Demande;
@Repository
public interface DemandeRepository extends JpaRepository<Demande, Integer> {
    List<Demande> findByStyliste_IdUser(int stylisteId);
    List<Demande> findByCoach_IdUser(int coachId);
    List<Demande> findByDermatologue_IdUser(int dermatoId);


}
