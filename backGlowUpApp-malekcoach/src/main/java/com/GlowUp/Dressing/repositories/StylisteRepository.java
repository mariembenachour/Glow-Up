package com.GlowUp.Dressing.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Styliste;
@Repository
public interface StylisteRepository extends JpaRepository<Styliste, Integer> {

}
