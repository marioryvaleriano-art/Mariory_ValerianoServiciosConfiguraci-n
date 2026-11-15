# 🏗️ Arquitectura Detallada - S08 | AP6

## Visión General

Este documento proporciona una explicación detallada de la arquitectura del proyecto, las decisiones de diseño y cómo cada componente interactúa con los demás.

---

## 1. Diagrama de Arquitectura Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USUARIO FINAL                                │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  │ HTTP Request
                                  │ (desde navegador/curl)
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          MINIKUBE                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │              NAMESPACE: practica-s08                          │ │
│  │                                                                │ │
│  │  ┌─────────────────┐          ┌────────────────────┐         │ │
│  │  │  app-configmap  │          │    db-secret       │         │ │
│  │  │  ============   │          │   ===========      │         │ │
│  │  │  DB_HOST        │          │   DB_USER (Base64) │         │ │
│  │  │  DB_NAME        │          │   DB_PASS (Base64) │         │ │
│  │  │  APP_PORT       │          │                    │         │ │
│  │  └────────┬────────┘          └──────────┬─────────┘         │ │
│  │           │                              │                    │ │
│  │           └──────────┬───────────────────┘                    │ │
│  │                      │ envFrom                                │ │
│  │                      ▼                                        │ │
│  │  ┌──────────────────────────────────────────────┐            │ │
│  │  │       backend-deployment (2 replicas)        │            │ │
│  │  │  ┌────────────┐          ┌────────────┐      │            │ │
│  │  │  │  Pod 1     │          │  Pod 2     │      │            │ │
│  │  │  │ Backend    │          │ Backend    │      │            │ │
│  │  │  │ Spring Boot│          │ Spring Boot│      │            │ │
│  │  │  │ Port: 8080 │          │ Port: 8080 │      │            │ │
│  │  │  └────────────┘          └────────────┘      │            │ │
│  │  │         │                        │            │            │ │
│  │  │         └────────┬───────────────┘            │            │ │
│  │  └──────────────────┼──────────────────────────┘             │ │
│  │                     │                                         │ │
│  │                     ▼                                         │ │
│  │  ┌────────────────────────────────────┐                      │ │
│  │  │      backend-service (NodePort)     │                      │ │
│  │  │      Port: 8080 → NodePort: 30080  │                      │ │
│  │  └─────────────────┬────────────────────┘                    │ │
│  │                    │                                          │ │
│  │                    │ Comunicación interna                     │ │
│  │                    │ (ClusterIP)                              │ │
│  │                    │                                          │ │
│  │                    ▼                                          │ │
│  │  ┌─────────────────────────────────────┐                     │ │
│  │  │      mongo-service (ClusterIP)      │                     │ │
│  │  │           Port: 27017               │                     │ │
│  │  └──────────────────┬──────────────────┘                     │ │
│  │                     │                                         │ │
│  │                     ▼                                         │ │
│  │  ┌─────────────────────────────────────┐                     │ │
│  │  │       mongo-deployment              │                     │ │
│  │  │  ┌──────────────────────────────┐   │                     │ │
│  │  │  │  MongoDB Pod                 │   │                     │ │
│  │  │  │  - MongoDB 7.0               │   │                     │ │
│  │  │  │  - Port: 27017               │   │                     │ │
│  │  │  │  - Auth: admin credentials   │   │                     │ │
│  │  │  └──────────────┬───────────────┘   │                     │ │
│  │  │                 │                    │                     │ │
│  │  │                 ▼                    │                     │ │
│  │  │  ┌──────────────────────────────┐   │                     │ │
│  │  │  │  PersistentVolume            │   │                     │ │
│  │  │  │  /data/db (1Gi)              │   │                     │ │
│  │  │  └──────────────────────────────┘   │                     │ │
│  │  └─────────────────────────────────────┘                     │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Componentes Principales

### 2.1 ConfigMap (app-configmap)

**Propósito:** Almacenar configuración no sensible que puede cambiar entre entornos.

**Contenido:**
- `DB_HOST`: Nombre del servicio de MongoDB dentro del clúster
- `DB_NAME`: Nombre de la base de datos a utilizar
- `APP_PORT`: Puerto en el que la aplicación Spring Boot escucha

**Razones de diseño:**
- Separar configuración del código
- Facilitar cambios sin reconstruir la imagen
- Transparencia: valores visibles para debugging

### 2.2 Secret (db-secret)

**Propósito:** Almacenar credenciales sensibles de forma segura.

**Contenido:**
- `DB_USER`: Usuario de MongoDB (codificado en Base64)
- `DB_PASS`: Contraseña de MongoDB (codificado en Base64)

**Razones de diseño:**
- Seguridad: no exponer credenciales en el código o ConfigMap
- Kubernetes maneja Secrets con protecciones adicionales
- Facilita rotación de credenciales

**Nota de seguridad:**
- Base64 NO es encriptación, solo codificación
- En producción usar: Sealed Secrets, Vault, o servicios cloud de gestión de secretos

### 2.3 MongoDB Stack

#### 2.3.1 PersistentVolumeClaim (mongo-pvc)

**Propósito:** Solicitar almacenamiento persistente para los datos de MongoDB.

**Especificaciones:**
- Tamaño: 1Gi
- Access Mode: ReadWriteOnce
- Storage Class: default (provisto por Minikube)

**Razones de diseño:**
- Persistencia: datos no se pierden al reiniciar pods
- Separación de concerns: el pod no maneja el ciclo de vida del almacenamiento

#### 2.3.2 MongoDB Deployment

**Propósito:** Desplegar y mantener MongoDB funcionando.

**Especificaciones:**
- Replicas: 1 (suficiente para desarrollo)
- Imagen: mongo:7.0 (versión estable y reciente)
- Puerto: 27017 (puerto estándar de MongoDB)

**Variables de entorno:**
- `MONGO_INITDB_ROOT_USERNAME`: Usuario administrador inicial
- `MONGO_INITDB_ROOT_PASSWORD`: Contraseña del administrador

**Probes:**
- **Liveness:** Verifica que MongoDB responde (`db.adminCommand('ping')`)
- **Readiness:** Verifica que MongoDB está listo para conexiones

**Resource Limits:**
- Memory: 512Mi (límite) / 256Mi (request)
- CPU: 500m (límite) / 250m (request)

**Razones de diseño:**
- Probes aseguran alta disponibilidad
- Resource limits previenen consumo excesivo
- Persistencia garantiza durabilidad de datos

#### 2.3.3 MongoDB Service (ClusterIP)

**Propósito:** Proporcionar un punto de acceso estable para MongoDB dentro del clúster.

**Especificaciones:**
- Tipo: ClusterIP (solo accesible internamente)
- Nombre: mongo-service
- Puerto: 27017

**Razones de diseño:**
- ClusterIP: MongoDB no debe ser accesible desde fuera del clúster
- Nombre estable: los pods pueden conectarse usando `mongo-service` sin importar la IP
- Seguridad: minimiza superficie de ataque

### 2.4 Backend Stack

#### 2.4.1 Backend Deployment

**Propósito:** Desplegar la aplicación Spring Boot que expone la API REST.

**Especificaciones:**
- Replicas: 2 (alta disponibilidad, balanceo de carga)
- Imagen: backend-practica:1.0 (construida localmente)
- imagePullPolicy: Never (usa la imagen local de Minikube)
- Puerto: 8080

**Inyección de configuración:**
```yaml
envFrom:
- configMapRef:
    name: app-configmap  # Inyecta DB_HOST, DB_NAME, APP_PORT
- secretRef:
    name: db-secret      # Inyecta DB_USER, DB_PASS
```

**Probes:**
- **Readiness:** GET /api/health (verifica que el backend está listo)
  - initialDelaySeconds: 30 (tiempo para iniciar Spring Boot)
  - periodSeconds: 10
- **Liveness:** GET /api/health (verifica que el backend está funcionando)
  - initialDelaySeconds: 60
  - periodSeconds: 15

**Resource Limits:**
- Memory: 512Mi (límite) / 256Mi (request)
- CPU: 500m (límite) / 250m (request)

**Razones de diseño:**
- 2 replicas: tolerancia a fallos, si un pod falla el otro responde
- Probes: Kubernetes reinicia pods automáticamente si fallan
- envFrom: inyección limpia sin hardcodear configuración
- Resource limits: previene que un pod consuma todos los recursos

#### 2.4.2 Backend Service (NodePort)

**Propósito:** Exponer el backend al exterior del clúster para acceso desde el navegador.

**Especificaciones:**
- Tipo: NodePort
- Puerto interno: 8080
- NodePort: 30080
- Protocolo: TCP

**Razones de diseño:**
- NodePort: permite acceso externo en entornos de desarrollo/test
- Puerto 30080: está en el rango permitido por Kubernetes (30000-32767)
- Balanceo de carga: distribuye tráfico entre las 2 réplicas del backend

**Alternativas (para producción):**
- LoadBalancer: en clouds públicos (AWS ELB, GCP LB)
- Ingress: para routing HTTP avanzado con nombres de dominio

---

## 3. Flujo de Datos

### 3.1 Flujo de Configuración (Startup)

```
1. Kubernetes lee ConfigMap y Secret
                    │
                    ▼
2. Deployment del Backend crea pods
                    │
                    ▼
3. Pods reciben variables de entorno desde ConfigMap y Secret
                    │
                    ▼
4. Spring Boot inicia y construye la URI de MongoDB
   URI = mongodb://DB_USER:DB_PASS@DB_HOST:27017/DB_NAME?authSource=admin
                    │
                    ▼
5. Backend se conecta a MongoDB usando el Service (mongo-service)
                    │
                    ▼
6. Readiness probe valida que el backend está listo
                    │
                    ▼
7. Service (NodePort) empieza a enrutar tráfico hacia el backend
```

### 3.2 Flujo de una Petición HTTP

```
Usuario                  Minikube              Backend              MongoDB
  │                         │                     │                    │
  │  GET /api/productos     │                     │                    │
  ├────────────────────────>│                     │                    │
  │                         │                     │                    │
  │                         │  NodePort 30080     │                    │
  │                         ├────────────────────>│                    │
  │                         │                     │                    │
  │                         │                     │ find all productos │
  │                         │                     ├───────────────────>│
  │                         │                     │                    │
  │                         │                     │   List<Producto>   │
  │                         │                     │<───────────────────┤
  │                         │                     │                    │
  │                         │   JSON Response     │                    │
  │                         │<────────────────────┤                    │
  │                         │                     │                    │
  │   JSON Response         │                     │                    │
  │<────────────────────────┤                     │                    │
  │                         │                     │                    │
```

### 3.3 Flujo de Creación de Producto (POST)

```
Usuario                  Backend                  MongoDB
  │                         │                         │
  │  POST /api/productos    │                         │
  │  {nombre, precio, ...}  │                         │
  ├────────────────────────>│                         │
  │                         │                         │
  │                         │  1. Validar datos       │
  │                         │     (@Valid)            │
  │                         │                         │
  │                         │  2. Save producto       │
  │                         ├────────────────────────>│
  │                         │                         │
  │                         │     3. MongoDB genera   │
  │                         │        ObjectId y       │
  │                         │        guarda documento │
  │                         │                         │
  │                         │  4. Producto guardado   │
  │                         │<────────────────────────┤
  │                         │                         │
  │  5. Response 201        │                         │
  │     {success, producto} │                         │
  │<────────────────────────┤                         │
  │                         │                         │
```

---

## 4. Decisiones de Arquitectura

### 4.1 ¿Por qué Spring Boot?

**Ventajas:**
- Framework maduro y ampliamente adoptado
- Configuración mínima con Spring Boot Starter
- Integración nativa con MongoDB mediante Spring Data
- Servidor embebido (Tomcat) elimina necesidad de servidor externo
- Amplia comunidad y documentación

### 4.2 ¿Por qué MongoDB?

**Ventajas:**
- NoSQL: esquema flexible, ideal para desarrollo ágil
- JSON nativo: fácil integración con REST APIs
- Imagen oficial de Docker bien mantenida
- Fácil de desplegar en Kubernetes

**Alternativas consideradas:**
- PostgreSQL: más estructura, mejor para datos relacionales
- MySQL: similar a PostgreSQL
- Redis: bueno para cache, menos apropiado como DB principal

### 4.3 ¿Por qué 2 Réplicas del Backend?

**Ventajas:**
- Alta disponibilidad: si un pod falla, el otro sigue funcionando
- Balanceo de carga: distribuye tráfico
- Rolling updates: permite actualizaciones sin downtime

**Desventaja:**
- Mayor consumo de recursos (aceptable para desarrollo)

**Alternativa:**
- 1 réplica: suficiente para desarrollo local simple

### 4.4 ¿Por qué NodePort en lugar de LoadBalancer?

**Razón:**
- LoadBalancer requiere integración con proveedor cloud (AWS, GCP, Azure)
- Minikube no proporciona LoadBalancer nativo
- NodePort es suficiente para desarrollo y pruebas locales

**Para producción:**
- Usar LoadBalancer en clouds públicos
- Usar Ingress para routing HTTP avanzado

### 4.5 ¿Por qué PersistentVolume para MongoDB?

**Razón:**
- Sin persistencia, los datos se pierden al reiniciar el pod
- En un entorno de práctica, perder datos es frustrante
- Simula mejor un entorno de producción real

**Alternativa:**
- emptyDir: volumen efímero (datos se pierden al eliminar pod)

---

## 5. Seguridad

### 5.1 Capas de Seguridad Implementadas

#### Capa 1: Network
- MongoDB solo accesible mediante ClusterIP (interno)
- Backend expuesto mediante NodePort (controlado)

#### Capa 2: Autenticación
- MongoDB requiere usuario y contraseña
- Credenciales en Secret, no en código

#### Capa 3: Contenedor
- Backend corre con usuario no privilegiado (no root)
- Imagen Alpine reduce superficie de ataque

#### Capa 4: Recursos
- Resource limits previenen DoS por consumo excesivo

### 5.2 Mejoras de Seguridad para Producción

1. **TLS/HTTPS:**
   - Certificados SSL para comunicación encriptada
   - Cert-manager para gestión automática de certificados

2. **Network Policies:**
   - Restringir qué pods pueden comunicarse entre sí
   - Ejemplo: solo el backend puede acceder a MongoDB

3. **RBAC (Role-Based Access Control):**
   - Definir permisos específicos para ServiceAccounts
   - Principio de mínimo privilegio

4. **Secrets Management:**
   - Sealed Secrets (encriptar secretos en Git)
   - HashiCorp Vault (gestión centralizada de secretos)
   - AWS Secrets Manager / Azure Key Vault

5. **Image Scanning:**
   - Escanear imágenes Docker por vulnerabilidades
   - Herramientas: Trivy, Clair, Snyk

6. **Pod Security Standards:**
   - Policies que imponen restricciones a nivel de pod
   - Ejemplo: no permitir contenedores privilegiados

---

## 6. Escalabilidad

### 6.1 Escalado Horizontal del Backend

**Actual:**
- 2 réplicas (configuradas estáticamente)

**Mejora: Horizontal Pod Autoscaler (HPA)**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: practica-s08
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Efecto:**
- Escala automáticamente entre 2-10 réplicas según uso de CPU

### 6.2 Escalado de MongoDB

**Actual:**
- 1 réplica (suficiente para desarrollo)

**Mejora para producción:**
- MongoDB Replica Set (3+ nodos)
- Proporciona alta disponibilidad y failover automático
- Distribución geográfica para disaster recovery

**Alternativa:**
- MongoDB Atlas (servicio gestionado en cloud)

---

## 7. Monitoreo y Observabilidad

### 7.1 Health Checks Implementados

**Endpoint `/api/health`:**
- Verifica que Spring Boot está funcionando
- Verifica conexión a MongoDB
- Retorna métricas útiles (productos_count, db_connection)

**Probes de Kubernetes:**
- **Liveness:** Reinicia pod si falla
- **Readiness:** Retira pod de balanceo si no está listo

### 7.2 Mejoras para Producción

#### Logging
- **Actual:** Logs a stdout (visibles con `kubectl logs`)
- **Mejora:** Stack ELK (Elasticsearch, Logstash, Kibana)
  - Centralización de logs
  - Búsqueda y análisis avanzado
  - Dashboards de visualización

#### Métricas
- **Actual:** Health endpoint básico
- **Mejora:** Prometheus + Grafana
  - Métricas de sistema (CPU, memoria, disco)
  - Métricas de aplicación (requests/sec, latencia, errores)
  - Alertas automáticas

#### Tracing
- **Mejora:** Jaeger o Zipkin
  - Seguimiento de requests a través de microservicios
  - Identificación de cuellos de botella

---

## 8. CI/CD

### 8.1 Pipeline de CI/CD Propuesto

```
┌──────────────┐
│  Git Push    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  CI: Build   │  ← Maven build, unit tests
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  CI: Test    │  ← Integration tests
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Docker Build │  ← Construir y pushear imagen
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   CD: Dev    │  ← Desplegar a entorno de desarrollo
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  CD: Staging │  ← Desplegar a staging (automático)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Approval   │  ← Aprobación manual
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ CD: Production│ ← Desplegar a producción
└──────────────┘
```

### 8.2 Herramientas

- **CI:** GitHub Actions, GitLab CI, Jenkins
- **CD:** ArgoCD, Flux, Spinnaker
- **Registry:** Docker Hub, AWS ECR, Google Container Registry

---

## 9. Comparación con Alternativas

### 9.1 Alternativa: Docker Compose

**Ventajas:**
- Más simple, menos curva de aprendizaje
- Bueno para desarrollo local
- Archivo único (docker-compose.yml)

**Desventajas:**
- No escala automáticamente
- No tiene self-healing (reinicio automático)
- No tiene balanceo de carga nativo
- No es estándar en producción

### 9.2 Alternativa: Serverless (AWS Lambda + DynamoDB)

**Ventajas:**
- Escalado automático
- Pago por uso
- No gestionar servidores

**Desventajas:**
- Vendor lock-in
- Cold start latency
- Menos control sobre infraestructura
- No apropiado para esta práctica académica

---

## 10. Conclusión

Esta arquitectura logra un balance entre:
- **Simplicidad:** Fácil de entender y desplegar
- **Realismo:** Simula prácticas de producción
- **Educación:** Demuestra conceptos clave de Kubernetes
- **Funcionalidad:** Aplicación completamente operativa

Es una base sólida para aprender Kubernetes y puede evolucionar hacia arquitecturas más complejas conforme se agreguen requisitos.

---

**Documentación creada para la práctica académica S08 | AP6**
