# 🚀 Inicio Rápido - S08 | AP6

Guía condensada para desplegar el proyecto en menos de 5 minutos.

## Requisitos Previos

- Docker Desktop (ejecutándose)
- Minikube
- kubectl

## Despliegue Automático

```powershell
# 1. Ejecutar el script de despliegue automatizado
.\scripts\deploy-all.ps1
```

Este script realiza automáticamente:
- ✓ Verificación de requisitos
- ✓ Inicio de Minikube (si no está ejecutándose)
- ✓ Creación del namespace `practica-s08`
- ✓ Construcción de la imagen Docker
- ✓ Despliegue de ConfigMap y Secret
- ✓ Despliegue de MongoDB con persistencia
- ✓ Despliegue del Backend
- ✓ Verificación del estado del clúster

## Acceso a la Aplicación

```powershell
# Obtener URL de acceso
minikube service backend-service -n practica-s08 --url

# O abrir directamente en el navegador
minikube service backend-service -n practica-s08
```

## Pruebas de la API

```powershell
# Ejecutar pruebas automatizadas
.\scripts\test-api.ps1
```

Este script prueba automáticamente:
- ✓ Health check
- ✓ Listado de productos
- ✓ Creación de productos
- ✓ Verificación de persistencia

## Generar Evidencias

```powershell
# Generar las tres evidencias requeridas
.\scripts\generate-evidences.ps1
```

Genera:
- Evidencia 1: Estado del clúster
- Evidencia 2: Inyección de variables de entorno
- Evidencia 3: Exposición externa mediante NodePort

Los archivos se guardan en el directorio `evidencias/`.

## Limpieza

```powershell
# Eliminar todos los recursos
.\scripts\cleanup.ps1
```

---

## Comandos Manuales (Alternativa)

Si prefieres el despliegue manual paso a paso, sigue los comandos del [README.md](README.md) principal.

### Despliegue Manual Resumido

```powershell
# 1. Iniciar Minikube
minikube start --driver=docker

# 2. Crear namespace
kubectl create namespace practica-s08

# 3. Construir imagen
minikube docker-env | Invoke-Expression
docker build -t backend-practica:1.0 .

# 4. Aplicar manifiestos
kubectl apply -f k8s/01-app-configmap.yaml
kubectl apply -f k8s/02-db-secret.yaml
kubectl apply -f k8s/03-mongo-stack.yaml
kubectl apply -f k8s/04-backend-stack.yaml

# 5. Esperar a que estén listos
kubectl wait --for=condition=ready pod -l app=mongodb -n practica-s08 --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n practica-s08 --timeout=180s

# 6. Verificar estado
kubectl get pods,svc -n practica-s08

# 7. Obtener URL
minikube service backend-service -n practica-s08 --url
```

## Verificación de Funcionamiento

```powershell
# Reemplazar <URL> con la obtenida anteriormente
curl <URL>/api/health
```

**Respuesta esperada:**
```json
{
  "status": "UP",
  "message": "Backend funcionando correctamente",
  "db_connection": "OK",
  "productos_count": 0
}
```

## Endpoints Disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/health` | Health check y estado de MongoDB |
| GET | `/api/productos` | Listar todos los productos |
| POST | `/api/productos` | Crear un nuevo producto |
| GET | `/api/productos/{id}` | Obtener producto por ID |
| DELETE | `/api/productos/{id}` | Eliminar producto por ID |

## Solución Rápida de Problemas

### Pod no inicia
```powershell
# Ver logs
kubectl logs -n practica-s08 -l app=backend --tail=50
kubectl logs -n practica-s08 -l app=mongodb --tail=50

# Describir pod
kubectl describe pod -n practica-s08 -l app=backend
```

### No puedo acceder a la URL
```powershell
# Verificar que el servicio existe
kubectl get svc backend-service -n practica-s08

# Reintentar obtener URL
minikube service backend-service -n practica-s08 --url
```

### Imagen no encontrada
```powershell
# Reconfigurar Docker y reconstruir
minikube docker-env | Invoke-Expression
docker build -t backend-practica:1.0 .

# Reiniciar deployment
kubectl rollout restart deployment backend-deployment -n practica-s08
```

---

Para más detalles, consulta el [README.md](README.md) completo.
