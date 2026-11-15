# Script de PowerShell para probar la API del Backend
# Uso: .\scripts\test-api.ps1

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  S08 | AP6 - Pruebas de API" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Obtener la URL del servicio
Write-Host "Obteniendo URL del servicio..." -ForegroundColor Yellow
$serviceUrl = minikube service backend-service -n practica-s08 --url 2>$null

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($serviceUrl)) {
    Write-Host "ERROR: No se pudo obtener la URL del servicio" -ForegroundColor Red
    Write-Host "Verifica que el servicio esté desplegado correctamente:" -ForegroundColor Yellow
    Write-Host "  kubectl get svc -n practica-s08" -ForegroundColor White
    exit 1
}

Write-Host "✓ URL del servicio: $serviceUrl" -ForegroundColor Green
Write-Host ""

# Test 1: Health Check
Write-Host "[Test 1/4] Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$serviceUrl/api/health" -Method Get -ErrorAction Stop
    Write-Host "✓ Health Check exitoso" -ForegroundColor Green
    Write-Host "  Status: $($response.status)" -ForegroundColor White
    Write-Host "  Database: $($response.database)" -ForegroundColor White
    Write-Host "  DB Connection: $($response.db_connection)" -ForegroundColor White
    Write-Host "  Productos Count: $($response.productos_count)" -ForegroundColor White
} catch {
    Write-Host "✗ Health Check falló: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Listar Productos (GET)
Write-Host "[Test 2/4] Listar Productos (GET /api/productos)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$serviceUrl/api/productos" -Method Get -ErrorAction Stop
    Write-Host "✓ Listado de productos exitoso" -ForegroundColor Green
    Write-Host "  Count: $($response.count)" -ForegroundColor White
    if ($response.count -gt 0) {
        Write-Host "  Productos:" -ForegroundColor White
        $response.productos | ForEach-Object {
            Write-Host "    - $($_.nombre): $($_.precio)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Listado de productos falló: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Crear Producto (POST)
Write-Host "[Test 3/4] Crear Producto (POST /api/productos)..." -ForegroundColor Yellow
$producto = @{
    nombre = "Laptop HP"
    descripcion = "Laptop gaming de alto rendimiento"
    precio = 1500.00
    disponible = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$serviceUrl/api/productos" `
        -Method Post `
        -Body $producto `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "✓ Producto creado exitosamente" -ForegroundColor Green
    Write-Host "  ID: $($response.producto.id)" -ForegroundColor White
    Write-Host "  Nombre: $($response.producto.nombre)" -ForegroundColor White
    Write-Host "  Precio: $($response.producto.precio)" -ForegroundColor White
    
    $productoId = $response.producto.id
} catch {
    Write-Host "✗ Creación de producto falló: $_" -ForegroundColor Red
    $productoId = $null
}
Write-Host ""

# Test 4: Verificar que el producto se guardó
Write-Host "[Test 4/4] Verificar persistencia (GET /api/productos)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$serviceUrl/api/productos" -Method Get -ErrorAction Stop
    Write-Host "✓ Verificación exitosa" -ForegroundColor Green
    Write-Host "  Total de productos: $($response.count)" -ForegroundColor White
    
    if ($productoId -and $response.productos) {
        $productoEncontrado = $response.productos | Where-Object { $_.id -eq $productoId }
        if ($productoEncontrado) {
            Write-Host "  ✓ El producto creado está en la base de datos" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ El producto creado no se encontró" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "✗ Verificación falló: $_" -ForegroundColor Red
}
Write-Host ""

# Resumen
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Pruebas completadas" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL del servicio: $serviceUrl" -ForegroundColor Yellow
Write-Host ""
Write-Host "Puedes acceder a los siguientes endpoints:" -ForegroundColor Yellow
Write-Host "  - GET  $serviceUrl/api/health" -ForegroundColor White
Write-Host "  - GET  $serviceUrl/api/productos" -ForegroundColor White
Write-Host "  - POST $serviceUrl/api/productos" -ForegroundColor White
Write-Host ""
