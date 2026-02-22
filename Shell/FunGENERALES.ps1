function VerificarRoot {
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-not $isAdmin) {
        Write-Host "Ejecuta este script como Administrador"
        exit
    }
}

function InstalarPaquete {
    param (
        [string]$FeatureName
    )

    Write-Host "Instalando característica: $FeatureName"
    Install-WindowsFeature -Name $FeatureName -IncludeManagementTools
}

function Validar-IP {
    param ($ip)
    if ($ip -match '^((25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$') {
        return ($ip -ne "255.255.255.255" -and $ip -ne "0.0.0.0" -and $ip -ne "127.0.0.1")
    }
    return $false
}

function IP-a-Int {
    param ([string]$ip)
    $bytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
    [Array]::Reverse($bytes)
    return [BitConverter]::ToUInt32($bytes, 0)
}

function Pedir-IP {
    param (
        [string]$mensaje
    )

    do {
        $ip = Read-Host $mensaje
        if (-not (Validar-IP $ip)) {
            Write-Host "IP no valida, intenta de nuevo"
        }
    } until (Validar-IP $ip)

    return $ip
}

function Get-PrefixLength {
    param([string]$SubnetMask)
    $bytes = $SubnetMask.Split('.') | ForEach-Object { [Convert]::ToString([int]$_,2).PadLeft(8,'0') }
    ($bytes -join '').ToCharArray() | Where-Object { $_ -eq '1' } | Measure-Object | Select-Object -ExpandProperty Count
}