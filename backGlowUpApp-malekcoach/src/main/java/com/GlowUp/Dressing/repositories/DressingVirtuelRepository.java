package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Dressing_Virtuel;
@Repository
public interface DressingVirtuelRepository extends JpaRepository<Dressing_Virtuel, Integer> {
	Dressing_Virtuel findByClient_IdUser(Integer idUser);



}
