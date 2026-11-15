# S08 | AP6 - Exposición de Servicios y Configuración Segura en Minikube

## 📋 Descripción del Proyecto

Este proyecto implementa una arquitectura de microservicios utilizando **Spring Boot** y **MongoDB**, desplegada en **Minikube** (Kubernetes local). La aplicación demuestra el uso de ConfigMaps y Secrets para gestionar la configuración de forma segura, así como la exposición de servicios mediante NodePort.

## 🎯 Objetivos

- ✅ Desplegar una aplicación Spring Boot en Kubernetes
- ✅ Configurar MongoDB con persistencia de datos
- ✅ Utilizar ConfigMaps para configuración no sensible
- ✅ Utilizar Secrets para credenciales sensibles
- ✅ Exponer servicios mediante NodePort
- ✅ Implementar health checks y probes
- ✅ Demostrar inyección de variables de entorno
- ✅ Implementar una API REST funcional con MongoDB

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────┐
│            MINIKUBE CLUSTER                      │
│  ┌──────────────────────────────────────────┐  │
│  │      Namespace: practica-s08              │  │
│  │                                            │  │
│  │  ┌────────────────┐  ┌─────────────────┐ │  │
│  │  │  ConfigMap     │  │    Secret       │ │  │
│  │  │  (app-config)  │  │  (db-secret)    │ │  │
│  │  └────────┬───────┘  └────────┬────────┘ │  │
│  │           │                   │           │  │
│  │           ├───────────────────┤           │  │
│  │           ▼                   ▼           │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │     Backend Deployment              │ │  │
│  │  │   (Spring Boot - 2 replicas)        │ │  │
│  │  │   - Port: 8080                      │ │  │
│  │  └──────────────┬──────────────────────┘ │  │
│  │                 │                         │  │
│  │                 ▼                         │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │     Backend Service (NodePort)      │ │  │
│  │  │   - Port: 8080                      │ │  │
│  │  │   - NodePort: 30080                 │ │  │
│  │  └──────────────┬──────────────────────┘ │  │
│  │                 │                         │  │
│  │                 │  Acceso externo         │  │
│  │                 │  mediante NodePort      │  │
│  │                 │                         │  │
│  │  ┌──────────────┴──────────────────────┐ │  │
│  │  │     MongoDB Deployment              │ │  │
│  │  │   - Port: 27017                     │ │  │
│  │  │   - PersistentVolumeClaim: 1Gi      │ │  │
│  │  └──────────────┬──────────────────────┘ │  │
│  │                 │                         │  │
│  │                 ▼                         │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │  MongoDB Service (ClusterIP)        │ │  │
│  │  │  - Port: 27017 (interno)            │ │  │
│  │  └─────────────────────────────────────┘ │  │
│  └────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────┘
```

### Flujo de Datos

1. **ConfigMap y Secret** inyectan variables de entorno en el Backend
2. **Backend** se conecta a **MongoDB** usando el servicio interno (`mongo-service`)
3. **MongoDB** almacena datos en un **PersistentVolume**
4. **Backend Service (NodePort)** expone la API al exterior en el puerto 30080
5. Los usuarios acceden a la API mediante la URL de Minikube

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| Java | 17 | Lenguaje de programación |
| Spring Boot | 3.2.0 | Framework para el Backend |
| Maven | 3.9+ | Gestión de dependencias |
| MongoDB | 7.0 | Base de datos NoSQL |
| Docker Desktop | Latest | Entorno de contenedores |
| Minikube | Latest | Kubernetes local |
| Kubernetes | 1.28+ | Orquestación de contenedores |

## 📁 Estructura del Repositorio

```
S08-AP6-Minikube/
│
├── k8s/                                    # Manifiestos de Kubernetes
│   ├── 01-app-configmap.yaml             # ConfigMap con configuración
│   ├── 02-db-secret.yaml                 # Secret con credenciales
│   ├── 03-mongo-stack.yaml               # MongoDB Deployment + Service + PVC
│   └── 04-backend-stack.yaml             # Backend Deployment + Service
│
├── src/                                   # Código fuente de Spring Boot
│   ├── main/
│   │   ├── java/com/practica/backend/
│   │   │   ├── BackendPracticaApplication.java    # Clase principal
│   │   │   ├── config/
│   │   │   │   └── MongoConfig.java               # Configuración de MongoDB
│   │   │   ├── controller/
│   │   │   │   └── ProductoController.java        # API REST
│   │   │   ├── model/
│   │   │   │   └── Producto.java                  # Modelo de datos
│   │   │   └── repository/
│   │   │       └── ProductoRepository.java        # Repository MongoDB
│   │   └── resources/
│   │       └── application.properties             # Configuración Spring
│
├── Dockerfile                             # Construcción de imagen Docker
├── .dockerignore                          # Archivos a ignorar por Docker
├── .gitignore                             # Archivos a ignorar por Git
├── pom.xml                                # Dependencias Maven
└── README.md                              # Este archivo
```

## 📦 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

1. **Docker Desktop** (con soporte de Kubernetes habilitado)
2. **Minikube** 
3. **kubectl**
4. **Maven** (opcional, si deseas compilar localmente)
5. **Git**

### Verificar Instalación

```powershell
# Verificar Docker
docker --version

# Verificar Minikube
minikube version

# Verificar kubectl
kubectl version --client

# Verificar Maven (opcional)
mvn --version
```

## 🚀 Guía de Despliegue Paso a Paso

### Paso 1: Clonar el Repositorio

```powershell
git clone <URL_DEL_REPOSITORIO>
cd S08-AP6-Minikube
```

### Paso 2: Iniciar Docker Desktop

Asegúrate de que Docker Desktop esté ejecutándose en segundo plano.

### Paso 3: Iniciar Minikube

```powershell
# Iniciar Minikube con Docker como driver
minikube start --driver=docker

# Verificar que Minikube está funcionando
minikube status
```

**Salida esperada:**
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Paso 4: Crear el Namespace

```powershell
# Crear namespace para la práctica
kubectl create namespace practica-s08

# Verificar que se creó correctamente
kubectl get namespaces
```

### Paso 5: Construir la Imagen Docker

```powershell
# Configurar el entorno Docker de Minikube (muy importante)
minikube docker-env | Invoke-Expression

# Construir la imagen Docker
docker build -t backend-practica:1.0 .

# Verificar que la imagen se construyó correctamente
docker images | Select-String "backend-practica"
```

**Nota:** El comando `minikube docker-env` configura tu terminal para usar el daemon de Docker dentro de Minikube, permitiendo que las imágenes estén disponibles directamente en el clúster.

### Paso 6: Desplegar ConfigMap

```powershell
# Aplicar el ConfigMap
kubectl apply -f k8s/01-app-configmap.yaml

# Verificar el ConfigMap
kubectl get configmap -n practica-s08
kubectl describe configmap app-configmap -n practica-s08
```

### Paso 7: Desplegar Secret

```powershell
# Aplicar el Secret
kubectl apply -f k8s/02-db-secret.yaml

# Verificar el Secret
kubectl get secret -n practica-s08
kubectl describe secret db-secret -n practica-s08
```

**Nota de Seguridad:** Los valores en el Secret están codificados en Base64:
- Usuario: `adminpractica`
- Contraseña: `practica2024`

Para verificar los valores (solo para desarrollo):
```powershell
# Decodificar el usuario
kubectl get secret db-secret -n practica-s08 -o jsonpath="{.data.DB_USER}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

# Decodificar la contraseña
kubectl get secret db-secret -n practica-s08 -o jsonpath="{.data.DB_PASS}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

### Paso 8: Desplegar MongoDB

```powershell
# Aplicar el stack de MongoDB (PVC + Deployment + Service)
kubectl apply -f k8s/03-mongo-stack.yaml

# Verificar el despliegue de MongoDB
kubectl get pods -n practica-s08 -l app=mongodb
kubectl get svc -n practica-s08 -l app=mongodb
kubectl get pvc -n practica-s08
```

**Esperar a que MongoDB esté listo:**
```powershell
# Ver logs de MongoDB
kubectl logs -n practica-s08 -l app=mongodb --tail=50

# Esperar hasta que el pod esté en estado Running
kubectl wait --for=condition=ready pod -l app=mongodb -n practica-s08 --timeout=120s
```

### Paso 9: Desplegar el Backend

```powershell
# Aplicar el stack del Backend (Deployment + Service)
kubectl apply -f k8s/04-backend-stack.yaml

# Verificar el despliegue del Backend
kubectl get pods -n practica-s08 -l app=backend
kubectl get svc -n practica-s08 -l app=backend
```

**Esperar a que el Backend esté listo:**
```powershell
# Ver logs del Backend
kubectl logs -n practica-s08 -l app=backend --tail=100

# Esperar hasta que los pods estén en estado Running
kubectl wait --for=condition=ready pod -l app=backend -n practica-s08 --timeout=180s
```

### Paso 10: Verificar el Estado del Clúster

**EVIDENCIA 1: Estado del Clúster**

```powershell
kubectl get pods,svc,configmaps,secrets -n practica-s08
```

**Salida esperada:**
```
NAME                                      READY   STATUS    RESTARTS   AGE
pod/backend-deployment-xxxxx-xxxxx        1/1     Running   0          2m
pod/backend-deployment-xxxxx-xxxxx        1/1     Running   0          2m
pod/mongo-deployment-xxxxx-xxxxx          1/1     Running   0          3m

NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/backend-service   NodePort    10.xxx.xxx.xxx   <none>        8080:30080/TCP   2m
service/mongo-service     ClusterIP   10.xxx.xxx.xxx   <none>        27017/TCP        3m

NAME                         DATA   AGE
configmap/app-configmap      3      5m

NAME                     TYPE     DATA   AGE
secret/db-secret         Opaque   2      4m
```

### Paso 11: Verificar Inyección de Variables

**EVIDENCIA 2: Inyección de Variables de Entorno**

```powershell
# Obtener el nombre de un pod del backend
$podName = kubectl get pods -n practica-s08 -l app=backend -o jsonpath="{.items[0].metadata.name}"

# Ver todas las variables de entorno
kubectl exec -it $podName -n practica-s08 -- env | Select-String "DB_|APP_"
```

**Salida esperada:**
```
DB_HOST=mongo-service
DB_NAME=practica_db
DB_USER=adminpractica
DB_PASS=practica2024
APP_PORT=8080
```

### Paso 12: Obtener la URL de Acceso

**EVIDENCIA 3: Exposición Externa mediante NodePort**

```powershell
# Obtener la URL del servicio
minikube service backend-service -n practica-s08 --url
```

**Salida esperada:**
```
http://127.0.0.1:xxxxx
```

**Nota:** Minikube crea un túnel para acceder al NodePort desde tu máquina local.

También puedes usar:
```powershell
# Abrir el servicio directamente en el navegador
minikube service backend-service -n practica-s08
```

### Paso 13: Probar los Endpoints de la API

Una vez obtenida la URL (por ejemplo: `http://127.0.0.1:51234`), prueba los siguientes endpoints:

#### 1. Health Check

```powershell
# Verificar que la aplicación está funcionando
curl http://127.0.0.1:PUERTO/api/health
```

**Respuesta esperada:**
```json
{
  "status": "UP",
  "message": "Backend funcionando correctamente",
  "database": "MongoDB",
  "db_host": "mongo-service",
  "db_name": "practica_db",
  "db_connection": "OK",
  "productos_count": 0
}
```

#### 2. Listar Productos (GET)

```powershell
curl http://127.0.0.1:PUERTO/api/productos
```

**Respuesta esperada:**
```json
{
  "success": true,
  "count": 0,
  "productos": []
}
```

#### 3. Crear Producto (POST)

```powershell
# Crear un producto de prueba
curl -X POST http://127.0.0.1:PUERTO/api/productos `
  -H "Content-Type: application/json" `
  -d '{\"nombre\":\"Laptop\",\"descripcion\":\"Laptop gaming\",\"precio\":1500.00,\"disponible\":true}'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Producto creado exitosamente",
  "producto": {
    "id": "6563a1b2c3d4e5f6a7b8c9d0",
    "nombre": "Laptop",
    "descripcion": "Laptop gaming",
    "precio": 1500.0,
    "disponible": true
  }
}
```

#### 4. Verificar que el Producto se Guardó

```powershell
curl http://127.0.0.1:PUERTO/api/productos
```

**Respuesta esperada:**
```json
{
  "success": true,
  "count": 1,
  "productos": [
    {
      "id": "6563a1b2c3d4e5f6a7b8c9d0",
      "nombre": "Laptop",
      "descripcion": "Laptop gaming",
      "precio": 1500.0,
      "disponible": true
    }
  ]
}
```

### Pruebas desde el Navegador

También puedes acceder directamente desde el navegador:

- **Health Check:** `http://127.0.0.1:PUERTO/api/health`
- **Listar Productos:** `http://127.0.0.1:PUERTO/api/productos`

Para crear productos, puedes usar herramientas como **Postman** o **Thunder Client** (extensión de VS Code).

## 🔍 Comandos de Verificación Útiles

### Ver Logs

```powershell
# Logs del Backend
kubectl logs -n practica-s08 -l app=backend --tail=100 -f

# Logs de MongoDB
kubectl logs -n practica-s08 -l app=mongodb --tail=100 -f

# Logs de un pod específico
kubectl logs -n practica-s08 POD_NAME
```

### Inspeccionar Recursos

```powershell
# Describir un pod
kubectl describe pod POD_NAME -n practica-s08

# Describir el servicio del backend
kubectl describe svc backend-service -n practica-s08

# Describir el ConfigMap
kubectl describe configmap app-configmap -n practica-s08

# Describir el Secret
kubectl describe secret db-secret -n practica-s08
```

### Ejecutar Comandos dentro de un Pod

```powershell
# Acceder al shell del Backend
kubectl exec -it POD_NAME -n practica-s08 -- /bin/sh

# Acceder al shell de MongoDB
kubectl exec -it MONGO_POD_NAME -n practica-s08 -- mongosh -u adminpractica -p practica2024
```

### Verificar Conectividad

```powershell
# Desde el Backend, hacer ping a MongoDB
kubectl exec -it BACKEND_POD_NAME -n practica-s08 -- ping mongo-service
```

## 🧹 Limpieza y Eliminación

Para eliminar todos los recursos creados:

```powershell
# Eliminar todos los recursos del namespace
kubectl delete namespace practica-s08

# Verificar que se eliminó
kubectl get namespaces
```

Para detener Minikube:

```powershell
minikube stop
```

Para eliminar completamente el clúster de Minikube:

```powershell
minikube delete
```

## 🔒 Seguridad y Buenas Prácticas

### Implementadas en este Proyecto

✅ **Secrets para Credenciales:** Las credenciales de MongoDB se almacenan en un Secret de Kubernetes, no en el código fuente.

✅ **ConfigMaps para Configuración:** La configuración no sensible se gestiona mediante ConfigMaps.

✅ **MongoDB como ClusterIP:** MongoDB solo es accesible internamente, no está expuesto al exterior.

✅ **Usuario No Privilegiado:** El contenedor del Backend se ejecuta con un usuario no privilegiado.

✅ **Health Checks:** Implementación de `readinessProbe` y `livenessProbe` para monitoreo.

✅ **Persistencia de Datos:** MongoDB utiliza un PersistentVolumeClaim para no perder datos.

✅ **Resource Limits:** Definición de límites de CPU y memoria para evitar consumo excesivo.

### Recomendaciones para Producción

🔐 **Gestión de Secrets:** Utilizar herramientas como HashiCorp Vault, AWS Secrets Manager, o Sealed Secrets.

🔐 **TLS/HTTPS:** Implementar certificados SSL/TLS para comunicaciones seguras.

🔐 **Network Policies:** Definir políticas de red para controlar el tráfico entre pods.

🔐 **RBAC:** Configurar control de acceso basado en roles.

🔐 **Backup de MongoDB:** Implementar estrategias de respaldo periódico.

🔐 **Monitoreo:** Integrar herramientas como Prometheus y Grafana.

## 🐛 Solución de Problemas Comunes

### Problema 1: El Backend no puede conectarse a MongoDB

**Síntoma:** Logs del Backend muestran errores de conexión a MongoDB.

**Solución:**
1. Verificar que MongoDB está en estado `Running`:
   ```powershell
   kubectl get pods -n practica-s08 -l app=mongodb
   ```
2. Verificar que el servicio `mongo-service` existe:
   ```powershell
   kubectl get svc mongo-service -n practica-s08
   ```
3. Verificar las credenciales en el Secret:
   ```powershell
   kubectl describe secret db-secret -n practica-s08
   ```

### Problema 2: La imagen Docker no se encuentra en Minikube

**Síntoma:** El pod del Backend muestra `ImagePullBackOff` o `ErrImagePull`.

**Solución:**
1. Asegurarse de ejecutar `minikube docker-env` antes de construir:
   ```powershell
   minikube docker-env | Invoke-Expression
   docker build -t backend-practica:1.0 .
   ```
2. Verificar que `imagePullPolicy: Never` está configurado en el Deployment.

### Problema 3: No se puede acceder al NodePort

**Síntoma:** No se puede acceder a `http://127.0.0.1:30080`.

**Solución:**
1. Usar el comando de Minikube para obtener la URL correcta:
   ```powershell
   minikube service backend-service -n practica-s08 --url
   ```
2. Verificar que el servicio está en estado activo:
   ```powershell
   kubectl get svc backend-service -n practica-s08
   ```

### Problema 4: MongoDB no inicia correctamente

**Síntoma:** El pod de MongoDB está en estado `CrashLoopBackOff`.

**Solución:**
1. Ver los logs para identificar el error:
   ```powershell
   kubectl logs -n practica-s08 -l app=mongodb --tail=100
   ```
2. Verificar que el PersistentVolumeClaim se creó correctamente:
   ```powershell
   kubectl get pvc -n practica-s08
   ```

## 📊 Validación de la Actividad (Rúbrica)

Para cumplir con los 20 puntos de la rúbrica de la práctica S08 | AP6, asegúrate de demostrar:

### 1. Despliegue Correcto (5 puntos)
- ✅ Todos los pods en estado `Running`
- ✅ Servicios configurados correctamente
- ✅ ConfigMap y Secret aplicados

**Comando de verificación:**
```powershell
kubectl get pods,svc,configmaps,secrets -n practica-s08
```

### 2. Configuración mediante ConfigMap y Secret (5 puntos)
- ✅ Variables de entorno inyectadas desde ConfigMap
- ✅ Credenciales inyectadas desde Secret
- ✅ Backend consume correctamente las variables

**Comando de verificación:**
```powershell
kubectl exec -it BACKEND_POD -n practica-s08 -- env | Select-String "DB_|APP_"
```

### 3. Exposición Externa (5 puntos)
- ✅ Backend expuesto mediante NodePort
- ✅ Acceso funcional desde el navegador
- ✅ API REST responde correctamente

**Comando de verificación:**
```powershell
minikube service backend-service -n practica-s08 --url
curl http://URL_OBTENIDA/api/health
```

### 4. Funcionalidad y Buenas Prácticas (5 puntos)
- ✅ MongoDB con persistencia (PVC)
- ✅ Health checks implementados
- ✅ Documentación completa
- ✅ Código limpio y comentado

## 📚 Referencias y Recursos

- [Documentación oficial de Kubernetes](https://kubernetes.io/docs/)
- [Documentación de Spring Boot](https://spring.io/projects/spring-boot)
- [Documentación de MongoDB](https://www.mongodb.com/docs/)
- [Guía de Minikube](https://minikube.sigs.k8s.io/docs/)
- [ConfigMaps en Kubernetes](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets en Kubernetes](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Services en Kubernetes](https://kubernetes.io/docs/concepts/services-networking/service/)

## 👨‍💻 Autor

**Proyecto Académico S08 | AP6**

Práctica de Exposición de Servicios y Configuración Segura en Minikube

---

## 📝 Notas Finales

- Este proyecto está diseñado con fines **educativos** para la actividad S08 | AP6.
- Las credenciales utilizadas son de **prueba** y no deben usarse en entornos de producción.
- La arquitectura implementada sigue las mejores prácticas de Kubernetes para ambientes de desarrollo.
- Se recomienda explorar y modificar el código para comprender mejor cada componente.

## ✅ Checklist de Entrega

Antes de entregar la práctica, verificar:

- [ ] Todos los archivos YAML están creados y comentados
- [ ] El código fuente de Spring Boot es funcional
- [ ] El Dockerfile construye correctamente la imagen
- [ ] Los comandos del README son ejecutables en PowerShell
- [ ] Los tres tipos de evidencia se pueden generar exitosamente
- [ ] La aplicación responde correctamente a las peticiones HTTP
- [ ] MongoDB almacena y recupera datos correctamente
- [ ] La documentación está completa y clara
- [ ] El repositorio está limpio (sin archivos temporales o credenciales reales)

---

**¡Éxito en tu práctica! 🚀**
