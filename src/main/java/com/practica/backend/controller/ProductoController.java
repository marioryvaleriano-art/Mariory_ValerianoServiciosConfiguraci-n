package com.practica.backend.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.practica.backend.model.Producto;
import com.practica.backend.repository.ProductoRepository;

import jakarta.validation.Valid;

/**
 * Controlador REST para gestionar productos
 * 
 * Endpoints:
 * - GET /api/health - Verificar estado del servicio y conexión a MongoDB
 * - GET /api/productos - Obtener todos los productos
 * - POST /api/productos - Crear un nuevo producto
 * - GET /api/productos/{id} - Obtener producto por ID
 * - DELETE /api/productos/{id} - Eliminar producto por ID
 */
@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ProductoController {

    @Autowired
    private ProductoRepository productoRepository;

    @Value("${DB_HOST:unknown}")
    private String dbHost;

    @Value("${DB_NAME:unknown}")
    private String dbName;

    /**
     * Endpoint de health check
     * Verifica que la aplicación está funcionando y puede conectarse a MongoDB
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Intentar contar documentos para verificar conexión a MongoDB
            long count = productoRepository.count();
            
            response.put("status", "UP");
            response.put("message", "Backend funcionando correctamente");
            response.put("database", "MongoDB");
            response.put("db_host", dbHost);
            response.put("db_name", dbName);
            response.put("db_connection", "OK");
            response.put("productos_count", count);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("status", "DOWN");
            response.put("message", "Backend funcionando pero error en MongoDB");
            response.put("database", "MongoDB");
            response.put("db_host", dbHost);
            response.put("db_name", dbName);
            response.put("db_connection", "ERROR");
            response.put("error", e.getMessage());
            
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
        }
    }

    /**
     * Obtener todos los productos
     */
    @GetMapping("/productos")
    public ResponseEntity<Map<String, Object>> getAllProductos() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Producto> productos = productoRepository.findAll();
            response.put("success", true);
            response.put("count", productos.size());
            response.put("productos", productos);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener productos");
            response.put("error", e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * Crear un nuevo producto
     */
    @PostMapping("/productos")
    public ResponseEntity<Map<String, Object>> createProducto(@Valid @RequestBody Producto producto) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Producto nuevoProducto = productoRepository.save(producto);
            response.put("success", true);
            response.put("message", "Producto creado exitosamente");
            response.put("producto", nuevoProducto);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al crear producto");
            response.put("error", e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * Obtener producto por ID
     */
    @GetMapping("/productos/{id}")
    public ResponseEntity<Map<String, Object>> getProductoById(@PathVariable String id) {
        Map<String, Object> response = new HashMap<>();
        
        return productoRepository.findById(id)
            .map(producto -> {
                response.put("success", true);
                response.put("producto", producto);
                return ResponseEntity.ok(response);
            })
            .orElseGet(() -> {
                response.put("success", false);
                response.put("message", "Producto no encontrado");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            });
    }

    /**
     * Eliminar producto por ID
     */
    @DeleteMapping("/productos/{id}")
    public ResponseEntity<Map<String, Object>> deleteProducto(@PathVariable String id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (productoRepository.existsById(id)) {
                productoRepository.deleteById(id);
                response.put("success", true);
                response.put("message", "Producto eliminado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Producto no encontrado");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al eliminar producto");
            response.put("error", e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
