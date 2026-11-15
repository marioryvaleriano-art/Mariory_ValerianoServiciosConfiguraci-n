package com.practica.backend.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Modelo de documento Producto para MongoDB
 * 
 * Representa un producto simple con nombre, descripción y precio
 * para fines de demostración de la práctica
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "productos")
public class Producto {

    @Id
    private String id;

    @NotBlank(message = "El nombre del producto es obligatorio")
    private String nombre;

    private String descripcion;

    @NotNull(message = "El precio es obligatorio")
    @Positive(message = "El precio debe ser positivo")
    private Double precio;

    private Boolean disponible;

    public Producto(String nombre, String descripcion, Double precio, Boolean disponible) {
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precio = precio;
        this.disponible = disponible;
    }
}
