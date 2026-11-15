
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
┌─────────────────────────────────────────────────┐ │ MINIKUBE CLUSTER │ │ ┌──────────────────────────────────────────┐ │ │ │ Namespace: practica-s08 │ │ │ │ │ │ │ │ ┌────────────────┐ ┌─────────────────┐ │ │ │ │ │ ConfigMap │ │ Secret │ │ │ │ │ │ (app-config) │ │ (db-secret) │ │ │ │ │ └────────┬───────┘ └────────┬────────┘ │ │ │ │ │ │ │ │ │ │ ├───────────────────┤ │ │ │ │ ▼ ▼ │ │ │ │ ┌─────────────────────────────────────┐ │ │ │ │ │ Backend Deployment │ │ │ │ │ │ (Spring Boot - 2 replicas) │ │ │ │ │ │ - Port: 8080 │ │ │ │ │ └──────────────┬──────────────────────┘ │ │ │ │ │ │ │ │ │ ▼ │ │ │ │ ┌─────────────────────────────────────┐ │ │ │ │ │ Backend Service (NodePort) │ │ │ │ │ │ - Port: 8080 │ │ │ │ │ │ - NodePort: 30080 │ │ │ │ │ └──────────────┬──────────────────────┘ │ │ │ │ │ │ │ │ │ │ Acceso externo │ │ │ │ │ mediante NodePort │ │ │ │ │ │ │ │ │ ┌──────────────┴──────────────────────┐ │ │ │ │ │ MongoDB Deployment │ │ │ │ │ │ - Port: 27017 │ │ │ │ │ │ - PersistentVolumeClaim: 1Gi │ │ │ │ │ └──────────────┬──────────────────────┘ │ │ │ │ │ │ │ │ │ ▼ │ │ │ │ ┌─────────────────────────────────────┐ │ │ │ │ │ MongoDB Service (ClusterIP) │ │ │ │ │ │ - Port: 27017 (interno) │ │ │ │ │ └─────────────────────────────────────┘ │ │ │ └────────────────────────────────────────────┘ │ └───────────────────────────────────────────────────┘



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
S08-AP6-Minikube/ │ ├── k8s/ # Manifiestos de Kubernetes │ ├── 01-app-configmap.yaml # ConfigMap con configuración │ ├── 02-db-secret.yaml # Secret con credenciales │ ├── 03-mongo-stack.yaml # MongoDB Deployment + Service + PVC │ └── 04-backend-stack.yaml # Backend Deployment + Service │ ├── src/ # Código fuente de Spring Boot │ └── main/ │ ├── java/com/practica/backend/ │ │ ├── BackendPracticaApplication.java │ │ ├── config/MongoConfig.java │ │ ├── controller/ProductoController.java │ │ ├── model/Producto.java │ │ └── repository/ProductoRepository.java │ └── resources/ │ └── application.properties │ ├── Dockerfile # Construcción de imagen Docker ├── pom.xml # Dependencias Maven └── README.md # Este archivo



## 🚀 Guía de Despliegue

### Requisitos Previos

- Docker Desktop
- Minikube
- kubectl

### Paso 1: Iniciar Minikube

```powershell
minikube start --driver=docker
minikube status
Paso 2: Crear Namespace
powershell

kubectl create namespace practica-s08
Paso 3: Construir Imagen Docker
powershell

minikube docker-env | Invoke-Expression
docker build -t backend-practica:1.0 .
Paso 4: Desplegar Manifiestos
powershell

kubectl apply -f k8s/01-app-configmap.yaml -n practica-s08
kubectl apply -f k8s/02-db-secret.yaml -n practica-s08
kubectl apply -f k8s/03-mongo-stack.yaml -n practica-s08
kubectl apply -f k8s/04-backend-stack.yaml -n practica-s08
Paso 5: Verificar Despliegue
powershell

kubectl get pods,svc -n practica-s08
Paso 6: Obtener URL de Acceso
powershell

minikube service backend-service -n practica-s08 --url
📊 Endpoints de la API
Método	Endpoint	Descripción
GET	/api/health	Health check y estado de MongoDB
GET	/api/productos	Listar todos los productos
POST	/api/productos	Crear un nuevo producto
GET	/api/productos/{id}	Obtener producto por ID
DELETE	/api/productos/{id}	Eliminar producto por ID
🔍 Evidencias de la Rúbrica
Evidencia 1: Estado del Clúster
powershell

kubectl get pods,svc,configmaps,secrets -n practica-s08
Evidencia 2: Inyección de Variables
powershell

$podName = kubectl get pods -n practica-s08 -l app=backend -o jsonpath="{.items[0].metadata.name}"
kubectl exec -it $podName -n practica-s08 -- env | Select-String "DB_|APP_"
Evidencia 3: Exposición Externa
powershell

minikube service backend-service -n practica-s08 --url
curl http://<URL>/api/health
🔒 Seguridad
✅ Secrets para credenciales (Base64)
✅ ConfigMaps para configuración no sensible
✅ MongoDB como ClusterIP (solo interno)
✅ Backend con usuario no privilegiado
✅ Resource limits configurados
✅ Health checks implementados
✅ Persistencia con PVC
Credenciales de prueba:

Usuario: adminpractica
Contraseña: practica2024
🧹 Limpieza
powershell

kubectl delete namespace practica-s08
minikube stop
🐛 Solución de Problemas
MongoDB no inicia
powershell

kubectl logs -n practica-s08 -l app=mongodb --tail=50
kubectl describe pod -n practica-s08 -l app=mongodb
Backend no se conecta a MongoDB
powershell

kubectl logs -n practica-s08 -l app=backend --tail=100
kubectl describe pod -n practica-s08 -l app=backend
Imagen no encontrada
powershell

minikube docker-env | Invoke-Expression
docker build -t backend-practica:1.0 .
kubectl rollout restart deployment backend-deployment -n practica-s08
📚 Referencias
Kubernetes Documentation
Spring Boot Documentation
MongoDB Documentation
Minikube Guide
👨‍💻 Autor
Proyecto Académico S08 | AP6

Práctica de Exposición de Servicios y Configuración Segura en Minikube
