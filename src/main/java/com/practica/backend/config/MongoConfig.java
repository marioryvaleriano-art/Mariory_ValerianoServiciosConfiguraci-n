package com.practica.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.AbstractMongoClientConfiguration;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;

/**
 * Configuración de MongoDB
 * 
 * Construye la URI de conexión utilizando variables de entorno
 * obtenidas desde ConfigMap y Secret de Kubernetes
 */
@Configuration
@EnableMongoRepositories(basePackages = "com.practica.backend.repository")
public class MongoConfig extends AbstractMongoClientConfiguration {

    @Value("${DB_HOST:localhost}")
    private String dbHost;

    @Value("${DB_NAME:practica_db}")
    private String dbName;

    @Value("${DB_USER:admin}")
    private String dbUser;

    @Value("${DB_PASS:password}")
    private String dbPass;

    @Override
    protected String getDatabaseName() {
        return dbName;
    }

    @Override
    public MongoClient mongoClient() {
        // Construir URI de conexión con autenticación
        String connectionString = String.format(
            "mongodb://%s:%s@%s:27017/%s?authSource=admin",
            dbUser, dbPass, dbHost, dbName
        );
        
        MongoClientSettings mongoClientSettings = MongoClientSettings.builder()
            .applyConnectionString(new ConnectionString(connectionString))
            .build();
        
        return MongoClients.create(mongoClientSettings);
    }
}
