# Script de PowerShell para generar las evidencias requeridas en la rúbrica
# Uso: .\scripts\generate-evidences.ps1

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  S08 | AP6 - Generación de Evidencias" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Crear directorio para las evidencias
$evidencesDir = "evidencias"
if (-not (Test-Path $evidencesDir)) {
    New-Item -ItemType Directory -Path $evidencesDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# EVIDENCIA 1: Estado del Clúster
Write-Host "[Evidencia 1/3] Estado del Clúster" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Gray
Write-Host ""
$evidencia1 = kubectl get pods,svc,configmaps,secrets -n practica-s08 2>&1
$evidencia1 | Out-String
$evidencia1 | Out-File -FilePath "$evidencesDir/evidencia1_estado_cluster_$timestamp.txt"
Write-Host ""
Write-Host "✓ Guardado en: $evidencesDir/evidencia1_estado_cluster_$timestamp.txt" -ForegroundColor Green
Write-Host ""

# EVIDENCIA 2: Inyección de Variables
Write-Host "[Evidencia 2/3] Inyección de Variables de Entorno" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Gray
Write-Host ""

# Obtener el nombre del primer pod del backend
$podName = kubectl get pods -n practica-s08 -l app=backend -o jsonpath="{.items[0].metadata.name}" 2>&1

if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrEmpty($podName)) {
    Write-Host "Pod seleccionado: $podName" -ForegroundColor White
    Write-Host ""
    
    $evidencia2 = kubectl exec -it $podName -n practica-s08 -- env 2>&1 | Select-String "DB_|APP_"
    $evidencia2 | Out-String
    
    # Guardar evidencia
    "Pod: $podName" | Out-File -FilePath "$evidencesDir/evidencia2_variables_entorno_$timestamp.txt"
    "" | Out-File -FilePath "$evidencesDir/evidencia2_variables_entorno_$timestamp.txt" -Append
    $evidencia2 | Out-File -FilePath "$evidencesDir/evidencia2_variables_entorno_$timestamp.txt" -Append
    
    Write-Host ""
    Write-Host "✓ Guardado en: $evidencesDir/evidencia2_variables_entorno_$timestamp.txt" -ForegroundColor Green
} else {
    Write-Host "✗ No se encontró ningún pod del backend" -ForegroundColor Red
    "ERROR: No se encontró ningún pod del backend" | Out-File -FilePath "$evidencesDir/evidencia2_variables_entorno_$timestamp.txt"
}
Write-Host ""

# EVIDENCIA 3: Exposición Externa
Write-Host "[Evidencia 3/3] Exposición Externa mediante NodePort" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Gray
Write-Host ""

$serviceUrl = minikube service backend-service -n practica-s08 --url 2>$null

if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrEmpty($serviceUrl)) {
    Write-Host "URL del servicio: $serviceUrl" -ForegroundColor White
    Write-Host ""
    
    # Intentar hacer una petición al health check
    try {
        $healthResponse = Invoke-RestMethod -Uri "$serviceUrl/api/health" -Method Get -ErrorAction Stop
        Write-Host "✓ Respuesta del Health Check:" -ForegroundColor Green
        $healthResponse | ConvertTo-Json -Depth 3 | Out-String
        
        # Guardar evidencia
        "URL del servicio: $serviceUrl" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt"
        "" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -Append
        "Respuesta del Health Check:" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -Append
        $healthResponse | ConvertTo-Json -Depth 3 | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -Append
        
        Write-Host ""
        Write-Host "✓ Guardado en: $evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -ForegroundColor Green
    } catch {
        Write-Host "✗ No se pudo conectar al servicio: $_" -ForegroundColor Red
        "URL del servicio: $serviceUrl" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt"
        "" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -Append
        "ERROR: No se pudo conectar al servicio" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -Append
        $_.Exception.Message | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt" -Append
    }
} else {
    Write-Host "✗ No se pudo obtener la URL del servicio" -ForegroundColor Red
    "ERROR: No se pudo obtener la URL del servicio" | Out-File -FilePath "$evidencesDir/evidencia3_exposicion_externa_$timestamp.txt"
}
Write-Host ""

# Resumen
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Evidencias generadas exitosamente" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos generados en el directorio: $evidencesDir/" -ForegroundColor Yellow
Write-Host "  1. evidencia1_estado_cluster_$timestamp.txt" -ForegroundColor White
Write-Host "  2. evidencia2_variables_entorno_$timestamp.txt" -ForegroundColor White
Write-Host "  3. evidencia3_exposicion_externa_$timestamp.txt" -ForegroundColor White
Write-Host ""
Write-Host "Estos archivos pueden adjuntarse como evidencia de la práctica." -ForegroundColor Yellow
Write-Host ""
