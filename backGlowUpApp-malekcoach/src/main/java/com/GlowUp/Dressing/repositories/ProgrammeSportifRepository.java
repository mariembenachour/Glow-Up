package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.ProgrammeSportif;
@Repository
public interface ProgrammeSportifRepository extends JpaRepository<ProgrammeSportif, Integer>{
	List<ProgrammeSportif> findByClient_IdUser(Integer clientId);}
