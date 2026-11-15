# Script de PowerShell para desplegar el proyecto completo en Minikube
# Uso: .\scripts\deploy-all.ps1

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  S08 | AP6 - Despliegue Automatizado" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Función para verificar si un comando existe
function Test-Command {
    param($CommandName)
    return [bool](Get-Command -Name $CommandName -ErrorAction SilentlyContinue)
}

# Verificar requisitos
Write-Host "[1/10] Verificando requisitos..." -ForegroundColor Yellow
$requiredCommands = @("docker", "minikube", "kubectl")
$missingCommands = @()

foreach ($cmd in $requiredCommands) {
    if (-not (Test-Command $cmd)) {
        $missingCommands += $cmd
    }
}

if ($missingCommands.Count -gt 0) {
    Write-Host "ERROR: Faltan los siguientes comandos: $($missingCommands -join ', ')" -ForegroundColor Red
    Write-Host "Por favor, instala Docker Desktop, Minikube y kubectl." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Todos los requisitos están instalados" -ForegroundColor Green
Write-Host ""

# Verificar que Minikube está ejecutándose
Write-Host "[2/10] Verificando Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Minikube no está ejecutándose. Iniciando Minikube..." -ForegroundColor Yellow
    minikube start --driver=docker
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo iniciar Minikube" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✓ Minikube está ejecutándose" -ForegroundColor Green
Write-Host ""

# Crear namespace
Write-Host "[3/10] Creando namespace practica-s08..." -ForegroundColor Yellow
kubectl create namespace practica-s08 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Namespace creado exitosamente" -ForegroundColor Green
} else {
    Write-Host "⚠ El namespace ya existe (continuando...)" -ForegroundColor Yellow
}
Write-Host ""

# Configurar Docker de Minikube
Write-Host "[4/10] Configurando entorno Docker de Minikube..." -ForegroundColor Yellow
minikube docker-env | Invoke-Expression
Write-Host "✓ Entorno Docker configurado" -ForegroundColor Green
Write-Host ""

# Construir imagen Docker
Write-Host "[5/10] Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t backend-practica:1.0 .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo construir la imagen Docker" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Imagen Docker construida exitosamente" -ForegroundColor Green
Write-Host ""

# Aplicar ConfigMap
Write-Host "[6/10] Aplicando ConfigMap..." -ForegroundColor Yellow
kubectl apply -f k8s/01-app-configmap.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo aplicar el ConfigMap" -ForegroundColor Red
    exit 1
}
Write-Host "✓ ConfigMap aplicado" -ForegroundColor Green
Write-Host ""

# Aplicar Secret
Write-Host "[7/10] Aplicando Secret..." -ForegroundColor Yellow
kubectl apply -f k8s/02-db-secret.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo aplicar el Secret" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Secret aplicado" -ForegroundColor Green
Write-Host ""

# Desplegar MongoDB
Write-Host "[8/10] Desplegando MongoDB..." -ForegroundColor Yellow
kubectl apply -f k8s/03-mongo-stack.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo desplegar MongoDB" -ForegroundColor Red
    exit 1
}
Write-Host "✓ MongoDB desplegado" -ForegroundColor Green
Write-Host "Esperando a que MongoDB esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mongodb -n practica-s08 --timeout=120s
Write-Host "✓ MongoDB está listo" -ForegroundColor Green
Write-Host ""

# Desplegar Backend
Write-Host "[9/10] Desplegando Backend..." -ForegroundColor Yellow
kubectl apply -f k8s/04-backend-stack.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo desplegar el Backend" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Backend desplegado" -ForegroundColor Green
Write-Host "Esperando a que el Backend esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=backend -n practica-s08 --timeout=180s
Write-Host "✓ Backend está listo" -ForegroundColor Green
Write-Host ""

# Verificar estado
Write-Host "[10/10] Verificando estado del clúster..." -ForegroundColor Yellow
Write-Host ""
kubectl get pods,svc,configmaps,secrets -n practica-s08
Write-Host ""

# Obtener URL de acceso
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ¡Despliegue completado exitosamente!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para obtener la URL de acceso, ejecuta:" -ForegroundColor Yellow
Write-Host "  minikube service backend-service -n practica-s08 --url" -ForegroundColor White
Write-Host ""
Write-Host "O para abrirlo directamente en el navegador:" -ForegroundColor Yellow
Write-Host "  minikube service backend-service -n practica-s08" -ForegroundColor White
Write-Host ""
Write-Host "Endpoints disponibles:" -ForegroundColor Yellow
Write-Host "  - GET  /api/health" -ForegroundColor White
Write-Host "  - GET  /api/productos" -ForegroundColor White
Write-Host "  - POST /api/productos" -ForegroundColor White
Write-Host ""
