package com.practica.backend.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.practica.backend.model.Producto;

/**
 * Repository para operaciones CRUD con MongoDB
 * 
 * Spring Data MongoDB proporciona implementaciones automáticas
 * de los métodos básicos y métodos de consulta personalizados
 */
@Repository
public interface ProductoRepository extends MongoRepository<Producto, String> {

    /**
     * Buscar productos por disponibilidad
     * @param disponible true para productos disponibles, false para no disponibles
     * @return Lista de productos que coinciden con la disponibilidad
     */
    List<Producto> findByDisponible(Boolean disponible);

    /**
     * Buscar productos cuyo nombre contenga el texto especificado (case insensitive)
     * @param nombre Texto a buscar en el nombre
     * @return Lista de productos que coinciden
     */
    List<Producto> findByNombreContainingIgnoreCase(String nombre);
}
