package com.GlowUp.Dressing.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Routine_SkinCare;
@Repository
public interface RoutineRepository extends JpaRepository<Routine_SkinCare, Integer>{

}
