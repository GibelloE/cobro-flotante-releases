<#
.SYNOPSIS
    Instala COBRO FLOTANTE en una terminal nueva (sección 8 de docs/ACTUALIZACIONES.md).

.DESCRIPTION
    Hace las cuatro cosas que hay que hacer una sola vez por caja:

      1. Crea C:\cobro-flotante
      2. Baja el último release publicado y verifica su SHA-256
      3. Deja un acceso directo en el escritorio
      4. Abre el programa una vez, para que se genere data\ con el logo y el sonido

    No necesita Python, ni git, ni el repositorio: sólo este archivo. Tampoco pide
    permisos de administrador, y es a propósito: data\ se crea al lado del .exe, así
    que la carpeta tiene que ser de las que el usuario de Windows puede escribir.
    Por eso NO sirve C:\Program Files.

    Lo que queda para hacer a mano después, una vez por caja (no viaja ni se baja):
    el monitor del cliente, el token de Mercado Pago y el inicio con Windows.
    Está todo en docs/INSTALACION.md.

.PARAMETER Carpeta
    Dónde instalarlo. Por defecto C:\cobro-flotante.

.PARAMETER Repo
    El repositorio público de releases. Tiene que ser el mismo que usa el programa
    para actualizarse (REPO_RELEASES en src/cobro_flotante/actualizador.py).

.PARAMETER Desde
    Instalar desde un CobroFlotante.exe que ya tenés (un pendrive, una carpeta de
    red) en vez de bajarlo. Si al lado hay un .sha256, también lo verifica.

.PARAMETER SinAtajo
    No crear el acceso directo en el escritorio.

.PARAMETER SinAbrir
    No abrir el programa al terminar.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File instalar.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File instalar.ps1 -Desde D:\CobroFlotante.exe
#>
param(
    [string]$Carpeta = "C:\cobro-flotante",
    [string]$Repo = "GibelloE/cobro-flotante-releases",
    [string]$Desde = "",
    [switch]$SinAtajo,
    [switch]$SinAbrir
)

$ErrorActionPreference = "Stop"
$NombreExe = "CobroFlotante.exe"
$NombreAtajo = "Cobro Flotante.lnk"

function Paso($texto) { Write-Host "`n==> $texto" -ForegroundColor Cyan }
function Bien($texto) { Write-Host "    $texto" -ForegroundColor Green }
function Aviso($texto) { Write-Host "    $texto" -ForegroundColor Yellow }
function Morir($texto) { Write-Host "`nERROR: $texto`n" -ForegroundColor Red; exit 1 }

Write-Host "`n  COBRO FLOTANTE - instalación" -ForegroundColor White
Write-Host "  ----------------------------"

# --------------------------------------------------------------- la carpeta --
Paso "Preparando $Carpeta"

# data\ se crea al lado del .exe: en Program Files haria falta ser administrador
# cada vez que el programa guarda la configuracion.
$prohibidas = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:SystemRoot)
foreach ($mala in $prohibidas) {
    if ($mala -and $Carpeta.ToLower().StartsWith($mala.ToLower())) {
        Morir "No instales en '$mala': el programa guarda su configuración al lado del .exe y esa carpeta es de sólo lectura. Usá C:\cobro-flotante."
    }
}

try {
    if (-not (Test-Path $Carpeta)) { New-Item -ItemType Directory -Path $Carpeta -Force | Out-Null }
    $prueba = Join-Path $Carpeta ".permiso-de-escritura"
    Set-Content -Path $prueba -Value "ok" -ErrorAction Stop
    Remove-Item $prueba -Force
} catch {
    Morir "No se puede escribir en $Carpeta. Elegí otra carpeta con -Carpeta, o dale permisos a ésta."
}
Bien "Lista."

# ----------------------------------------------------------- de donde sale --
$temporal = Join-Path $env:TEMP "cobro-flotante-instalacion"
if (Test-Path $temporal) { Remove-Item $temporal -Recurse -Force }
New-Item -ItemType Directory -Path $temporal -Force | Out-Null
$bajado = Join-Path $temporal $NombreExe
$version = ""

if ($Desde) {
    Paso "Copiando desde $Desde"
    if (-not (Test-Path $Desde)) { Morir "No existe el archivo $Desde." }
    Copy-Item $Desde $bajado -Force
    $shaLocal = "$Desde.sha256"
    if (Test-Path $shaLocal) {
        $esperado = ((Get-Content $shaLocal -Raw) -split '\s+' | Where-Object { $_ -match '^[0-9a-fA-F]{64}$' } | Select-Object -First 1)
        $real = (Get-FileHash $bajado -Algorithm SHA256).Hash
        if ($esperado -and $real -ne $esperado.ToUpper()) {
            Morir "El archivo no coincide con su .sha256: puede estar dañado. No se instaló nada."
        }
        Bien "Verificado contra su .sha256."
    } else {
        Aviso "No hay un .sha256 al lado: no se puede verificar que el archivo esté entero."
    }
} else {
    Paso "Buscando la última versión publicada"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    } catch { }
    try {
        # GitHub responde 403 a las consultas sin User-Agent
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" `
            -Headers @{ "User-Agent" = "CobroFlotante-instalador" } -TimeoutSec 20
    } catch {
        Morir "No se pudo consultar GitHub. Puede ser que todavía no exista ninguna versión publicada en $Repo, que el repositorio no sea público, o que esta PC no tenga internet.`n       Si tenés el CobroFlotante.exe en un pendrive:  -Desde D:\$NombreExe"
    }

    $version = "$($release.tag_name)" -replace '^[vV]', ''
    $urlExe = ($release.assets | Where-Object { $_.name -eq $NombreExe } | Select-Object -First 1).browser_download_url
    $urlSha = ($release.assets | Where-Object { $_.name -eq "$NombreExe.sha256" } | Select-Object -First 1).browser_download_url
    if (-not $urlExe) { Morir "El release $version no trae el archivo $NombreExe." }
    if (-not $urlSha) { Morir "El release $version no trae el $NombreExe.sha256, y sin él no hay forma de verificar la descarga." }
    Bien "Versión $version."

    Paso "Bajando el programa (unos 19 MB)"
    # -UseBasicParsing NO es opcional: sin eso, PowerShell 5.1 quiere parsear la
    # respuesta con el motor de Internet Explorer, que en Windows 11 ya no existe, y
    # tira "Referencia a objeto no establecida". Y los dos bajan a archivo a
    # proposito: con -UseBasicParsing, .Content devuelve bytes y no texto.
    $shaBajado = "$bajado.sha256"
    try {
        $progreso = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"     # sin esto Invoke-WebRequest es lentisimo
        Invoke-WebRequest -Uri $urlExe -OutFile $bajado -TimeoutSec 300 -UseBasicParsing `
            -Headers @{ "User-Agent" = "CobroFlotante-instalador" }
        Invoke-WebRequest -Uri $urlSha -OutFile $shaBajado -TimeoutSec 60 -UseBasicParsing `
            -Headers @{ "User-Agent" = "CobroFlotante-instalador" }
        $ProgressPreference = $progreso
    } catch {
        Morir "Se cortó la descarga: $($_.Exception.Message)"
    }
    $textoSha = Get-Content $shaBajado -Raw

    Paso "Verificando que lo que bajó sea lo publicado"
    $esperado = (($textoSha -split '\s+') | Where-Object { $_ -match '^[0-9a-fA-F]{64}$' } | Select-Object -First 1)
    if (-not $esperado) { Morir "El .sha256 publicado no tiene un hash válido adentro." }
    $real = (Get-FileHash $bajado -Algorithm SHA256).Hash
    if ($real -ne $esperado.ToUpper()) {
        Remove-Item $bajado -Force
        Morir "Lo que bajó NO coincide con lo publicado. Puede haberse cortado la descarga. No se instaló nada."
    }
    Bien "SHA-256 correcto."
}

# ------------------------------------------------------------- poner el exe --
Paso "Instalando"
$destino = Join-Path $Carpeta $NombreExe
if (Test-Path $destino) {
    # Reinstalacion: el viejo queda como .anterior, igual que al actualizar
    $anterior = "$destino.anterior"
    Aviso "Ya había una versión instalada: queda como $NombreExe.anterior"
    if (Test-Path $anterior) { Remove-Item $anterior -Force }
    try {
        Move-Item $destino $anterior -Force
    } catch {
        Morir "No se pudo reemplazar el programa. Cerralo (clic derecho en el ícono -> Salir) y volvé a intentar."
    }
}
Move-Item $bajado $destino -Force
Remove-Item $temporal -Recurse -Force -ErrorAction SilentlyContinue
Bien "$destino"

# ------------------------------------------------------------------ atajo --
if (-not $SinAtajo) {
    Paso "Creando el acceso directo en el escritorio"
    try {
        $escritorio = [Environment]::GetFolderPath("Desktop")
        $wsh = New-Object -ComObject WScript.Shell
        $atajo = $wsh.CreateShortcut((Join-Path $escritorio $NombreAtajo))
        $atajo.TargetPath = $destino
        $atajo.WorkingDirectory = $Carpeta
        $atajo.Description = "Pantalla de cobro para el mostrador"
        $atajo.Save()
        Bien "Listo."
    } catch {
        Aviso "No se pudo crear el acceso directo. No es grave: el programa está en $destino."
    }
}

# ------------------------------------------------------------- abrirlo una vez --
if (-not $SinAbrir) {
    Paso "Abriendo el programa por primera vez"
    Aviso "Si Windows avisa 'Windows protegió tu PC', es SmartScreen porque el programa no está firmado:"
    Aviso "Más información -> Ejecutar de todas formas."
    try {
        Start-Process -FilePath $destino -WorkingDirectory $Carpeta
        Bien "Debería aparecer el círculo flotante en pantalla."
    } catch {
        Aviso "No se pudo abrir solo. Abrilo con doble clic en $destino."
    }
}

# ----------------------------------------------------------------- que falta --
Write-Host "`n================================================================" -ForegroundColor White
Write-Host "  Instalado$(if ($version) { " (versión $version)" })" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor White
Write-Host @"

  Falta configurar tres cosas en ESTA caja. No viajan de una PC a otra
  y no se pueden bajar:

    1. El monitor del cliente
       Clic derecho en el ícono -> Configuración... -> contraseña
       -> PANTALLA DEL CLIENTE -> Monitor -> "Detectar monitores conectados"

    2. El token de Mercado Pago (si se usa)
       -> MERCADO PAGO -> pegar el Access Token -> "Probar conexión"
       Se cifra contra esta PC: por eso hay que cargarlo en cada caja.

    3. Iniciar con Windows
       -> SISTEMA -> tildar "Iniciar automáticamente junto con Windows"

  Y después: "Guardar y bloquear".

  El paso a paso completo esta en docs/INSTALACION.md.

"@
