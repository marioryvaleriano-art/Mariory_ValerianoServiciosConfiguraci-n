package com.practica.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Clase principal de la aplicación Spring Boot
 * 
 * Práctica S08 | AP6 - Exposición de Servicios y Configuración Segura en Minikube
 * 
 * Esta aplicación demuestra:
 * - Conexión a MongoDB desplegado en Kubernetes
 * - Configuración mediante ConfigMap y Secret
 * - Exposición de servicios mediante NodePort
 * - API REST funcional con operaciones CRUD básicas
 */
@SpringBootApplication
public class BackendPracticaApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendPracticaApplication.class, args);
    }
}
