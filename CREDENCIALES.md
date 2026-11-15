# 🔐 Gestión de Credenciales - S08 | AP6

## Credenciales Actuales (Solo para Desarrollo)

### MongoDB

- **Usuario:** `adminpractica`
- **Contraseña:** `practica2024`

**⚠️ IMPORTANTE:** Estas son credenciales de **demostración académica**. NUNCA uses estas credenciales en entornos de producción o proyectos reales.

---

## Cómo Cambiar las Credenciales

Si deseas cambiar las credenciales de MongoDB, sigue estos pasos:

### Opción 1: Cambiar el Secret (Recomendado)

#### Paso 1: Generar valores en Base64

```powershell
# Convertir nuevo usuario a Base64
$nuevoUsuario = "mi_nuevo_usuario"
$usuarioBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($nuevoUsuario))
Write-Host "DB_USER (Base64): $usuarioBase64"

# Convertir nueva contraseña a Base64
$nuevaPassword = "mi_nueva_password_segura"
$passwordBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($nuevaPassword))
Write-Host "DB_PASS (Base64): $passwordBase64"
```

#### Paso 2: Editar k8s/02-db-secret.yaml

Reemplaza los valores en Base64:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: practica-s08
  labels:
    app: mongodb
    tier: database
type: Opaque
data:
  # Usuario de MongoDB (en Base64)
  DB_USER: <USUARIO_EN_BASE64>
  
  # Contraseña de MongoDB (en Base64)
  DB_PASS: <PASSWORD_EN_BASE64>
```

#### Paso 3: Aplicar los cambios

```powershell
# Eliminar el secret anterior
kubectl delete secret db-secret -n practica-s08

# Aplicar el nuevo secret
kubectl apply -f k8s/02-db-secret.yaml

# Reiniciar los deployments para que tomen el nuevo secret
kubectl rollout restart deployment mongo-deployment -n practica-s08
kubectl rollout restart deployment backend-deployment -n practica-s08

# Esperar a que estén listos
kubectl wait --for=condition=ready pod -l app=mongodb -n practica-s08 --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n practica-s08 --timeout=180s
```

### Opción 2: Usar kubectl para crear el Secret

En lugar de editar el YAML manualmente, puedes crear el Secret directamente:

```powershell
# Eliminar el secret anterior
kubectl delete secret db-secret -n practica-s08 2>$null

# Crear nuevo secret con las credenciales
kubectl create secret generic db-secret `
  --from-literal=DB_USER=mi_nuevo_usuario `
  --from-literal=DB_PASS=mi_nueva_password_segura `
  -n practica-s08

# Reiniciar deployments
kubectl rollout restart deployment mongo-deployment -n practica-s08
kubectl rollout restart deployment backend-deployment -n practica-s08
```

### Opción 3: Usar variables de entorno locales (para testing)

Si solo quieres probar localmente sin Kubernetes:

```powershell
# Definir variables de entorno
$env:DB_HOST = "localhost"
$env:DB_NAME = "practica_db"
$env:DB_USER = "mi_usuario"
$env:DB_PASS = "mi_password"
$env:APP_PORT = "8080"

# Ejecutar la aplicación
mvn spring-boot:run
```

---

## Verificar que las Credenciales Funcionan

### Verificar en MongoDB

```powershell
# Obtener el nombre del pod de MongoDB
$mongoPod = kubectl get pods -n practica-s08 -l app=mongodb -o jsonpath="{.items[0].metadata.name}"

# Intentar conectarse con las credenciales
kubectl exec -it $mongoPod -n practica-s08 -- mongosh `
  -u adminpractica `
  -p practica2024 `
  --authenticationDatabase admin
```

Si las credenciales son correctas, verás el prompt de MongoDB:
```
test>
```

### Verificar en el Backend

```powershell
# Obtener el nombre del pod del backend
$backendPod = kubectl get pods -n practica-s08 -l app=backend -o jsonpath="{.items[0].metadata.name}"

# Ver las variables de entorno (sin mostrar la contraseña completa)
kubectl exec -it $backendPod -n practica-s08 -- env | Select-String "DB_USER"

# Ver los logs para verificar conexión
kubectl logs $backendPod -n practica-s08 --tail=50 | Select-String "MongoDB"
```

### Verificar mediante la API

```powershell
# Obtener URL del servicio
$serviceUrl = minikube service backend-service -n practica-s08 --url

# Health check (debe mostrar db_connection: OK)
curl "$serviceUrl/api/health"
```

---

## Decodificar Credenciales del Secret

Si necesitas ver las credenciales actuales almacenadas en el Secret:

```powershell
# Ver el Secret completo
kubectl get secret db-secret -n practica-s08 -o yaml

# Decodificar solo el usuario
kubectl get secret db-secret -n practica-s08 -o jsonpath="{.data.DB_USER}" | `
  ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

# Decodificar solo la contraseña
kubectl get secret db-secret -n practica-s08 -o jsonpath="{.data.DB_PASS}" | `
  ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

---

## Buenas Prácticas de Seguridad

### ✅ SÍ hacer:

1. **Usar Secrets para credenciales:**
   - Nunca hardcodear en el código fuente
   - Usar ConfigMaps solo para configuración no sensible

2. **Rotar credenciales regularmente:**
   - Cambiar contraseñas periódicamente
   - Especialmente después de que alguien deje el equipo

3. **Principio de mínimo privilegio:**
   - Crear usuarios de MongoDB con solo los permisos necesarios
   - Ejemplo: un usuario de solo lectura para reportes

4. **Credenciales diferentes por entorno:**
   - Desarrollo: credenciales simples
   - Producción: credenciales complejas y únicas

5. **No commitear Secrets a Git:**
   - El `.gitignore` debe incluir archivos de secretos locales
   - Si accidentalmente commiteaste un secret, rotalo inmediatamente

### ❌ NO hacer:

1. **No usar credenciales por defecto:**
   - `admin/admin`, `root/root`, etc.

2. **No compartir credenciales de producción:**
   - Usar herramientas de gestión de secretos (Vault, 1Password)

3. **No logear credenciales:**
   - Nunca imprimir secretos en logs
   - Cuidado con stack traces que pueden exponer variables

4. **No reutilizar credenciales:**
   - Cada servicio debe tener sus propias credenciales

5. **No commitear archivos .env:**
   - Agregar `.env*` al `.gitignore`

---

## Gestión Avanzada de Secretos

### Para Producción: Sealed Secrets

Sealed Secrets permite encriptar secretos para commitearlos de forma segura a Git.

```powershell
# Instalar Sealed Secrets Controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Instalar cliente kubeseal
# (Descargar desde https://github.com/bitnami-labs/sealed-secrets/releases)

# Crear un secret
kubectl create secret generic db-secret `
  --from-literal=DB_USER=adminpractica `
  --from-literal=DB_PASS=practica2024 `
  --dry-run=client `
  -o yaml > db-secret.yaml

# Encriptar el secret
kubeseal -f db-secret.yaml -w db-sealed-secret.yaml

# Ahora db-sealed-secret.yaml puede commitearse a Git de forma segura
```

### Para Producción: HashiCorp Vault

Vault proporciona gestión centralizada de secretos con auditoría y rotación automática.

```yaml
# Ejemplo de configuración con Vault
apiVersion: v1
kind: Pod
metadata:
  name: backend
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "backend"
    vault.hashicorp.com/agent-inject-secret-database: "database/creds/mongodb"
spec:
  serviceAccountName: backend
  containers:
  - name: backend
    image: backend-practica:1.0
```

### Para Cloud: Servicios Nativos

#### AWS Secrets Manager
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  annotations:
    aws-secret-manager/secret-name: "practica/mongodb"
```

#### Azure Key Vault
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  annotations:
    azure-key-vault-secret: "mongodb-credentials"
```

#### Google Cloud Secret Manager
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  annotations:
    secret-manager.googleapis.com/secret-name: "mongodb-creds"
```

---

## Auditoría de Acceso a Secretos

### Ver quién accedió a un Secret

Kubernetes registra accesos en los audit logs (si están habilitados):

```powershell
# Ver eventos relacionados con el secret
kubectl get events -n practica-s08 --field-selector involvedObject.name=db-secret

# Ver pods que montan el secret
kubectl get pods -n practica-s08 -o json | `
  jq '.items[] | select(.spec.containers[].envFrom[]?.secretRef.name=="db-secret") | .metadata.name'
```

---

## Rotación de Credenciales Sin Downtime

Para rotar credenciales sin interrumpir el servicio:

```powershell
# 1. Crear nuevo usuario en MongoDB con los mismos permisos
kubectl exec -it <MONGO_POD> -n practica-s08 -- mongosh -u adminpractica -p practica2024 --authenticationDatabase admin --eval '
  db.getSiblingDB("admin").createUser({
    user: "nuevo_usuario",
    pwd: "nueva_password",
    roles: [{role: "root", db: "admin"}]
  })
'

# 2. Crear nuevo Secret con las nuevas credenciales
kubectl create secret generic db-secret-new `
  --from-literal=DB_USER=nuevo_usuario `
  --from-literal=DB_PASS=nueva_password `
  -n practica-s08

# 3. Actualizar Deployment para usar el nuevo Secret
# Editar k8s/04-backend-stack.yaml:
# secretRef:
#   name: db-secret-new

# 4. Aplicar cambios
kubectl apply -f k8s/04-backend-stack.yaml

# 5. Verificar que funciona correctamente

# 6. Eliminar el usuario antiguo de MongoDB
kubectl exec -it <MONGO_POD> -n practica-s08 -- mongosh -u nuevo_usuario -p nueva_password --authenticationDatabase admin --eval '
  db.getSiblingDB("admin").dropUser("adminpractica")
'

# 7. Eliminar el Secret antiguo
kubectl delete secret db-secret -n practica-s08
```

---

## Preguntas Frecuentes

### ¿Por qué Base64 si no es seguro?

Base64 es solo **codificación**, no **encriptación**. Se usa para:
- Permitir caracteres especiales en YAML
- Consistencia en el formato de Secrets

Kubernetes proporciona seguridad adicional:
- Secrets se almacenan encriptados en etcd (si se configura)
- Permisos de RBAC controlan quién puede leer Secrets
- Secrets no se muestran en logs de Kubernetes

### ¿Puedo usar archivos en lugar de variables de entorno?

Sí, puedes montar Secrets como archivos:

```yaml
volumeMounts:
- name: secret-volume
  mountPath: /etc/secrets
  readOnly: true
volumes:
- name: secret-volume
  secret:
    secretName: db-secret
```

Luego leer desde `/etc/secrets/DB_USER` y `/etc/secrets/DB_PASS`.

### ¿Cómo genero contraseñas seguras?

```powershell
# Generar contraseña aleatoria de 32 caracteres
$password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
Write-Host "Contraseña generada: $password"

# O usar herramientas como 1Password, LastPass, etc.
```

---

## Resumen

- ✅ Credenciales actuales: `adminpractica` / `practica2024` (solo para desarrollo)
- ✅ Cambiar credenciales editando el Secret y reiniciando deployments
- ✅ Verificar conexión mediante MongoDB shell, logs y API
- ✅ Nunca commitear credenciales reales a Git
- ✅ Para producción, usar herramientas avanzadas como Vault o Sealed Secrets

---

**Documentación de seguridad para la práctica académica S08 | AP6**
