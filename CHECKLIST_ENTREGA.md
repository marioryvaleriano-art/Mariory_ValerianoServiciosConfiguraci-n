# ✅ Checklist de Entrega - S08 | AP6

## 📋 Lista de Verificación Previa a la Entrega

Utiliza este checklist para asegurarte de que el proyecto cumple con todos los requisitos de la rúbrica.

---

## 1. Estructura del Proyecto ✓

- [x] **Directorio k8s/** con los 4 manifiestos YAML
  - [x] 01-app-configmap.yaml
  - [x] 02-db-secret.yaml
  - [x] 03-mongo-stack.yaml
  - [x] 04-backend-stack.yaml

- [x] **Código fuente Java (src/)**
  - [x] Clase principal (BackendPracticaApplication.java)
  - [x] Configuración de MongoDB (MongoConfig.java)
  - [x] Modelo de datos (Producto.java)
  - [x] Repository (ProductoRepository.java)
  - [x] Controller REST (ProductoController.java)
  - [x] application.properties

- [x] **Archivos Docker**
  - [x] Dockerfile
  - [x] .dockerignore

- [x] **Documentación**
  - [x] README.md completo
  - [x] QUICK_START.md
  - [x] .gitignore

- [x] **Scripts de utilidad**
  - [x] deploy-all.ps1 (despliegue automatizado)
  - [x] test-api.ps1 (pruebas de API)
  - [x] generate-evidences.ps1 (generar evidencias)
  - [x] cleanup.ps1 (limpieza de recursos)

- [x] **Ejemplos**
  - [x] curl-ejemplos.md
  - [x] productos-ejemplo.json

---

## 2. Manifiestos de Kubernetes

### ConfigMap (5 puntos)
- [ ] Contiene las variables: DB_HOST, DB_NAME, APP_PORT
- [ ] Nombre del ConfigMap: `app-configmap`
- [ ] Namespace: `practica-s08`
- [ ] Comentarios explicativos en el YAML

### Secret (5 puntos)
- [ ] Contiene DB_USER y DB_PASS codificados en Base64
- [ ] Tipo: Opaque
- [ ] Nombre del Secret: `db-secret`
- [ ] Namespace: `practica-s08`
- [ ] Comentarios explicativos en el YAML

### MongoDB Stack (10 puntos)
- [ ] Deployment de MongoDB configurado
- [ ] Service de tipo ClusterIP
- [ ] PersistentVolumeClaim para persistencia (1Gi)
- [ ] Variables de entorno obtenidas del Secret
- [ ] Probes (liveness y readiness) configurados
- [ ] Resource limits definidos
- [ ] Comentarios explicativos en el YAML

### Backend Stack (10 puntos)
- [ ] Deployment del Backend configurado
- [ ] Service de tipo NodePort (puerto 30080)
- [ ] Variables inyectadas mediante envFrom (ConfigMap y Secret)
- [ ] imagePullPolicy: Never
- [ ] Probes (liveness y readiness) configurados
- [ ] Resource limits definidos
- [ ] Comentarios explicativos en el YAML

---

## 3. Código Fuente del Backend

### Funcionalidad (15 puntos)
- [ ] Aplicación Spring Boot funcional
- [ ] Conexión a MongoDB operativa
- [ ] Endpoint GET /api/health
- [ ] Endpoint GET /api/productos
- [ ] Endpoint POST /api/productos
- [ ] Variables de entorno obtenidas correctamente
- [ ] URI de MongoDB construida dinámicamente
- [ ] No hay credenciales hardcodeadas en el código

### Calidad del Código (5 puntos)
- [ ] Código limpio y comentado
- [ ] Organización en paquetes (controller, model, repository, config)
- [ ] Uso de anotaciones de Spring apropiadas
- [ ] Manejo de errores implementado
- [ ] Validaciones en el modelo

---

## 4. Docker

### Dockerfile (5 puntos)
- [ ] Multi-stage build implementado
- [ ] Imagen optimizada (Alpine)
- [ ] Usuario no privilegiado configurado
- [ ] Puerto 8080 expuesto
- [ ] Comentarios explicativos

### Construcción (5 puntos)
- [ ] La imagen se construye sin errores
- [ ] La imagen está disponible en Minikube
- [ ] Tamaño de imagen razonable

---

## 5. Despliegue en Minikube

### Configuración del Clúster (10 puntos)
- [ ] Minikube inicia correctamente
- [ ] Namespace `practica-s08` creado
- [ ] Todos los manifiestos aplicados sin errores
- [ ] ConfigMap desplegado correctamente
- [ ] Secret desplegado correctamente
- [ ] MongoDB desplegado y funcionando
- [ ] Backend desplegado y funcionando

### Estado de los Recursos (10 puntos)
- [ ] Todos los pods en estado Running
- [ ] Servicios configurados correctamente
- [ ] PVC creado y bound
- [ ] ConfigMap visible en el namespace
- [ ] Secret visible en el namespace

---

## 6. Evidencias Requeridas (20 puntos)

### Evidencia 1: Estado del Clúster (7 puntos)
```powershell
kubectl get pods,svc,configmaps,secrets -n practica-s08
```
- [ ] Ejecutado correctamente
- [ ] Muestra todos los recursos
- [ ] Pods en estado Running
- [ ] Services activos
- [ ] ConfigMap presente
- [ ] Secret presente

### Evidencia 2: Inyección de Variables (7 puntos)
```powershell
kubectl exec -it <POD_NAME> -n practica-s08 -- env | Select-String "DB_|APP_"
```
- [ ] Ejecutado correctamente
- [ ] DB_HOST visible
- [ ] DB_NAME visible
- [ ] DB_USER visible
- [ ] DB_PASS visible
- [ ] APP_PORT visible
- [ ] Valores correctos

### Evidencia 3: Exposición Externa (6 puntos)
```powershell
minikube service backend-service -n practica-s08 --url
```
- [ ] Ejecutado correctamente
- [ ] URL obtenida
- [ ] Acceso desde navegador funcional
- [ ] /api/health responde correctamente
- [ ] /api/productos responde correctamente
- [ ] POST /api/productos funciona

---

## 7. Funcionalidad de la API (10 puntos)

### Endpoints
- [ ] GET /api/health - Status UP, db_connection OK
- [ ] GET /api/productos - Lista productos (vacía o con datos)
- [ ] POST /api/productos - Crea producto correctamente
- [ ] GET /api/productos/{id} - Recupera producto por ID
- [ ] DELETE /api/productos/{id} - Elimina producto

### Persistencia (5 puntos)
- [ ] Productos se guardan en MongoDB
- [ ] Productos persisten después de reiniciar pods
- [ ] Contador de productos en health check es correcto

---

## 8. Seguridad y Buenas Prácticas (10 puntos)

### Seguridad
- [ ] Credenciales en Secret, no en código
- [ ] ConfigMap para configuración no sensible
- [ ] MongoDB accesible solo internamente (ClusterIP)
- [ ] Backend con usuario no privilegiado
- [ ] No hay credenciales reales en el repositorio

### Buenas Prácticas
- [ ] Resource limits definidos
- [ ] Probes configurados (liveness y readiness)
- [ ] Persistencia con PVC
- [ ] Comentarios en todos los archivos YAML
- [ ] .gitignore configurado correctamente
- [ ] .dockerignore configurado correctamente

---

## 9. Documentación (10 puntos)

### README.md
- [ ] Descripción clara del proyecto
- [ ] Arquitectura explicada con diagrama
- [ ] Tecnologías listadas
- [ ] Guía de instalación paso a paso
- [ ] Comandos funcionales en PowerShell
- [ ] Ejemplos de uso de la API
- [ ] Solución de problemas comunes
- [ ] Referencias y recursos

### Documentación Adicional
- [ ] QUICK_START.md presente
- [ ] Ejemplos de curl disponibles
- [ ] Scripts comentados
- [ ] Checklist de entrega (este archivo)

---

## 10. Scripts de Automatización (Extra)

### deploy-all.ps1
- [ ] Despliega todo el proyecto automáticamente
- [ ] Verifica requisitos
- [ ] Maneja errores correctamente
- [ ] Proporciona feedback al usuario

### test-api.ps1
- [ ] Prueba todos los endpoints
- [ ] Muestra resultados claros
- [ ] Verifica persistencia

### generate-evidences.ps1
- [ ] Genera las 3 evidencias automáticamente
- [ ] Guarda archivos en directorio evidencias/
- [ ] Incluye timestamps

### cleanup.ps1
- [ ] Elimina todos los recursos
- [ ] Solicita confirmación
- [ ] No deja recursos huérfanos

---

## 11. Pruebas Finales

### Despliegue Limpio
- [ ] Eliminar namespace: `kubectl delete namespace practica-s08`
- [ ] Ejecutar: `.\scripts\deploy-all.ps1`
- [ ] Verificar que todo funciona desde cero

### Pruebas de Funcionalidad
- [ ] Ejecutar: `.\scripts\test-api.ps1`
- [ ] Todos los tests pasan
- [ ] Crear productos manualmente
- [ ] Verificar en MongoDB

### Generación de Evidencias
- [ ] Ejecutar: `.\scripts\generate-evidences.ps1`
- [ ] 3 archivos generados en evidencias/
- [ ] Archivos contienen información correcta

---

## 12. Entrega Final

### Repositorio Git
- [ ] Commit de todos los archivos
- [ ] Mensaje de commit descriptivo
- [ ] Push al repositorio remoto (GitHub)
- [ ] README visible en la página principal

### Archivos de Evidencia
- [ ] evidencia1_estado_cluster_[timestamp].txt
- [ ] evidencia2_variables_entorno_[timestamp].txt
- [ ] evidencia3_exposicion_externa_[timestamp].txt

### Verificación Final
- [ ] Clonar el repositorio en una nueva ubicación
- [ ] Seguir los pasos del README.md
- [ ] Verificar que todo funciona

---

## 13. Rúbrica de Evaluación (Total: 20 puntos)

### Criterio 1: Configuración de ConfigMap y Secret (5 puntos)
- [ ] 5 puntos: ConfigMap y Secret correctamente configurados y utilizados
- [ ] 3-4 puntos: Configurados pero con errores menores
- [ ] 1-2 puntos: Configuración incompleta
- [ ] 0 puntos: No implementado

### Criterio 2: Despliegue de MongoDB (5 puntos)
- [ ] 5 puntos: MongoDB desplegado con persistencia y acceso interno
- [ ] 3-4 puntos: Desplegado pero sin persistencia o con configuración subóptima
- [ ] 1-2 puntos: Desplegado con errores significativos
- [ ] 0 puntos: No desplegado

### Criterio 3: Despliegue del Backend y Exposición (5 puntos)
- [ ] 5 puntos: Backend desplegado correctamente y expuesto mediante NodePort
- [ ] 3-4 puntos: Desplegado pero con problemas de exposición
- [ ] 1-2 puntos: Despliegue incompleto
- [ ] 0 puntos: No desplegado

### Criterio 4: Evidencias y Documentación (5 puntos)
- [ ] 5 puntos: Las 3 evidencias correctas y documentación completa
- [ ] 3-4 puntos: Evidencias correctas pero documentación incompleta
- [ ] 1-2 puntos: Solo algunas evidencias o documentación mínima
- [ ] 0 puntos: Sin evidencias ni documentación

---

## ✅ Confirmación Final

- [ ] He revisado TODOS los puntos de este checklist
- [ ] El proyecto cumple con TODOS los requisitos
- [ ] He generado las 3 evidencias requeridas
- [ ] La documentación está completa
- [ ] El código funciona correctamente
- [ ] El repositorio está limpio y organizado
- [ ] Estoy listo para entregar la práctica

---

## 📝 Notas Adicionales

**Fecha de revisión:** _________________

**Comentarios:**
_______________________________________________
_______________________________________________
_______________________________________________

**Problemas encontrados y solucionados:**
_______________________________________________
_______________________________________________
_______________________________________________

---

**¡Buena suerte con tu entrega! 🚀**
