# Dockerfile multi-stage para construir y ejecutar la aplicación Spring Boot
# Optimizado para reducir el tamaño final de la imagen

# Etapa 1: Construcción de la aplicación
FROM maven:3.9-eclipse-temurin-17 AS build

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Maven
COPY pom.xml .

# Descargar dependencias (se cachea si pom.xml no cambia)
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Compilar y empaquetar la aplicación
RUN mvn clean package -DskipTests -B

# Etapa 2: Imagen de ejecución
FROM eclipse-temurin:17-jre-alpine

# Crear usuario no privilegiado para ejecutar la aplicación
RUN addgroup -S spring && adduser -S spring -G spring

# Establecer directorio de trabajo
WORKDIR /app

# Copiar el JAR compilado desde la etapa de construcción
COPY --from=build /app/target/backend-practica.jar app.jar

# Cambiar propiedad del archivo al usuario spring
RUN chown spring:spring app.jar

# Cambiar al usuario no privilegiado
USER spring

# Exponer el puerto de la aplicación
EXPOSE 8080

# Variables de entorno por defecto (se sobrescriben con ConfigMap y Secret)
ENV DB_HOST=localhost \
    DB_NAME=practica_db \
    DB_USER=admin \
    DB_PASS=password \
    APP_PORT=8080

# Configuración de Java
ENV JAVA_OPTS="-Xmx256m -Xms128m"

# Comando para ejecutar la aplicación
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
