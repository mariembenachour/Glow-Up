package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Seance;
@Repository
public interface SeanceRepository extends JpaRepository<Seance, Integer>{
	List<Seance> findByProgrammeSportif_Client_IdUser(Integer clientId);
	List<Seance> findByProgrammeSportif_IdProgramme(Integer programmeId);
	}
