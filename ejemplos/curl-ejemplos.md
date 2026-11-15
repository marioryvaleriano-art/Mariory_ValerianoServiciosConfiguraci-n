# Ejemplos de uso con curl

Esta guía proporciona ejemplos prácticos de cómo interactuar con la API usando `curl` desde PowerShell.

> **Nota:** Reemplaza `<URL>` con la URL obtenida al ejecutar:
> ```powershell
> minikube service backend-service -n practica-s08 --url
> ```

## 1. Health Check

Verificar que la aplicación está funcionando y conectada a MongoDB:

```powershell
curl http://<URL>/api/health
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

## 2. Listar todos los productos (GET)

```powershell
curl http://<URL>/api/productos
```

**Respuesta esperada (vacía inicialmente):**
```json
{
  "success": true,
  "count": 0,
  "productos": []
}
```

## 3. Crear un producto (POST)

### Ejemplo 1: Laptop

```powershell
curl -X POST http://<URL>/api/productos `
  -H "Content-Type: application/json" `
  -d '{\"nombre\":\"Laptop HP\",\"descripcion\":\"Laptop gaming\",\"precio\":1500.00,\"disponible\":true}'
```

### Ejemplo 2: Mouse

```powershell
curl -X POST http://<URL>/api/productos `
  -H "Content-Type: application/json" `
  -d '{\"nombre\":\"Mouse Logitech\",\"descripcion\":\"Mouse inalámbrico\",\"precio\":99.99,\"disponible\":true}'
```

### Ejemplo 3: Teclado

```powershell
curl -X POST http://<URL>/api/productos `
  -H "Content-Type: application/json" `
  -d '{\"nombre\":\"Teclado Mecánico\",\"descripcion\":\"Teclado con switches azules\",\"precio\":85.00,\"disponible\":false}'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Producto creado exitosamente",
  "producto": {
    "id": "6563a1b2c3d4e5f6a7b8c9d0",
    "nombre": "Laptop HP",
    "descripcion": "Laptop gaming",
    "precio": 1500.0,
    "disponible": true
  }
}
```

## 4. Obtener un producto por ID (GET)

```powershell
# Reemplaza <ID> con el ID obtenido al crear el producto
curl http://<URL>/api/productos/<ID>
```

**Respuesta esperada:**
```json
{
  "success": true,
  "producto": {
    "id": "6563a1b2c3d4e5f6a7b8c9d0",
    "nombre": "Laptop HP",
    "descripcion": "Laptop gaming",
    "precio": 1500.0,
    "disponible": true
  }
}
```

## 5. Eliminar un producto (DELETE)

```powershell
# Reemplaza <ID> con el ID del producto a eliminar
curl -X DELETE http://<URL>/api/productos/<ID>
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Producto eliminado exitosamente"
}
```

## 6. Crear múltiples productos con un script

Si deseas crear varios productos de prueba rápidamente:

```powershell
# Guardar este script como crear-productos-demo.ps1
$url = "http://<URL>/api/productos"

$productos = @(
    @{nombre="Laptop HP"; descripcion="Laptop gaming"; precio=1500.00; disponible=$true},
    @{nombre="Mouse Logitech"; descripcion="Mouse inalámbrico"; precio=99.99; disponible=$true},
    @{nombre="Teclado Mecánico"; descripcion="Switches azules"; precio=85.00; disponible=$false},
    @{nombre="Monitor Dell 27"; descripcion="Monitor 4K"; precio=450.00; disponible=$true},
    @{nombre="Auriculares Sony"; descripcion="Cancelación de ruido"; precio=399.99; disponible=$true}
)

foreach ($producto in $productos) {
    $body = $producto | ConvertTo-Json
    Write-Host "Creando: $($producto.nombre)..."
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✓ Creado: $($response.producto.nombre) (ID: $($response.producto.id))" -ForegroundColor Green
    } else {
        Write-Host "✗ Error al crear $($producto.nombre)" -ForegroundColor Red
    }
}

Write-Host "`nProductos creados exitosamente. Ejecuta curl $url/productos para verlos."
```

Luego ejecuta:
```powershell
.\crear-productos-demo.ps1
```

## 7. Probar con Invoke-RestMethod (alternativa a curl)

PowerShell también tiene un comando nativo más potente:

### Health Check
```powershell
Invoke-RestMethod -Uri "http://<URL>/api/health" -Method Get
```

### Listar productos
```powershell
Invoke-RestMethod -Uri "http://<URL>/api/productos" -Method Get
```

### Crear producto
```powershell
$body = @{
    nombre = "Laptop HP"
    descripcion = "Laptop gaming"
    precio = 1500.00
    disponible = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://<URL>/api/productos" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

### Eliminar producto
```powershell
Invoke-RestMethod -Uri "http://<URL>/api/productos/<ID>" -Method Delete
```

## 8. Formatear respuestas JSON

Para ver las respuestas JSON con mejor formato:

```powershell
# Con curl
curl http://<URL>/api/productos | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Con Invoke-RestMethod (ya formatea automáticamente)
Invoke-RestMethod -Uri "http://<URL>/api/productos" | ConvertTo-Json -Depth 10
```

## 9. Guardar respuestas en archivos

```powershell
# Guardar listado de productos en un archivo
curl http://<URL>/api/productos | Out-File -FilePath productos.json

# O con Invoke-RestMethod
Invoke-RestMethod -Uri "http://<URL>/api/productos" | ConvertTo-Json -Depth 10 | Out-File productos.json
```

## Notas importantes

- En PowerShell, las comillas dobles dentro de JSON deben escaparse con `\` cuando se usa `curl`
- `Invoke-RestMethod` es más amigable con PowerShell y maneja JSON automáticamente
- Reemplaza siempre `<URL>` con la URL real obtenida de Minikube
- Los IDs de productos son generados automáticamente por MongoDB

## Solución de problemas

### Error de conexión
```powershell
# Verificar que el servicio está disponible
kubectl get svc backend-service -n practica-s08

# Verificar que el pod está funcionando
kubectl get pods -n practica-s08 -l app=backend

# Ver logs del backend
kubectl logs -n practica-s08 -l app=backend --tail=50
```

### Error 404
- Verifica que la URL incluya `/api/` en la ruta
- Ejemplo correcto: `http://127.0.0.1:51234/api/health`

### Error 500
- Puede ser un problema de conexión con MongoDB
- Verifica los logs del backend y de MongoDB
- Verifica que las credenciales en el Secret sean correctas
