. .\FunGENERALES.ps1

function Get-SubnetMaskFromIP {
    param([string]$ip)

    $octetos = $ip.Split('.')
    $primerOcteto = [int]$octetos[0]

    if ($primerOcteto -ge 1 -and $primerOcteto -le 126) {
        return "255.0.0.0"      # Clase A → /8
    } elseif ($primerOcteto -ge 128 -and $primerOcteto -le 191) {
        return "255.255.0.0"    # Clase B → /16
    } elseif ($primerOcteto -ge 192 -and $primerOcteto -le 223) {
        return "255.255.255.0"  # Clase C → /24
    } else {
        return "255.255.255.0"  # Valor por defecto
    }
}

function Configurar {
    Write-Host "Iniciando Configuraciones..." -ForegroundColor Green

    $scopeName = Read-Host "Nombre del ambito"

    # Capturar la IP fija (servidor)
    $fixedIP = Pedir-IP "IP fija del servidor"
    Write-Host "IP fija del servidor: $fixedIP"

    # Configurar la IP fija en la interfaz de red
    $gateway = Read-Host "Gateway (opcional, no ingreses nada si no aplica)"
    $subnetMask = Get-SubnetMaskFromIP $fixedIP
    $prefix = Get-PrefixLength -SubnetMask $subnetMask
    Write-Host "Máscara calculada: $subnetMask (/$prefix)"

    try {
        # Aporte soto sol
        Remove-NetIPAddress -InterfaceIndex 11 -Confirm:$false
        $interface = Get-NetAdapter -Name "Ethernet1"
        if ([string]::IsNullOrWhiteSpace($gateway)) {
            New-NetIPAddress -InterfaceIndex $interface.InterfaceIndex `
            -IPAddress $fixedIP `
            -PrefixLength $prefix -ErrorAction Stop | Out-Null
    } else {
        New-NetIPAddress -InterfaceIndex $interface.InterfaceIndex `
            -IPAddress $fixedIP `
            -PrefixLength $prefix `
            -DefaultGateway $gateway -ErrorAction Stop | Out-Null
    }
    Write-Host "IP fija configurada en la interfaz $($interface.Name)" -ForegroundColor Green
    } catch {
        Write-Host "Error al asignar la IP fija: $_" -ForegroundColor Red
    }

    # Calcular la IP inicial del ámbito = IP fija + 1
    $fixedInt = IP-a-Int $fixedIP
    $startInt = $fixedInt + 1
    $startIP = [System.Net.IPAddress]::Parse(($startInt).ToString())
    Write-Host "IP inicial del ambito: $startIP"

    do {
        # Pedir la IP final
        $endIP  = Pedir-IP "IP final"
        $endInt = IP-a-Int $endIP

        # Validar rango
        if ($startInt -gt $endInt) {
            Write-Host "La IP inicial no puede ser mayor que la IP final."
        }

        # Validar subred
        elseif ($startNet -ne $endNet) {
            Write-Host "La IP inicial y la IP final no pertenecen a la misma subred."
        }

    } until ( ($startInt -le $endInt) -and ($startNet -eq $endNet) )

    Write-Host "Las IPs son validas: mismo rango y misma subred."

    $maskInt = IP-a-Int $subnetMask
    $startNet = $startInt -band $maskInt
    $endNet = $endInt -band $maskInt

    # DNS primario y alternativo opcionales 
    $dns = Read-Host "DNS primario (opcional)" 
    $dnsAlt = Read-Host "DNS alternativo (opcional)"

    do {
        $lease = Read-Host "Tiempo de concesion (dias)"
    } until ($lease -match '^\d+$')

    try {
        Write-Host "Servicio DHCP Instalandose..." -ForegroundColor Green
        # Instalacion silenciosa DHCP
        Import-Module DhcpServer -ErrorAction Stop
        Start-Service DHCPServer

    # Crear el ambito
        Add-DhcpServerv4Scope `
            -Name $scopeName `
            -StartRange $startIP `
            -EndRange $endIP `
            -SubnetMask $subnetMask `
            -LeaseDuration (New-TimeSpan -Days $lease) | Out-Null
            
    Write-Host "Ambito creado y configurado correctamente." -ForegroundColor Green
    }
    catch {
        Write-Host "Error al crear el ambito: $_" -ForegroundColor Red
    }

    $scope = Get-DhcpServerv4Scope |
    Where-Object { $_.StartRange -eq $startIP -and $_.EndRange -eq $endIP }

# Construir lista de DNS si se ingresaron
$dnsList = @()
if (-not [string]::IsNullOrWhiteSpace($dns)) { $dnsList += $dns }
if (-not [string]::IsNullOrWhiteSpace($dnsAlt)) { $dnsList += $dnsAlt }

# Aplicar opciones solo si hay valores 
if (-not [string]::IsNullOrWhiteSpace($gateway) -and $dnsList.Count -gt 0) {
    # Caso: Gateway y DNS presentes
    Set-DhcpServerv4OptionValue -ScopeId $scope.ScopeId -Router $gateway -DnsServer $dnsList
}
elseif (-not [string]::IsNullOrWhiteSpace($gateway)) {
    # Caso: Solo Gateway
    Set-DhcpServerv4OptionValue -ScopeId $scope.ScopeId -Router $gateway
}
elseif ($dnsList.Count -gt 0) {
    # Caso: Solo DNS
    Set-DhcpServerv4OptionValue -ScopeId $scope.ScopeId -DnsServer $dnsList
}
else {
    Write-Host "No se configuraron opciones de Gateway ni DNS." -ForegroundColor Yellow
}

}

function Instalar {
    Write-Host "Iniciando Configuraciones..." -ForegroundColor Green
    try{
        Install-WindowsFeature DHCP -IncludeManagementTools -ErrorAction Stop | Out-Null
        Write-Host "Instalacion finalizada" -ForegroundColor Green
    }
    catch{
        Write-Host "Instalacion fallida..." -ForegroundColor Red
    }
}

function VerificarServicio {
    if ((Get-WindowsFeature -Name DHCP).Installed) {
        Write-Host "El rol DHCP ya esta instalado."
    } else {
        Write-Host "El rol DHCP no esta instalado."
        $respuesta = Read-Host "¿Deseas instalarlo ahora? (S/N)"
        if ($respuesta -match '^[sS]$') {
            Instalar
        } else {
            Write-Host "Instalacion cancelada por el usuario."
        }
    }
}

function ReiniciarDHCP {
    Write-Host "Reiniciando servicio DHCP..."
    try {
        Restart-Service -Name "DHCPServer" -Force -ErrorAction Stop
        Write-Host "Servicio DHCP reiniciado correctamente" -ForegroundColor Green
    } catch {
        Write-Host "Error al reiniciar el servicio DHCP" -ForegroundColor Red
    }
}

function ListarConcesiones {
    Write-Host "Iniciando monitoreo..."
    try {
        Get-Service DHCPServer
        $scopes = Get-DhcpServerv4Scope
        foreach ($scope in $scopes) {
            Write-Host "Concesiones para ScopeId $($scope.ScopeId) - $($scope.Name)"
            Get-DhcpServerv4Lease -ScopeId $scope.ScopeId |
            Select-Object IPAddress, HostName, ClientId, LeaseExpiryTime |
            Format-Table -AutoSize
        }
    }
    catch {
        Write-Host "DHCP no se encuentra instalado" -ForegroundColor Red
    }
}


$con = "S"

while ($con -match '^[sS]$') {
    Write-Host "Tarea 2: Automatizacion y Gestion del Servidor DHCP"
    Write-Host "++++++++ Menu de Opciones ++++++++"
    Write-Host "1.-Verificar la presencia del servicio"
    Write-Host "2.-Instalar el servicio"
    Write-Host "3.-Configurar el servicio"
    Write-Host "4.-Monitoreo"
    Write-Host "5.-Reiniciar Servivicios"
    Write-Host "6.-Salir"
    $op = [int](Read-Host "Selecciona: ")
    switch($op){
        1{VerificarServicio}
        2{Instalar}
        3{Configurar}
        4{ListarConcesiones}
        5{ReiniciarDHCP}
        6{$con = "n"}
        default{Write-Host "Opcion no valida"}
    }
}
Write-Host "Programa terminado."