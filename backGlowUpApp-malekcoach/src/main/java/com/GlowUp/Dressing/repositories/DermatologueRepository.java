package com.GlowUp.Dressing.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Dermatologue;
@Repository
public interface DermatologueRepository extends JpaRepository<Dermatologue, Integer>{

}
